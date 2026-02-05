-- ========================================
-- Nyoom Tangerine Bootstrap (safe)
-- ========================================

vim.pack.add({
	{ src = "https://github.com/nvim-neorocks/lz.n" },
	{ src = "https://github.com/udayvir-singh/tangerine.nvim" },
})

vim.cmd.packadd("lz.n")
vim.cmd.packadd("tangerine.nvim")

-- ========================================
-- init.lua: Nyoom Fennel Bootstrap
-- ========================================

-- 0. Tangerine/Fennel setup
local nyoom_globals = {
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

-- require("tangerine")
local api = require("tangerine.api")
local fennel = require("tangerine.fennel")
-- fennel["compiler-env"] = _G
-- 1. Define EVERY symbol that Nyoom uses as a global
-- This list needs to be comprehensive to satisfy the strict compiler
-- fennel["allowed-globals"] = nyoom_globals
fennel["allowed-globals"] = nyoom_globals

-- Type helpers
local function table_q(x)
	return type(x) == "table"
end
local function nil_q(x)
	return x == nil
end
local function string_q(x)
	return type(x) == "string"
end
local function number_q(x)
	return type(x) == "number"
end
local function boolean_q(x)
	return type(x) == "boolean"
end

-- Inject into runtime and compile-time environment BEFORE bootstrapping core/lib
for name, fn in pairs({
	["table?"] = table_q,
	["nil?"] = nil_q,
	["string?"] = string_q,
	["number?"] = number_q,
	["boolean?"] = boolean_q,
}) do
	_G[name] = fn
end

-- 1. Paths
vim.cmd.cd(vim.fn.stdpath("config")) -- absolutely needed for include fnl.modules in packages.fnl
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
local lua_dir = vim.fn.stdpath("config") .. "/lua"
fennel.path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. (fennel.path or "")
fennel["macro-path"] = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/macros-macros/?.fnl;" .. (fennel["macro-path"] or "")
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- 2. Bootstrap core/lib essentials
local function bootstrap_lib(name)
	-- print(name)
	local src = fnl_dir .. "/core/lib/" .. name .. ".fnl"
	local dest = lua_dir .. "/core/lib/" .. name .. ".lua"
	api.compile.file(src, dest, { verbose = true })
	package.loaded["core.lib." .. name] = nil
	local ok, module = pcall(require, "core.lib." .. name)
	if not ok then
		error("Failed to load core.lib." .. name .. ": " .. tostring(module))
	end
	return module
end

_G.nyoom = {}
-- print("NYOOM: Bootstrapping core/lib essentials...")
_G.shared = bootstrap_lib("shared")
_G.nyoom.shared = bootstrap_lib("shared")
_G.tables = bootstrap_lib("tables")
_G.fun = bootstrap_lib("fun")
_G.crypt = bootstrap_lib("crypt")
_G.autoload = bootstrap_lib("autoload") --will not compile without this
local p_lib = bootstrap_lib("p")

_G.p = p_lib
_G.nth = fun.nth
_G.deep_merge = tables.deep_merge
_G["getfenv"] = p_lib["getfenv"]
_G["setfenv"] = p_lib["setfenv"]

-- ========================================
-- 2. Compile Macros (before core/*.fnl)
-- ========================================
-- print("NYOOM: Compiling macros...")
api.compile.dir(fnl_dir .. "/macros", lua_dir .. "/macros", { verbose = true })
-- Load macros into the compiler env so they can be used

-- ========================================
-- 3. Compile remaining core/lib modules
-- ========================================
local remaining_libs = { "setup", "profile", "io", "color", "init" }

local runtime_globals = {
	autoload = true,
	setup = true,
}

local loaded_libs = {}

for _, name in ipairs(remaining_libs) do
	-- print("Bootstrapping " .. name)
	local module = bootstrap_lib(name)
	loaded_libs[name] = module

	if runtime_globals[name] then
		_G[name] = module
	end
end

-- Export io helpers for runtime Lua
local io_lib = loaded_libs.io
_G["echo!"] = io_lib["echo!"]
_G["err!"] = io_lib["err!"]

-- ========================================
-- 4. Compile core/*.fnl files individually
-- ========================================
local function safe_compile(src, dest)
	-- 3. Run the standard Tangerine compile
	local ok, err = pcall(function()
		api.compile.file(src, dest, {
			force = true,
			verbose = true,
		})
	end)

	if not ok then
		print("COMPILE ERROR [" .. src .. "]: " .. tostring(err))
	end
end

-- print("NYOOM: Compiling core logic...")

local core_files = {
	-- core runtime
	{ fnl_dir .. "/core/init.fnl", lua_dir .. "/core/init.lua" },
	{ fnl_dir .. "/core/repl.fnl", lua_dir .. "/core/repl.lua" },

	-- Compiling the Doctor into the Health system
	-- health check (must land in lua/health.lua)
	{ fnl_dir .. "/core/doctor.fnl", lua_dir .. "/health.lua" },
}

for _, pair in ipairs(core_files) do
	safe_compile(pair[1], pair[2])
end

-- print("NYOOM: Compiling entry point...")
local base_files = {
	{ fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua" },
	{ fnl_dir .. "/modules.fnl", lua_dir .. "/modules.lua" },
	{ fnl_dir .. "/config.fnl", lua_dir .. "/config.lua" },
	{ fnl_dir .. "/packages.fnl", lua_dir .. "/packages.lua" },
}

for _, pair in ipairs(base_files) do
	safe_compile(pair[1], pair[2])
end

-- ========================================
-- 5. Compile 'after' RTP (The non-dumb way)
-- ========================================
if vim.fn.isdirectory("after") == 1 then
	-- Compile everything in /after/*.fnl to /after/*.lua
	-- Neovim will then naturally find after/ftplugin/python.lua, etc.
	--api.compile.dir(fnl_dir .. "/after/lsp/", "/after/lsp/", {
	api.compile.dir("after/lsp", "after/lsp/", {
		force = true,
		verbose = false,
	})
end

-- ========================================
-- 6. Handoff to main entrypoint
-- ========================================
-- print("NYOOM: Handoff to nyoom.fnl")
local ok, err = pcall(require, "nyoom")
if not ok then
	print("NYOOM: Handoff failed!")
	print(err)
end
