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

-- 1. bootstrap tangerine.nvim
vim.pack.add({
	{ src = "https://github.com/udayvir-singh/tangerine.nvim" },
})
vim.cmd.packadd("tangerine.nvim")

-- 1. Setup Tangerine and the compiler's search path
local tangerine = require("tangerine")
local api = require("tangerine.api")
local fennel = require("tangerine.fennel")

-- This is the "Secret Sauce":
-- We inject the actual modules into Fennel's own compiler environment
fennel["compiler-env"] = _G
-- Add this before you call api.compile.dir
-- This tells the compiler "Don't worry, these will exist at runtime"

-- Add 'shared' and 'deep-merge' (if it's also a global) to the list
fennel["allowed-globals"] = {
	"vim",
	"autoload",
	"setup",
	"_G",
	"nth",
	"fun",
	"shared",
	"deep-merge",
	"tables",
}

-- This tells the Fennel COMPILER where to look for macros.fnl and other deps
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
-- 2. Define our clean Lua target
local lua_dir = vim.fn.stdpath("config") .. "/lua"
require("tangerine.fennel").path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl"

-- 3. Update Neovim's package.path (LUA ONLY)
-- We remove the .fnl entry to stop the ')' expected error
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- 4. Compile and Inject core libs in dependency order
local lib_path = fnl_dir .. "/core/lib"

-- Function to compile and immediately make available to the compiler/runtime
local function bootstrap_lib(name, is_global)
	local src = lib_path .. "/" .. name .. ".fnl"
	local dest = lua_dir .. "/core/lib/" .. name .. ".lua"

	api.compile.file(src, dest, { verbose = true })

	if is_global then
		-- This makes it available for both the rest of init.lua
		-- AND the Fennel compiler's environment
		_G[name] = require("core.lib." .. name)
	end
end

-- Order matters here!
bootstrap_lib("shared", true) -- Compile shared.fnl -> set _G.shared
bootstrap_lib("tables", true) -- Compile tables.fnl -> set _G.tables (for deep-merge)
bootstrap_lib("fun", true) -- Compile fun.fnl    -> set _G.fun (for nth)

-- Now that the "Big Three" are in _G, compile the rest of the lib
local files = vim.fn.readdir(lib_path)
for _, filename in ipairs(files) do
	if filename:match("%.fnl$") then
		local name = filename:gsub("%.fnl$", "")
		if not _G[name] then -- Skip the ones we already bootstrapped
			api.compile.file(lib_path .. "/" .. filename, lua_dir .. "/core/lib/" .. name .. ".lua")
		end
	end
end

-- 5. Inject globals
-- Note: we use pcall here because core.lib.init might still be grumpy
local ok, lib = pcall(require, "core.lib")
if ok then
	_G.autoload = lib.autoload
	_G.setup = lib.setup
	_G.nth = lib.nth -- Add this!
else
	print("NYOOM: Warning - core.lib load failed, some globals may be missing")
end

-- Force compile the entry point specifically
api.compile.file(fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua", { verbose = true })
-- Set the macro path explicitly for the compiler
-- Safely set macro-path
local current_mpath = fennel["macro-path"] or ""
fennel["macro-path"] = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. current_mpath

-- 6. Explicitly Compile the "Big Three" and Directories
print("NYOOM: Compiling Core and Modules...")

-- A helper to catch specific file errors
local function safe_compile(src, dest)
	local ok, err = pcall(function()
		api.compile.file(src, dest, { verbose = true })
	end)
	if not ok then
		print("COMPILE ERROR [" .. src .. "]: " .. tostring(err))
	end
end

-- 1. Root Files
safe_compile(fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua")
safe_compile(fnl_dir .. "/modules.fnl", lua_dir .. "/modules.lua")
safe_compile(fnl_dir .. "/packages.fnl", lua_dir .. "/packages.lua")
safe_compile(fnl_dir .. "/config.fnl", lua_dir .. "/config.lua")

-- 2. The Core Entry Point (Crucial!)
safe_compile(fnl_dir .. "/core/init.fnl", lua_dir .. "/core/init.lua")

-- 3. The rest of the subdirectories (modules/*, etc)
api.compile.dir(fnl_dir, lua_dir, { recursive = true, verbose = true })

-- 7. HANDOFF
print("NYOOM: Attempting handoff to nyoom.lua")
local ok, err = pcall(require, "nyoom")
if not ok then
	print("NYOOM: Handoff failed!")
	print(err)
end
