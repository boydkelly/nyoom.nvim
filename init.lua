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

local api = require("tangerine.api")

-- paths
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
local lua_dir = vim.fn.stdpath("config") .. "/.compiled"

-- compiled Lua first in package.path
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path
-- allow raw fennel require for macros etc
package.path = fnl_dir .. "/?.fnl;" .. package.path

-- helper to compile a single file
local function compile_file(src, out)
	api.compile.file(src, out, { verbose = true })
end

-- compile core/lib in dependency order
local core_lib = {
	"shared", -- needed by setup
	"fun", -- no deps
	"tables", -- no deps
	"setup",
	"p",
	"profile",
	"io",
	"color",
	"autoload",
	"init", -- compile init last
}

for _, f in ipairs(core_lib) do
	local src = fnl_dir .. "/core/lib/" .. f .. ".fnl"
	local out = lua_dir .. "/core/lib/" .. f .. ".lua"
	compile_file(src, out)
end

-- compile root init.fnl
compile_file(fnl_dir .. "/init.fnl", lua_dir .. "/init.lua")

-- compile the rest (modules, packages, config)
api.compile.dir(fnl_dir, lua_dir, {
	clean = false,
	float = false,
	verbose = false,
})

-- Hotpot-style global helpers (intentional)
local autoload_mod = require("core.lib.autoload")
local setup_mod = require("core.lib.setup")

_G.autoload = autoload_mod.autoload or autoload_mod
_G.setup = setup_mod

-- 2. expose compiled modules to Lua
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- 3. DEBUG — confirm files
print("NYOOM: .compiled contents:")
local handle = vim.loop.fs_scandir(lua_dir)
while handle do
	local name = vim.loop.fs_scandir_next(handle)
	if not name then
		break
	end
	print("  ", name)
end

-- 4. HANDOFF — load Nyoom Fennel runtime
print("NYOOM: Requiring init.lua (compiled from init.fnl)")
require("init")
