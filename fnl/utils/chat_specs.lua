local config_root = vim.fn.stdpath "config"
local source_dir = config_root .. "/lua/specs"
local dest_dir = config_root .. "/lua/lz_specs"
vim.fn.mkdir(dest_dir, "p")

local inspect = vim.inspect

-- local require_overrides = {
--   ["blink.cmp"] = "setup.blink",
--   ["nvim-colorizer.lua"] = "colorizer.setup()",
-- }

-- Strip "owner/" from plugin[1] if it's a string like "owner/plugin.nvim"
local function shorten_name(plugin)
  if type(plugin[1]) == "string" then
    local short = plugin[1]:match "[^/]+$"
    if short then
      plugin[1] = short
    end
  end
end

-- Rewrites config = function → after = function
-- Ignores init and opts functions

local function flatten_plugin(plugin)
  local result = {}
  local main = vim.deepcopy(plugin)
  local deps = main.dependencies or {}
  main.dependencies = nil

  shorten_name(main)
  main.init = nil -- DROP init unconditionally, no processing

  -- Rename event "VeryLazy" to "UiEnter"
  if main.event == "VeryLazy" then
    main.event = "UiEnter"
  elseif type(main.event) == "table" then
    for i, ev in ipairs(main.event) do
      if ev == "VeryLazy" then
        main.event[i] = "UiEnter"
      end
    end
  end

  -- Helper function to assign after function based on plugin name

  local function make_after_fn(short_name)
    if short_name:match "^mini%." then
      local mini_fn = short_name:match "^mini%.(.+)"
      return function()
        require("setup")["mini_" .. mini_fn]()
      end
    else
      return function()
        require("setup." .. short_name)
      end
    end
  end

  local short_name = tostring(main[1]):gsub("%.nvim$", "")

  if type(plugin.config) == "function" then
    main.after = make_after_fn(short_name)
    main.config = nil
  end

  if type(plugin.opts) == "function" then
    main.after = make_after_fn(short_name)
    main.opts = nil
  end

  table.insert(result, { entry = main, is_dep = false })

  for _, dep in ipairs(deps) do
    if type(dep) == "string" then
      dep = { dep }
    elseif type(dep) ~= "table" then
      goto continue
    end
    shorten_name(dep)

    -- Rename event in dependencies as well
    if dep.event == "VeryLazy" then
      dep.event = "UiEnter"
    elseif type(dep.event) == "table" then
      for i, ev in ipairs(dep.event) do
        if ev == "VeryLazy" then
          dep.event[i] = "UiEnter"
        end
      end
    end

    dep.config = nil
    dep.opts = nil
    table.insert(result, { entry = dep, is_dep = true })
    ::continue::
  end

  return result
end

-- Custom writer to preserve real Lua functions
local require_overrides = {
  ["blink.cmp"] = "setup.blink",
  ["nvim-colorizer.lua"] = 'require("colorizer").setup()',
}

-- Custom writer to preserve real Lua functions and handle require overrides
local function write_plugin(f, plugin)
  local require_overrides = {
    ["blink.cmp"] = "setup.blink",
    ["nvim-colorizer.lua"] = 'require("colorizer").setup()',
  }

  if plugin.is_dep then
    f:write "  -- from dependencies\n"
  end

  f:write "  {\n"
  for k, v in pairs(plugin.entry) do
    if k == 1 then
      f:write(string.format('    "%s",\n', v))
    elseif type(v) == "function" and (k == "after" or k == "before") then
      local plugin_name = plugin.entry[1]
      local short_name = tostring(plugin_name):gsub("%.nvim$", "")

      local override = require_overrides[plugin_name]
      if override then
        if override:match "^require%(.+%)%.setup%(%)*%)$" then
          -- Full require call, e.g. require("colorizer").setup()
          f:write(string.format(
            [[
    %s = function()
      %s
    end,
]],
            k,
            override
          ))
        else
          -- Simple require override
          f:write(string.format(
            [[
    %s = function()
      require("%s")
    end,
]],
            k,
            override
          ))
        end
      elseif short_name:match "^mini%." then
        local mini_fn = short_name:match "^mini%.(.+)"
        f:write(string.format(
          [[
    %s = function()
      require("setup").mini_%s()
    end,
]],
          k,
          mini_fn
        ))
      else
        f:write(string.format(
          [[
    %s = function()
      require("setup.%s")
    end,
]],
          k,
          short_name:lower()
        ))
      end
    else
      f:write(string.format("    %s = %s,\n", k, vim.inspect(v)))
    end
  end
  f:write "  },\n"
end

-- Convert one file
local function convert_file(src, dst)
  local chunk = loadfile(src)
  if not chunk then
    vim.notify("Could not load " .. src, vim.log.levels.ERROR)
    return
  end

  local ok, spec = pcall(chunk)
  if not ok then
    vim.notify("Error evaluating " .. src .. ": " .. spec, vim.log.levels.ERROR)
    return
  end

  local plugins = {}
  if vim.tbl_islist(spec) then
    for _, item in ipairs(spec) do
      if type(item) == "table" then
        vim.list_extend(plugins, flatten_plugin(item))
      end
    end
  elseif type(spec) == "table" then
    vim.list_extend(plugins, flatten_plugin(spec))
  end

  local f = io.open(dst, "w")
  if not f then
    vim.notify("Failed to write to " .. dst, vim.log.levels.ERROR)
    return
  end

  f:write "return {\n"
  for _, plugin in ipairs(plugins) do
    write_plugin(f, plugin)
  end
  f:write "}\n"
  f:close()
end

-- Run over all spec files
for _, src in ipairs(vim.fn.glob(source_dir .. "/*.lua", true, true)) do
  local dst = dest_dir .. "/" .. vim.fn.fnamemodify(src, ":t")
  convert_file(src, dst)
end

vim.notify "Plugin specs converted to lz_specs/"
