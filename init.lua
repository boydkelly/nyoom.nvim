-- ========================================
-- Nyoom Tangerine Bootstrap (safe)
-- ========================================

-- 0. Disable builtin plugins/providers (unchanged from Nyoom)
local default_plugins = {
	"2html_plugin",
	"getscript",
	"getscriptPlugin",
	"gzip",
	"logipat",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"matchit",
	"tar",
	"tarPlugin",
	"rrhelper",
	"spellfile_plugin",
	"vimball",
	"vimballPlugin",
	"zip",
	"zipPlugin",
	"tutor",
	"rplugin",
	"syntax",
	"synmenu",
	"optwin",
	"compiler",
	"bugreport",
	"ftplugin",
}
local default_providers = { "node", "perl", "ruby" }

for _, p in ipairs(default_plugins) do
	vim.g["loaded_" .. p] = 1
end
for _, p in ipairs(default_providers) do
	vim.g["loaded_" .. p .. "_provider"] = 0
end

vim.pack.add({
	{ src = "https://github.com/udayvir-singh/tangerine.nvim" },
})
vim.cmd.packadd("tangerine.nvim")

-- ========================================
-- init.lua: Nyoom Fennel Bootstrap
-- ========================================

-- 0. Tangerine/Fennel setup
local tangerine = require("tangerine")
local api = require("tangerine.api")
local fennel = require("tangerine.fennel")
fennel["compiler-env"] = _G

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
	fennel["compiler-env"][name] = fn
end
_G.table = table
fennel["compiler-env"].table = table

-- 1. Paths
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
local lua_dir = vim.fn.stdpath("config") .. "/lua"
fennel.path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl"
fennel["macro-path"] = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/macros-macros/?.fnl;" .. (fennel["macro-path"] or "")
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- This tells the compiler where to find the SOURCE files for (include) or (require)
fennel.path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. (fennel.path or "")

-- 2. Bootstrap core/lib essentials
local function bootstrap_lib(name)
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

print("NYOOM: Bootstrapping core/lib essentials...")
local shared = bootstrap_lib("shared")
local tables = bootstrap_lib("tables")
local fun = bootstrap_lib("fun")

-- Inject runtime globals from bootstrapped libs
_G.shared = shared
_G.tables = tables
_G.fun = fun
_G.nth = fun.nth
_G.deep_merge = tables.deep_merge

-- Inject into Fennel compiler_env for compile-time
fennel["compiler-env"].shared = shared
fennel["compiler-env"].tables = tables
fennel["compiler-env"].fun = fun
fennel["compiler-env"].nth = fun.nth
fennel["compiler-env"].deep_merge = tables.deep_merge
fennel["compiler-env"]["nil?"] = function(v)
	return v == nil
end

-- ========================================
-- 2. Compile Macros (before core/*.fnl)
-- ========================================
print("NYOOM: Compiling macros...")
api.compile.dir(fnl_dir .. "/macros", lua_dir .. "/macros", { verbose = true })
-- Load macros into the compiler env so they can be used

-- Example, after compiling macros
-- Any macro functions you want available for core/*.fnl or packages.fnl
-- These names must match what your macros define
fennel["compiler-env"]["echo!"] = function(msg)
	print(msg)
end

fennel["compiler-env"]["packadd!"] = function(plugin)
	vim.cmd.packadd(plugin)
end

-- ========================================
-- 3. Compile remaining core/lib modules
-- ========================================
-- Bootstrap remaining core/lib modules
local remaining_libs = { "autoload", "setup", "p", "profile", "io", "color", "crypt", "init" }
local loaded_libs = {}
for _, name in ipairs(remaining_libs) do
	print("Bootstrapping " .. name)
	local module = bootstrap_lib(name)
	loaded_libs[name] = module
	-- _G[name] = module  -- inject into _G for runtime
end

-- After bootstrapping remaining_libs (where io is loaded)
local io_lib = loaded_libs["io"]

-- Nyoom's io.fnl exports a table. We need to grab the functions correctly.
local echo_fn = io_lib["echo!"]
local err_fn = io_lib["err!"]

-- 1. Inject into Runtime Global (for compiled lua to use)
_G["echo!"] = echo_fn
_G["err!"] = err_fn

-- 2. Inject into Compiler Env (for Fennel compiler to see during compilation)
fennel["compiler-env"]["echo!"] = echo_fn
fennel["compiler-env"]["err!"] = err_fn

-- 3. Double Check: If those were nil, use a fallback so compilation doesn't break
if not echo_fn then
	local fallback = function(msg)
		print(tostring(msg))
	end
	fennel["compiler-env"]["echo!"] = fallback
	_G["echo!"] = fallback
end

-- Allow Fennel compiler to see these globals
-- ========================================
-- 4. Compile core/*.fnl files individually
-- ========================================

local function safe_compile(src, dest)
	-- 1. Define EVERY symbol that Nyoom uses as a global
	-- This list needs to be comprehensive to satisfy the strict compiler
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

	-- 2. Inject these into both the Fennel module and the Tangerine API
	fennel["allowed-globals"] = nyoom_globals

	-- 3. Run the standard Tangerine compile
	local ok, err = pcall(function()
		api.compile.file(src, dest, {
			force = true,
			verbose = true,
			-- Try both possible naming conventions
			compilerEnv = _G,
			env = _G,
			allowedGlobals = false, -- Setting to false DISBABLES the strict check in some versions
		})
	end)

	if not ok then
		print("COMPILE ERROR [" .. src .. "]: " .. tostring(err))
	end
end

print("NYOOM: Compiling core logic...")
local core_path = fnl_dir .. "/core"
-- local core_files = { "doctor.fnl", "init.fnl", "repl.fnl" }
local core_files = { "init.fnl", "repl.fnl" }
for _, filename in ipairs(core_files) do
	safe_compile(core_path .. "/" .. filename, lua_dir .. "/core/" .. filename:gsub("%.fnl$", ".lua"))
end

print("NYOOM: Compiling user configuration...")

local user_files = {
	{ fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua" },
	{ fnl_dir .. "/modules.fnl", lua_dir .. "/modules.lua" },
	{ fnl_dir .. "/config.fnl", lua_dir .. "/config.lua" },
	{ fnl_dir .. "/packages.fnl", lua_dir .. "/packages.lua" },
}

fennel["allowed-globals"] = {
	"vim",
	"shared",
	"tables",
	"fun",
	"nth",
	"deep-merge",
	"echo!",
	"err!",
	"packadd!",
	"nyoom!",
	"setup",
	"autoload",
}

-- Add this right before the user_files loop
local fennel_compiler = require("tangerine.fennel")

-- Some versions of Fennel require globals to be in the 'metadata' or 'env'
fennel_compiler["allowed-globals"] = {
	"vim",
	"shared",
	"tables",
	"fun",
	"nth",
	"deep-merge",
	"echo!",
	"err!",
	"packadd!",
	"nyoom!",
	"setup",
	"autoload",
}

-- Force the compiler to see the runtime _G
fennel_compiler["compiler-env"] = _G

for _, pair in ipairs(user_files) do
	safe_compile(pair[1], pair[2])
end

-- Finally, compile any remaining .fnl recursively
api.compile.dir(fnl_dir, lua_dir, { recursive = true, verbose = true })

-- ========================================
-- 6. Handoff to main entrypoint
-- ========================================
print("NYOOM: Handoff to nyoom.lua")
local ok, err = pcall(require, "nyoom")
if not ok then
	print("NYOOM: Handoff failed!")
	print(err)
end
