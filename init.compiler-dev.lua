-- ========================================
-- Nyoom Tangerine Bootstrap (safe)
-- ========================================

-- 0. Add Tangerine + dependencies
vim.pack.add({
	{ src = "https://github.com/nvim-neorocks/lz.n" },
	{ src = "https://github.com/udayvir-singh/tangerine.nvim" },
})
vim.cmd.packadd("lz.n")
vim.cmd.packadd("tangerine.nvim")

-- ========================================
-- init.lua: Nyoom Fennel Bootstrap
-- ========================================

require("tangerine")
local api = require("tangerine.api")
local fennel = require("tangerine.fennel")

-- Define allowed globals for Nyoom compiler
fennel["allowed-globals"] = {
	"vim",
	"shared",
	"tables",
	"fun",
	"nth",
	"deep-merge",
	"echo!",
	"err!",
	"warn!",
	"build",
	"setup",
	"autoload",
	"packadd!",
	"nyoom!",
	"use-package!",
	"rock!",
	"pack",
	"rock",
	"nyoom-init-modules!",
	"nyoom-compile-modules!",
	"unpack!",
	"autocmd!",
}

-- Type helpers
for name, fn in pairs({
	["table?"] = function(x)
		return type(x) == "table"
	end,
	["nil?"] = function(x)
		return x == nil
	end,
	["string?"] = function(x)
		return type(x) == "string"
	end,
	["number?"] = function(x)
		return type(x) == "number"
	end,
	["boolean?"] = function(x)
		return type(x) == "boolean"
	end,
}) do
	_G[name] = fn
end

-- Paths
vim.cmd.cd(vim.fn.stdpath("config"))
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
local lua_dir = vim.fn.stdpath("config") .. "/lua"
fennel.path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. (fennel.path or "")
fennel["macro-path"] = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/macros-macros/?.fnl;" .. (fennel["macro-path"] or "")
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- ========================================
-- Bootstrap function
-- ========================================
local function bootstrap_lib(name)
	local src = fnl_dir .. "/core/lib/" .. name .. ".fnl"
	local dest = lua_dir .. "/core/lib/" .. name .. ".lua"
	api.compile.file(src, dest, { float = true, verbose = true })
	package.loaded["core.lib." .. name] = nil
	local ok, module = pcall(require, "core.lib." .. name)
	if not ok then
		error("Failed to load core.lib." .. name .. ": " .. tostring(module))
	end
	return module
end

-- ========================================
-- 1. Bootstrap minimal core libs for macros
-- Order matters!
-- ========================================
fennel["compiler-env"] = fennel["compiler-env"] or {}
fennel["macro-env"] = fennel["macro-env"] or {}

_G.shared = bootstrap_lib("shared")
_G.tables = bootstrap_lib("tables")
_G.fun = bootstrap_lib("fun")
_G.crypt = bootstrap_lib("crypt") -- critical for macros
_G.nth = _G.fun.nth
_G.deep_merge = _G.tables.deep_merge

fennel["compiler-env"][shared] = shared -- compile-time for macros
fennel["compiler-env"][crypt] = _G.crypt -- compile-time for macros
fennel["macro-env"][crypt] = _G.crypt
fennel["compiler-env"].nth = _G.nth
fennel["compiler-env"].deep_merge = _G.deep_merge
--
--
-- Additional helpers macros may use
local io_lib = bootstrap_lib("io")
_G["echo!"] = io_lib["echo!"]
_G["err!"] = io_lib["err!"]
fennel["compiler-env"]["echo!"] = io_lib["echo!"]
fennel["compiler-env"]["err!"] = io_lib["err!"]

-- ========================================
-- 2. Compile macros
-- ========================================
api.compile.dir(fnl_dir .. "/macros", lua_dir .. "/macros", { float = true, verbose = true })

-- ========================================
-- 3. Bootstrap remaining core/lib modules
-- ========================================
local remaining_libs = { "autoload", "setup", "p", "profile", "color", "init" }
local runtime_globals = { autoload = true, setup = true } -- crypt already handled
local loaded_libs = {}

for _, name in ipairs(remaining_libs) do
	local lib = bootstrap_lib(name)
	loaded_libs[name] = lib
	if runtime_globals[name] then
		_G[name] = lib
	end
	-- Inject into compiler-env in case macros touch it
	fennel["compiler-env"][name] = lib
end

-- Helpers from p module
_G["getfenv"] = loaded_libs.p["getfenv"]
_G["setfenv"] = loaded_libs.p["setfenv"]
fennel["compiler-env"]["getfenv"] = _G["getfenv"]
fennel["compiler-env"]["setfenv"] = _G["setfenv"]

-- ========================================
-- 4. Compile core/*.fnl individually
-- ========================================
local core_files = {
	{ fnl_dir .. "/core/init.fnl", lua_dir .. "/core/init.lua" },
	{ fnl_dir .. "/core/repl.fnl", lua_dir .. "/core/repl.lua" },
	{ fnl_dir .. "/core/doctor.fnl", lua_dir .. "/health.lua" },
}
for _, pair in ipairs(core_files) do
	local ok, err = pcall(function()
		api.compile.file(pair[1], pair[2], { float = true, force = true, verbose = true })
	end)
	if not ok then
		print("COMPILE ERROR [" .. pair[1] .. "]: " .. tostring(err))
	end
end

-- ========================================
-- 5. Compile base entry points
-- ========================================
local base_files = {
	{ fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua" },
	{ fnl_dir .. "/modules.fnl", lua_dir .. "/modules.lua" },
	{ fnl_dir .. "/config.fnl", lua_dir .. "/config.lua" },
	{ fnl_dir .. "/packages.fnl", lua_dir .. "/packages.lua" },
}
for _, pair in ipairs(base_files) do
	local ok, err = pcall(function()
		api.compile.file(pair[1], pair[2], { float = true, force = true, verbose = true })
	end)
	if not ok then
		print("COMPILE ERROR [" .. pair[1] .. "]: " .. tostring(err))
	end
end

-- ========================================
-- 6. Handoff to main entrypoint
-- ========================================
local ok, err = pcall(require, "nyoom")
if not ok then
	print("NYOOM: Handoff failed!")
	print(err)
end
