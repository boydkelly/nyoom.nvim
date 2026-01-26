-- ========================================
-- Nyoom Tangerine Bootstrap (correct)
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

-- 1. bootstrap pack
vim.pack.add({
	{ src = "https://github.com/udayvir-singh/tangerine.nvim" },
})
vim.cmd.packadd("tangerine.nvim")

-- 2. compile fennel
local api = require("tangerine.api")

local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
local lua_dir = vim.fn.stdpath("config") .. "/.compiled"

-- Add compiled root so require("core.lib") resolves to compiled/core/lib/init.lua
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- helper to compile a single file
local function compile_file(src, out)
	api.compile.file(src, out, { verbose = true })
end

-- compile core/lib in dependency order
local core_lib = {
	"shared", -- needed by setup
	"fun", -- no deps
	"tables", -- no deps
	"init",
	"setup",
	"p",
	"profile",
	"io",
	"color",
	"autoload",
}

for _, f in ipairs(core_lib) do
	local src = fnl_dir .. "/core/lib/" .. f .. ".fnl"
	local out = lua_dir .. "/core/lib/" .. f .. ".lua"
	compile_file(src, out)
	-- update package.path so subsequent requires work
	package.path = lua_dir .. "/core/lib/?.lua;" .. lua_dir .. "/core/lib/?/init.lua;" .. package.path
end

-- 2. Compile the rest of fnl
api.compile.dir(fnl_dir, lua_dir, {
	clean = false,
	float = true,
	verbose = true,
})

-- 3. expose compiled modules to Lua
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path

-- 4. HANDOFF — stop here
-- require("init") -- <-- this is a Fennel module
