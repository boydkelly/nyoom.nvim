-- ========================================
-- 1. Plugin Management (Bootstrap)
-- ========================================

-- ========================================
-- 2. Tangerine & Fennel Configuration
-- ========================================

-- Set up paths and move to config root for 'include' resolution
-- vim.cmd.cd(vim.fn.stdpath("config"))
local fnl_dir = vim.fn.stdpath("config") .. "/fnl"
local lua_dir = vim.fn.stdpath("config") .. "/lua"

-- 1. Check native Lua first (Fastest)
local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	else
		return false
	end
end

local dev = false
local core_exists = file_exists(lua_dir .. "/core/init.lua")

-- 2. Only check environment variables if we aren't sure yet
if not core_exists or dev or os.getenv("NYOOM_CLI") == "true" then
	vim.pack.add({
		{ src = "https://github.com/nvim-neorocks/lz.n" },
		{ src = "https://github.com/udayvir-singh/tangerine.nvim" },
	})

	vim.cmd.packadd("tangerine.nvim")

	local api = require("tangerine.api")
	local fennel = require("tangerine.fennel")
	fennel["allowed-globals"] = nyoom_globals

	fennel.path = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/?/init.fnl;" .. (fennel.path or "")
	fennel["macro-path"] = fnl_dir .. "/?.fnl;" .. fnl_dir .. "/macros-macros/?.fnl;" .. (fennel["macro-path"] or "")
	package.path = lua_dir .. "/?.lua;" .. lua_dir .. "/?/init.lua;" .. package.path
	--
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

	-- ========================================
	-- 4. Core Library Bootstrapping
	-- ========================================

	-- Compiles and requires libraries immediately for use in the bootstrap phase

	local function bootstrap_corelib(name)
		local src = fnl_dir .. "/core/lib/" .. name .. ".fnl"
		local dest = lua_dir .. "/core/lib/" .. name .. ".lua"

		-- 1. Compile SILENTLY. Verbosity is a startup killer.
		api.compile.file(src, dest, { force = false, verbose = false })

		-- 2. Only nil out if we are actually in a RESTART/RELOAD flow.
		-- For standard startup, let the Lua cache do its job.
		local ok, module = pcall(require, "core.lib." .. name)
		if not ok then
			error("Failed: " .. tostring(module))
		end
		return module
	end

	-- Compile macros first so core libs can use them
	safe_compile_dir(fnl_dir .. "/macros", lua_dir .. "/macros")

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

	-- Only these specific keys will be injected into _G
	local runtime_globals = {
		shared = true,
		tables = true,
		fun = true,
		crypt = true,
		p_lib = true,
	}

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

	-- Establish global aliases from loaded libs
	_G["echo!"] = loaded_libs.io["echo!"]
	_G["err!"] = loaded_libs.io["err!"]
	_G.nth = _G.fun.nth
	_G.deep_merge = _G.tables.deep_merge

	-- ========================================
	-- 5. Main Logic Compilation
	-- ========================================
	local core_base = {
		{ fnl_dir .. "/core/init.fnl", lua_dir .. "/core/init.lua" },
		{ fnl_dir .. "/core/repl.fnl", lua_dir .. "/core/repl.lua" },
		{ fnl_dir .. "/core/doctor.fnl", lua_dir .. "/health.lua" },
		{ fnl_dir .. "/nyoom.fnl", lua_dir .. "/nyoom.lua" },
		{ fnl_dir .. "/modules.fnl", lua_dir .. "/modules.lua" },
		{ fnl_dir .. "/config.fnl", lua_dir .. "/config.lua" },
		{ fnl_dir .. "/packages.fnl", lua_dir .. "/packages.lua" },
	}

	local modules = {
		{ fnl_dir .. "/after/lsp", lua_dir .. "/after/lsp" },
		{ fnl_dir .. "/modules", lua_dir .. "/modules" },
	}

	-- Execute batch compilation
	for _, pair in ipairs(core_base) do
		safe_compile_file(pair[1], pair[2])
	end

	for _, pair in ipairs(modules) do
		safe_compile_dir(pair[1], pair[2])
	end
end
-- ========================================
-- 6. Handoff to Main Entrypoint
-- ========================================
vim.cmd.packadd("lz.n") -- for now
local ok, err = pcall(require, "nyoom")
if not ok then
	print("NYOOM: Handoff failed!")
	print(err)
end
