-- lua/utils/plugins.lua
-- lua/utils/plugins.lua
local M = {}

-- Set of essential plugins that should never be removed
local EXCLUDE = {
  ["lz.n"] = true,
  ["hotpot.nvim"] = true,
  ["tangerine.nvim"] = true,
  -- add more core plugins here if needed
}

-- Read and decode lockfile
local function read_lockfile(lock_file)
  if vim.fn.filereadable(lock_file) == 0 then
    return nil, "lockfile not found: " .. lock_file
  end
  local ok, contents = pcall(vim.fn.readfile, lock_file)
  if not ok then
    return nil, "failed to read lockfile: " .. lock_file
  end
  local ok2, data = pcall(vim.json.decode, table.concat(contents, "\n"))
  if not ok2 then
    return nil, "failed to decode lockfile json: " .. lock_file
  end
  return data
end

-- Convert manifest entries to set of plugin names
local function manifest_to_set(manifest)
  local set = {}
  for _, entry in ipairs(manifest or {}) do
    local name
    if type(entry) == "string" then
      name = entry:match ".*/(.*)"
    elseif type(entry) == "table" then
      if entry.name then
        name = entry.name
      elseif entry.src then
        name = entry.src:match ".*/(.*)"
      elseif entry[1] then
        name = entry[1]:match ".*/(.*)"
      end
    end
    if name then
      set[name] = true
    end
  end
  return set
end

local function backup_file(path)
  local ts = os.date "%Y%m%dT%H%M%S"
  local filename = vim.fn.fnamemodify(path, ":t")
  local dest = "/var/tmp/" .. filename .. ".bak." .. ts

  -- Use a system command to copy. It's faster and less prone to Lua path bugs.
  local cmd = string.format("cp '%s' '%s'", path, dest)
  local ret = os.execute(cmd)

  if ret == 0 or ret == true then
    -- Clean up the local mess while we're at it
    os.execute(string.format("rm -f %s/%s.bak.*", vim.fn.fnamemodify(path, ":h"), filename))
    return dest
  end

  return nil, "Failed to copy to /var/tmp"
end

-- Main function
function M.clean(opts)
  opts = opts or {}
  local dry = opts.dry
  if dry == nil then
    dry = true
  end
  local force = opts.force or false
  local do_backup = opts.backup
  if do_backup == nil then
    do_backup = true
  end

  -- 1) load manifest
  local ok, manifest_mod = pcall(require, "config.plugins")
  if not ok or not manifest_mod or type(manifest_mod.plugins) ~= "table" then
    vim.notify("cleanplugins: failed to load manifest at require('config.plugins').plugins", vim.log.levels.ERROR)
    return
  end
  local desired = manifest_to_set(manifest_mod.plugins)

  -- 2) lockfile path
  local lock_file = vim.fn.stdpath "config" .. "/nvim-pack-lock.json"
  local lock_data, err = read_lockfile(lock_file)
  if not lock_data then
    vim.notify("cleanplugins: " .. err, vim.log.levels.WARN)
    return
  end
  local installed = lock_data.plugins or {}

  -- 3) compute removals
  local to_remove = {}
  for name, _ in pairs(installed) do
    if not desired[name] and not EXCLUDE[name] then
      table.insert(to_remove, name)
    end
  end

  if #to_remove == 0 then
    vim.notify("cleanplugins: nothing to remove", vim.log.levels.INFO)
    return
  end

  -- 4) backup lockfile if requested
  if do_backup then
    local bak, berr = backup_file(lock_file)
    if bak then
      vim.notify("cleanplugins: lockfile backed up to " .. bak, vim.log.levels.DEBUG)
    else
      vim.notify("cleanplugins: backup failed: " .. tostring(berr), vim.log.levels.WARN)
    end
  end

  -- 5) dry-run report
  if dry and not force then
    local msg = { "cleanplugins (dry run) - plugins that would be removed:" }
    for _, name in ipairs(to_remove) do
      table.insert(msg, "  - " .. name)
    end
    vim.notify(table.concat(msg, "\n"), vim.log.levels.WARN)
    return to_remove
  end

  -- 6) actual deletion
  local removed = {}
  for _, name in ipairs(to_remove) do
    local ok_del, err_del = pcall(vim.pack.del, { name })
    if ok_del then
      table.insert(removed, name)
      vim.notify("cleanplugins: removed " .. name, vim.log.levels.INFO)
    else
      vim.notify("cleanplugins: failed to remove " .. name .. ": " .. tostring(err_del), vim.log.levels.ERROR)
    end
  end

  return removed
end

-- Convenience wrapper
function M.cmd(arg)
  local opts = {}
  if type(arg) == "table" then
    opts = arg
  elseif arg == true then
    opts.force = true
    opts.dry = false
  end
  return M.clean(opts)
end

return M
