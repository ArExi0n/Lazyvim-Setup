#!/usr/bin/env lua

-- Simple test runner for Neovim LSP configuration tests
local function run_tests()
	-- Add current directory to package path
	local current_dir = debug.getinfo(1, "S").source:match("@(.*/)") or "./"
	package.path = current_dir .. "../?.lua;" .. current_dir .. "../lua/?.lua;" .. package.path

	-- Mock busted framework functions
	local test_cases = {}
	local current_describe = nil
	local current_it = nil
	local test_results = { passed = 0, failed = 0, errors = {} }

	-- Mock functions for testing framework
	_G.describe = function(name, fn)
		current_describe = name
		print("Running: " .. name)
		fn()
		current_describe = nil
	end

	_G.it = function(name, fn)
		current_it = name
		local full_name = (current_describe or "Unknown") .. " > " .. name
		print("  " .. name)

		local success, err = pcall(fn)
		if success then
			test_results.passed = test_results.passed + 1
			print("    ✓ PASSED")
		else
			test_results.failed = test_results.failed + 1
			table.insert(test_results.errors, { test = full_name, error = err })
			print("    ✗ FAILED: " .. tostring(err))
		end
		current_it = nil
	end

	_G.before_each = function(fn)
		fn()
	end

	_G.after_each = function(fn)
		fn()
	end

	-- Mock assertion library
	local assert_lib = {}

	function assert_lib.equals(expected, actual, message)
		if expected ~= actual then
			error(
				string.format(
					"Expected %s but got %s%s",
					tostring(expected),
					tostring(actual),
					message and (" - " .. message) or ""
				)
			)
		end
	end

	function assert_lib.is_true(value, message)
		if value ~= true then
			error("Expected true but got " .. tostring(value) .. (message and (" - " .. message) or ""))
		end
	end

	function assert_lib.is_not_nil(value, message)
		if value == nil then
			error("Expected non-nil value" .. (message and (" - " .. message) or ""))
		end
	end

	function assert_lib.is_function(value, message)
		if type(value) ~= "function" then
			error("Expected function but got " .. type(value) .. (message and (" - " .. message) or ""))
		end
	end

	function assert_lib.is_table(value, message)
		if type(value) ~= "table" then
			error("Expected table but got " .. type(value) .. (message and (" - " .. message) or ""))
		end
	end

	function assert_lib.same(expected, actual, message)
		local function tables_equal(t1, t2)
			if type(t1) ~= type(t2) then
				return false
			end
			if type(t1) ~= "table" then
				return t1 == t2
			end

			for k, v in pairs(t1) do
				if not tables_equal(v, t2[k]) then
					return false
				end
			end
			for k, v in pairs(t2) do
				if not tables_equal(v, t1[k]) then
					return false
				end
			end
			return true
		end

		if not tables_equal(expected, actual) then
			error(string.format("Tables not equal%s", message and (" - " .. message) or ""))
		end
	end

	_G.assert = assert_lib

	-- Mock spy library
	local spy_lib = {}

	function spy_lib.new(fn)
		local calls = {}
		local spy_fn = function(...)
			table.insert(calls, { ... })
			if fn then
				return fn(...)
			end
		end

		spy_fn.was_called = function()
			return #calls > 0
		end

		spy_fn.was_called_with = function(...)
			local expected_args = { ... }
			for _, call_args in ipairs(calls) do
				local match = true
				for i, expected in ipairs(expected_args) do
					local actual = call_args[i]
					if type(expected) == "table" and expected.has_match then
						if not expected.has_match(actual) then
							match = false
							break
						end
					elseif expected ~= actual then
						match = false
						break
					end
				end
				if match then
					return true
				end
			end
			return false
		end

		return spy_fn
	end

	_G.spy = spy_lib

	-- Mock match library
	_G.match = {
		has_match = function(fn)
			return { has_match = fn }
		end,
	}

	print("Starting LSP Configuration Tests...")
	print("=" .. string.rep("=", 50))

	-- Load and run the test file
	require("tests.lsp_spec")

	print("=" .. string.rep("=", 50))
	print(string.format("Test Results: %d passed, %d failed", test_results.passed, test_results.failed))

	if test_results.failed > 0 then
		print("\nFailures:")
		for _, failure in ipairs(test_results.errors) do
			print(string.format("  %s: %s", failure.test, failure.error))
		end
		return 1
	else
		print("\nAll tests passed! ✓")
		return 0
	end
end

-- Run the tests
os.exit(run_tests())

