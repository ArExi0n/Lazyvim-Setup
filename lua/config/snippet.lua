-- Guard against stale vim.snippet sessions.
--
-- Neovim's native snippet engine keeps a single global session whose tabstops
-- are buffer extmarks. Anything that rewrites a buffer wholesale (external
-- reload via autoread/checktime, whole-file :%s, grug-far/refactoring rewrites,
-- ...) deletes those extmarks without ending the session. From then on every
-- <Tab> (snippet jump) and every keystroke (TextChanged sync) throws:
--   lua/vim/snippet.lua:102: attempt to index a nil value
-- This watchdog validates the session's extmarks and stops dead sessions
-- before they can spam.
local M = {}

local NS = "nvim.snippet"

local function mark_alive(bufnr, ns, id)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	local ok, mark = pcall(vim.api.nvim_buf_get_extmark_by_id, bufnr, ns, id, { details = true })
	return ok and type(mark) == "table" and mark[3] ~= nil
end

---@return boolean true when there is no session or it is fully intact
function M.session_alive()
	local s = vim.snippet._session
	if not s then
		return true
	end
	local ns = vim.api.nvim_get_namespaces()[NS]
	if not ns then
		return true
	end
	if not mark_alive(s.bufnr, ns, s.extmark_id) then
		return false
	end
	for _, tabstops in pairs(s.tabstops or {}) do
		for _, ts in ipairs(tabstops) do
			if not mark_alive(ts.bufnr or s.bufnr, ns, ts.extmark_id) then
				return false
			end
		end
	end
	return true
end

-- End a dead session quietly. Never touches a healthy one.
function M.stop_if_stale()
	local s = vim.snippet._session
	if s == nil or M.session_alive() then
		return
	end
	-- stop() only acts when the session buffer is current; run it there.
	pcall(vim.api.nvim_buf_call, s.bufnr, function()
		pcall(vim.snippet.stop)
	end)
	if vim.snippet._session == s then
		-- Buffer is gone so stop() bailed: clear the leftovers ourselves.
		local ns = vim.api.nvim_get_namespaces()[NS]
		pcall(vim.api.nvim_clear_autocmds, { group = NS, buf = s.bufnr })
		if ns then
			pcall(vim.api.nvim_buf_clear_namespace, s.bufnr, ns, 0, -1)
		end
		vim.snippet._session = nil
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("user-snippet-guard", { clear = true })
	-- A (re)read wipes extmarks by definition; a session spanning one is dead.
	vim.api.nvim_create_autocmd({ "BufReadPost", "FileChangedShellPost" }, {
		group = group,
		callback = function(ev)
			local s = vim.snippet._session
			if s ~= nil and s.bufnr == ev.buf then
				M.stop_if_stale()
			end
		end,
	})
	-- Catch-all for anything else that rewrote the buffer: validate before
	-- the next keystroke/command trips over the corpse. InsertCharPre runs
	-- before the char's TextChanged, so it pre-empts the per-keystroke spam.
	vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "InsertCharPre" }, {
		group = group,
		callback = function()
			M.stop_if_stale()
		end,
	})

	-- Close the <Tab> race: LazyVim's snippet_forward checks active() then
	-- schedules jump(1). Validate synchronously first so a session that died
	-- milliseconds ago falls through instead of throwing from the callback.
	local ok, cmp_util = pcall(require, "lazyvim.util.cmp")
	if ok and cmp_util.actions and cmp_util.actions.snippet_forward then
		local orig = cmp_util.actions.snippet_forward
		cmp_util.actions.snippet_forward = function()
			M.stop_if_stale()
			return orig()
		end
	end
end

return M
