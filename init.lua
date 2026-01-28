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

-- Add this before you call api.compile.dir
-- This tells the compiler "Don't worry, these will exist at runtime"
fennel["allowed-globals"] = { "vim", "autoload", "setup", "_G" }

-- This tells the Fennel COMPILER where to look for macros.fnl and other deps
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
-- 2. Define our clean Lua target
local lua_dir = vim.fn.stdpath("config") .. "/lua"
require("tangerine.fennel").path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl"

-- 3. Update Neovim's package.path (LUA ONLY)
-- We remove the .fnl entry to stop the ')' expected error
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- 4. Compile the core libs first so we can use them in _G
local lib_path = fnl_dir .. "/core/lib"
local files = vim.fn.readdir(lib_path)

-- 2. Compile every .fnl file in that directory first
for _, filename in ipairs(files) do
	if filename:match("%.fnl$") then
		local name = filename:gsub("%.fnl$", "")
		api.compile.file(lib_path .. "/" .. filename, lua_dir .. "/core/lib/" .. name .. ".lua", { verbose = true })
	end
end

-- 3. NOW it is safe to inject globals because the whole lib is there
_G.autoload = require("core.lib.autoload").autoload
_G.setup = require("core.lib.setup").setup
-- Add any other common Nyoom globals here if they appear
_G.shared = require("core.lib.shared")

-- Force compile the entry point specifically
api.compile.file(fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua", { verbose = true })
-- Set the macro path explicitly for the compiler
-- Safely set macro-path
local current_mpath = fennel["macro-path"] or ""
fennel["macro-path"] = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. current_mpath

-- 6. Compile everything else with error tracking
print("NYOOM: Starting full compilation...")

-- Explicitly compile the root files first to ensure they exist
local root_fnl_files = { "nyoom", "packages", "modules", "config" }
for _, f in ipairs(root_fnl_files) do
	local src = fnl_dir .. "/" .. f .. ".fnl"
	local out = lua_dir .. "/" .. f .. ".lua"
	if vim.loop.fs_stat(src) then
		api.compile.file(src, out, { verbose = true })
	end
end

-- Now compile all subdirectories (modules, core, etc.)
api.compile.dir(fnl_dir, lua_dir, {
	recursive = true,
	verbose = true,
})

-- 7. HANDOFF
print("NYOOM: Attempting handoff to nyoom.lua")
local ok, err = pcall(require, "nyoom")
if not ok then
	print("NYOOM: Handoff failed!")
	print(err)
end
