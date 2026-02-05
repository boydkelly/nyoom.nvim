--- ### UI toggle functions.
-- heavily modified from normal nvim

--    Functions:
--      -> change_number
--      -> toggle_autoformat
--      -> toggle_autopairs
--      -> toggle_background
--      -> toggle_buffer_autoformat
--      -> toggle_buffer_semantic_tokens
--      -> toggle_buffer_syntax
--      -> toggle_buffer_inlay_hints
--      -> toggle_coverage_signs
--      -> toggle_conceal
--      -> toggle_diagnostics
--      -> toggle_scrollbind
--      -> toggle_lsp_signature
--      -> toggle_spell
--      -> toggle_statusline
--      -> toggle_url_effect
--      -> toggle_wrap

local utils = require "utils.base"

local M = {}

local function bool2str(bool)
  return bool and "on" or "off"
end

--- Change the number display modes
function M.change_number()
  local number = vim.wo.number -- local to window
  local relativenumber = vim.wo.relativenumber -- local to window
  if not number and not relativenumber then
    vim.wo.number = true
  elseif number and not relativenumber then
    vim.wo.relativenumber = true
  elseif number and relativenumber then
    vim.wo.number = false
  else -- not number and relativenumber
    vim.wo.relativenumber = false
  end
  utils.notify(string.format("number %s, relativenumber %s", bool2str(vim.wo.number), bool2str(vim.wo.relativenumber)))
end

--- Toggle auto format
function M.toggle_global_format()
  -- vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  utils.notify(string.format("Global autoformatting %s", bool2str(vim.g.disable_autoformat)))
end

function M.toggle_buffer_format()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify("Buffer autoformat: " .. (vim.b.disable_autoformat and "disabled" or "enabled"))
end

--- Toggle autopairs
function M.toggle_autopairs()
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
    else
      autopairs.disable()
    end
    vim.g.autopairs_enabled = autopairs.state.disabled
    utils.notify(string.format("autopairs %s", bool2str(not autopairs.state.disabled)))
  else
    utils.notify "autopairs not available"
  end
end

function M.toggle_minipairs()
  if vim.b.minipairs_disable then
    vim.b.minipairs_disable = false
    utils.notify "Mini.pairs: ENABLED"
  else
    vim.b.minipairs_disable = true
    utils.notify "Mini.pairs: DISABLED"
  end
end

--- Toggle background="dark"|"light"
function M.toggle_background()
  vim.go.background = vim.go.background == "light" and "dark" or "light"
  utils.notify(string.format("background=%s", vim.go.background))
end

--- Toggle buffer semantic token highlighting for all language servers that support it
--@param bufnr? number the buffer to toggle the clients on
function M.toggle_buffer_semantic_tokens(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].semantic_tokens_enabled = not vim.b[bufnr].semantic_tokens_enabled
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens_enabled and "start" or "stop"](bufnr, client.id)
      utils.notify(string.format("Buffer lsp semantic highlighting %s", bool2str(vim.b[bufnr].semantic_tokens_enabled)))
    end
  end
end

function M.toggle_buffer_syntax(bufnr)
  bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
  -- Check if Treesitter is currently active for this buffer
  local is_ts_active = vim.treesitter.highlighter.active[bufnr] ~= nil
  local ft = vim.bo[bufnr].filetype

  if vim.bo[bufnr].syntax == "off" and not is_ts_active then
    -- ENABLE SYNTAX
    -- 1. Check if it's in your allowed TS list
    if ts_fts_set[ft] then
      local lang = vim.treesitter.language.get_lang(ft) or ft
      vim.treesitter.start(bufnr, lang)
    end
    -- 2. Fallback/Concurrent vim regex syntax
    vim.bo[bufnr].syntax = "on"
    if not vim.b.semantic_tokens_enabled then
      M.toggle_buffer_semantic_tokens(bufnr, true)
    end
    utils.notify "Syntax highlighting: ON"
  else
    -- DISABLE SYNTAX
    if is_ts_active then
      vim.treesitter.stop(bufnr)
    end
    vim.bo[bufnr].syntax = "off"
    if vim.b.semantic_tokens_enabled then
      M.toggle_buffer_semantic_tokens(bufnr, true)
    end
    utils.notify "Syntax highlighting: OFF"
  end
end

--- Toggle conceal=2|0
function M.toggle_conceal()
  vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
  utils.notify(string.format("conceal %s", bool2str(vim.opt.conceallevel:get() == 2)))
end

--- Toggle LSP inlay hints (buffer)
-- @param bufnr? number the buffer to toggle the clients on
function M.toggle_buffer_inlay_hints(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].inlay_hints_enabled = not vim.b[bufnr].inlay_hints_enabled
  vim.lsp.inlay_hint.enable(vim.b[bufnr].inlay_hints_enabled, { bufnr = bufnr })
  utils.notify(string.format("Buffer inlay hints %s", bool2str(vim.b[bufnr].inlay_hints_enabled)))
end

--- Toggle lsp signature
function M.toggle_lsp_signature()
  local state = require("lsp_signature").toggle_float_win()
  utils.notify(string.format("lsp signature %s", bool2str(state)))
end

--- Toggle spell
function M.toggle_spell()
  vim.wo.spell = not vim.wo.spell -- local to window
  utils.notify(string.format("spell %s", bool2str(vim.wo.spell)))
end

--- Toggle laststatus=3|2|0
function M.toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = "local"
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = "global"
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = "off"
  end
  utils.notify(string.format("statusline %s", status))
end

-- function M.toggle_url_effect()
--   vim.g.url_effect_enabled = not vim.g.url_effect_enabled
--   require("base.utils").set_url_effect()
--   utils.notify(string.format("URL effect %s", bool2str(vim.g.url_effect_enabled)))
-- end

--- Toggle wrap
function M.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap -- local to window
  utils.notify(string.format("wrap %s", bool2str(vim.wo.wrap)))
end

-- bk stuff

M.ToggleRelativeNumber = function()
  vim.opt.relativenumber = not (vim.opt.relativenumber:get())
end

M.ToggleNumber = function()
  vim.opt.number = not (vim.opt.number:get())
end

function M.toggle_diagnostics()
  -- Initialize buffer flag if not set
  if vim.b._diagnostics_disabled == nil then
    vim.b._diagnostics_disabled = false
  end

  -- Toggle
  if vim.b._diagnostics_disabled then
    vim.diagnostic.enable(true)
    vim.b._diagnostics_disabled = false
    print "Diagnostics enabled for this buffer"
  else
    vim.diagnostic.disable(true)
    vim.b._diagnostics_disabled = true
    print "Diagnostics disabled for this buffer"
  end
end

vim.api.nvim_create_user_command("ToggleDiagnostics", M.toggle_diagnostics, {
  desc = "Toggle diagnostics for the current buffer",
})

-- gemmini
function M.toggle_scrollbind()
  local window_ids = vim.api.nvim_list_wins()
  if #window_ids ~= 2 then
    return
  end
  local current_scrollbind = vim.api.nvim_get_option_value("scrollbind", { win = window_ids[1] })
  local new_scrollbind_state = not current_scrollbind
  for _, win_id in ipairs(window_ids) do
    vim.api.nvim_set_option_value("scrollbind", new_scrollbind_state, { win = win_id })
    vim.api.nvim_echo({ { "Scrollbind " .. (new_scrollbind_state and "enabled" or "disabled"), "Normal" } }, false, {})
  end
end

return M
