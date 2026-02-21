vim.deprecate = function() end
local dev = true
local data_path = vim.fn.stdpath("data")
local config_path = vim.fn.stdpath("config")
local tangerine_path = data_path .. "/site/pack/core/opt/tangerine.nvim"
local oxocarbon_path = data_path .. "/site/pack/core/opt/oxocarbon.nvim"
local lz_path = data_path .. "/site/pack/core/opt/lz.n"

local bootstrap_ok = vim.uv.fs_stat(tangerine_path) and vim.uv.fs_stat(lz_path) and vim.uv.fs_stat(oxocarbon_path)
--
if not bootstrap_ok then
	-- either install or make user run install script.
	vim.pack.add({
		{ src = "https://github.com/nvim-neorocks/lz.n" },
		{ src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
		{ src = "https://github.com/udayvir-singh/tangerine.nvim" },
	})
	dev = true -- to force package install below
	-- or
	-- vim.api.nvim_err_writeln("\nError: Core Dependencies Unavailable\nPlease install with: bin/nyoom install\n")
	--
	--     return vim.cmd("qall!")
end
vim.cmd.packadd("lz.n")
vim.cmd.packadd("tangerine.nvim")

-- vim.cmd.cd(vim.fn.stdpath("config"))
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
local lua_dir = vim.fn.stdpath("config") .. "/.nyoom"

local core_exists = vim.uv.fs_stat(lua_dir .. "/core/init.lua")

vim.cmd.packadd("tangerine.nvim")

local api = require("tangerine.api")
local fennel = require("tangerine.fennel")

fennel.path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. (fennel.path or "")
package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path
fennel.macro_path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. (fennel.macro_path or "")
fennel["allowed-globals"] = nil
fennel["compiler-env"] = _G

if not core_exists or dev or os.getenv("NYOOM_CLI") == "true" then
	--
	local function safe_compile_file(src, dest)
		local ok, err = pcall(function()
			api.compile.file(src, dest, { force = false, verbose = false })
		end)
		if not ok then
			print("COMPILE ERROR [" .. src .. "]: " .. tostring(err))
		end
	end

	local function safe_compile_dir(src, dest)
		local ok, err = pcall(function()
			api.compile.dir(src, dest, { force = false, verbose = false })
		end)
		if not ok then
			print("COMPILE ERROR [" .. src .. "]: " .. tostring(err))
		end
	end

	local function bootstrap_corelib(name)
		-- print(name)
		local src = fnl_dir .. "/core/lib/" .. name .. ".fnl"
		local dest = lua_dir .. "/core/lib/" .. name .. ".lua"

		api.compile.file(src, dest, { force = false, verbose = false })

		local ok, module = pcall(require, "core.lib." .. name)
		if not ok then
			error("Failed: " .. tostring(module))
		end
		return module
	end

	_G.nyoom = {}

	-- Manifest defines the load order and global mapping
	local core_manifest = {
		{ "shared", "shared" },
		{ "tables", "tables" },
		{ "fun", "fun" },
		{ "crypt", "crypt" },
		{ "autoload", "autoload" },
		{ "p_lib", "p" },
		{ "setup", "setup" },
		{ "profile", "profile" },
		{ "io", "io" },
		{ "color", "color" },
		{ "init", "init" },
	}

	local runtime_globals = { shared = true, autoload = true, setup = true }

	local loaded_libs = {}

	for _, entry in ipairs(core_manifest) do
		local key = entry[1]
		local file = entry[2]
		local module = bootstrap_corelib(file)
		loaded_libs[key] = module
		if runtime_globals[key] then
			_G[key] = module
		end
	end

	local stdlib = require("core.lib")
	for k, v in pairs(stdlib) do
		rawset(_G, k, v)
	end

	local core_base = {
		{ fnl_dir .. "/core/init.fnl", lua_dir .. "/core/init.lua" },
		{ fnl_dir .. "/core/repl.fnl", lua_dir .. "/core/repl.lua" },
		{ fnl_dir .. "/core/doctor.fnl", lua_dir .. "/health.lua" },
		{ fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua" },
		{ fnl_dir .. "/config.fnl", lua_dir .. "/config.lua" },
		{ fnl_dir .. "/packages.fnl", lua_dir .. "/packages.lua" },
	}

	for _, pair in ipairs(core_base) do
		safe_compile_file(pair[1], pair[2])
	end

	safe_compile_dir(fnl_dir .. "/lsp", config_path .. "/after/lsp")
end

local ok, err = pcall(require, "nyoom")
if not ok then
	print("NYOOM: Fennel handoff failed!")
	print(err)
end
