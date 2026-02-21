-- ~/.config/nvim/plugin/export_colors.lua

local EXPORT_DIR = vim.fn.stdpath "config" .. "/colorschemes"

local M = {}

local function color(value)
  if type(value) == "number" then
    return string.format("%q", string.format("#%06x", value))
  elseif type(value) == "boolean" then
    return tostring(value)
  elseif value == nil then
    return "nil"
  else
    return string.format("%q", tostring(value))
  end
end

function M.export_colorscheme(name)
  -- Clear highlights and reapply colorscheme
  vim.cmd "highlight clear"
  vim.cmd "syntax reset"
  if name then
    pcall(vim.cmd, "colorscheme " .. name)
  end

  local ok, highlights = pcall(vim.api.nvim_get_hl, 0, {})
  if not ok then
    vim.notify("nvim_get_hl failed", vim.log.levels.ERROR)
    return
  end

  local output = { "return {" }
  local groups = {}

  for group, attrs in pairs(highlights) do
    local keys, parts = {}, {}
    for k in pairs(attrs) do
      table.insert(keys, k)
    end
    table.sort(keys)

    for _, k in ipairs(keys) do
      local v = attrs[k]
      if k ~= "cterm" or type(v) ~= "table" then
        table.insert(parts, string.format("%s = %s", k, color(v)))
      end
    end

    table.insert(groups, string.format("  [%q] = { %s },", group, table.concat(parts, ", ")))
  end

  table.sort(groups)
  vim.list_extend(output, groups)
  table.insert(output, "}")

  vim.fn.mkdir(EXPORT_DIR, "p")
  local filepath = string.format("%s/%s.lua", EXPORT_DIR, name)
  local file = assert(io.open(filepath, "w"))
  file:write(table.concat(output, "\n"))
  file:close()

  vim.notify("Exported colorscheme to " .. filepath, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("ExportColors", function(opts)
  local name = vim.g.colors_name or "colorscheme_export"
  M.export_colorscheme(name)
end, {
  nargs = "?",
  desc = "Export current colorscheme to " .. EXPORT_DIR,
})

return M
