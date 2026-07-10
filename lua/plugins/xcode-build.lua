local progress_handle

local function get_available_simulators()
  local handle = io.popen("xcrun simctl list devices available --json 2>/dev/null")
  if not handle then return {} end
  local result = handle:read("*a")
  handle:close()
  local ok, data = pcall(vim.json.decode, result)
  if not ok or not data or not data.devices then return {} end
  local devices = {}
  for runtime, list in pairs(data.devices) do
    for _, device in ipairs(list) do
      if device.isAvailable then
        local major, minor = runtime:match("iOS%-(%d+)%-(%d+)")
        local os_ver = major and (major .. "." .. minor) or ""
        table.insert(devices, {
          id = device.udid,
          name = device.name,
          os = os_ver,
          runtime = runtime,
        })
      end
    end
  end
  return devices
end

local function auto_select_device()
  local config = require("xcodebuild.project.config")
  local devices = get_available_simulators()
  if #devices == 0 then
    vim.notify("No available simulators found", vim.log.levels.WARN)
    return
  end
  local current_name = config.settings.deviceName
  if current_name then
    for _, d in ipairs(devices) do
      if d.name == current_name then
        vim.notify("Device already selected: " .. d.name)
        return
      end
    end
  end
  config.set_destination({
    id = devices[1].id,
    platform = "iOS Simulator",
    name = devices[1].name,
    os = devices[1].os,
  })
  vim.notify("Selected device: " .. devices[1].name)
end

local function cleanup_simulators()
  local handle = io.popen("xcrun simctl delete unavailable 2>&1")
  if handle then
    handle:read("*a")
    handle:close()
  end
  local rh = io.popen("xcrun simctl list runtimes --json 2>/dev/null")
  if not rh then return end
  local result = rh:read("*a")
  rh:close()
  local ok, data = pcall(vim.json.decode, result)
  if not ok or not data or not data.runtimes then return end
  local to_delete = {}
  for _, rt in ipairs(data.runtimes) do
      if rt.isAvailable and rt.platform == "iOS" then
        local major = tonumber(rt.version:match("^(%d+)")) or 0
        if major < 17 and major > 0 then
          table.insert(to_delete, rt)
        end
      end
  end
  if #to_delete == 0 then
    vim.notify("No old simulator runtimes to clean up")
    return
  end
  local names = vim.tbl_map(function(rt) return rt.name end, to_delete)
  local msg = "Delete " .. #to_delete .. " old simulator runtime(s) to free space?\n" .. table.concat(names, "\n")
  vim.ui.select({ "Yes, delete them", "Cancel" }, {
    prompt = msg,
  }, function(choice)
    if not choice or choice ~= "Yes, delete them" then
      vim.notify("Cleanup cancelled")
      return
    end
    for _, rt in ipairs(to_delete) do
      pcall(function()
        vim.fn.system({ "xcrun", "simctl", "runtime", "delete", rt.identifier })
        vim.notify("Deleted: " .. (rt.name or rt.identifier))
      end)
    end
    vim.notify("Simulator cleanup complete")
  end)
end

return {
	"wojciech-kulik/xcodebuild.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("xcodebuild").setup({
			show_build_progress_bar = false,
			logs = {
				auto_open_on_success_tests = false,
				auto_open_on_failed_tests = false,
				auto_open_on_success_build = false,
				auto_open_on_failed_build = false,
				auto_focus = false,
				auto_close_on_app_launch = true,
				only_summary = true,
				notify = function(message, severity)
					local fidget = require("fidget")
					if progress_handle then
						progress_handle.message = message
						if not message:find("Loading") then
							progress_handle:finish()
							progress_handle = nil
							if vim.trim(message) ~= "" then
								fidget.notify(message, severity)
							end
						end
					else
						fidget.notify(message, severity)
					end
				end,
				notify_progress = function(message)
					local progress = require("fidget.progress")

					if progress_handle then
						progress_handle.title = ""
						progress_handle.message = message
					else
						progress_handle = progress.handle.create({
							message = message,
							lsp_client = { name = "xcodebuild.nvim" },
						})
					end
				end,
			},
			code_coverage = {
				enabled = true,
			},
		})

		-- Xcodebuild Keybindings
		vim.keymap.set("n", "<leader>X", "<cmd>XcodebuildPicker<cr>", { desc = "Show Xcodebuild Actions" })
		vim.keymap.set(
			"n",
			"<leader>xf",
			"<cmd>XcodebuildProjectManager<cr>",
			{ desc = "Show Project Manager Actions" }
		)

		vim.keymap.set("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
		vim.keymap.set("n", "<leader>xB", "<cmd>XcodebuildBuildForTesting<cr>", { desc = "Build For Testing" })
		vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })

		vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
		vim.keymap.set("v", "<leader>xt", "<cmd>XcodebuildTestSelected<cr>", { desc = "Run Selected Tests" })
		vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run This Test Class" })

		vim.keymap.set("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Xcodebuild Logs" })
		vim.keymap.set("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Toggle Code Coverage" })
		vim.keymap.set(
			"n",
			"<leader>xC",
			"<cmd>XcodebuildShowCodeCoverageReport<cr>",
			{ desc = "Show Code Coverage Report" }
		)
		vim.keymap.set("n", "<leader>xe", "<cmd>XcodebuildTestExplorerToggle<cr>", { desc = "Toggle Test Explorer" })
		vim.keymap.set("n", "<leader>xs", "<cmd>XcodebuildFailingSnapshots<cr>", { desc = "Show Failing Snapshots" })

		vim.keymap.set("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
		vim.keymap.set("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>", { desc = "Select Test Plan" })
		

		vim.keymap.set("n", "<leader>xx", "<cmd>XcodebuildQuickfixLine<cr>", { desc = "Quickfix Line" })
		vim.keymap.set("n", "<leader>xa", "<cmd>XcodebuildCodeActions<cr>", { desc = "Show Code Actions" })

		vim.api.nvim_create_user_command("XcodebuildAutoDevice", auto_select_device,
			{ desc = "Auto-select first available simulator" })
		vim.api.nvim_create_user_command("XcodebuildCleanupSimulators", cleanup_simulators,
			{ desc = "Remove unused simulator runtimes (asks permission)" })
		vim.keymap.set("n", "<leader>xz", "<cmd>XcodebuildAutoDevice<cr>", { desc = "Auto-select simulator" })
		vim.keymap.set("n", "<leader>xZ", "<cmd>XcodebuildCleanupSimulators<cr>",
			{ desc = "Clean up simulator runtimes" })
	end,
}
