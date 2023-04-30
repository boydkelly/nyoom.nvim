local cmd = vim.cmd
local fn = vim.fn

local M = {}

M.notify = function(message, level, title)
  local notify_options = {
    title = title,
    timeout = 5000,
  }
  vim.api.nvim_notify(message, level, notify_options)
end

-- check if a variable is not empty nor nil
M.isNotEmpty = function(s)
  return s ~= nil and s ~= ""
end

--- Check if path exists
M.path_exists = function(path)
  local ok = vim.loop.fs_stat(path)
  return ok
end

-- Return telescope files command
M.telescope_find_files = function()
  local path = vim.loop.cwd() .. "/.git"
  if M.path_exists(path) then
    return "Telescope git_files"
  else
    return "Telescope find_files"
  end
end

-- toggle quickfixlist
M.toggle_qf = function()
  local windows = fn.getwininfo()
  local qf_exists = false
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    cmd "cclose"
    return
  end
  if M.isNotEmpty(fn.getqflist()) then
    cmd "copen"
  end
end

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

function M.map(mode, l, r, opts)
  opts = opts or {}
  vim.keymap.set(mode, l, r, opts)
end

function M.get_buf_option(opt)
  local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
  if not status_ok then
    return nil
  else
    return buf_option
  end
end

function M.is_empty(s)
  return s == nil or s == ""
end

M.prose = function()
  vim.cmd [[call Ventilated()]] -- OneSentencePerLine
  --   "set background=light
  --
  --   "search in folds doesnt work but defaults include search
  -- vim.bo.fdo:append('search')

  --  "allow cut virtual block mode colonm
  vim.wo.virtualedit = "block"

  --  "make an indent to show wrap
  --  "prevent vim from inserting line breaks in newly entered text
  --  "disable a bunch of formatoptions
  vim.bo.textwidth = 0
  vim.bo.wrapmargin = 0
  vim.wo.wrap = 1 --soft wrap lines
  vim.wo.linebreak = 1 --break only on word boundries
  vim.o.whichwrap = "b,s,<,>,[,]" -- "cursor wrap at line begining and end
  vim.wo.showbreak = "»"
  vim.wo.breakindent = 1
  vim.wo.breakindentopt = "min:20,shift:2,sbr"
  --  "call pencil#init()

  --  "lists completion in asciidoc via comments feature
  --  fix vim.bo.comments = '://,b:#,:%,:XCOMM,b:-,b:*,b:.,:\|'

  --  " Show tabs and trailing characters.
  --  "set listchars=tab:»·,trail:·,eol:¬
  --  "yeah but do we actually need to format lists in asciidoc with vim?
  vim.wo.listchars = "tab:> ,trail:-,nbsp:+"
  -- vim.wo.listchars = "eol:* ,tab:> ,trail:· ,nbsp:+"
  vim.o.list = true

  vim.bo.formatoptions = "tcqr"
  -- " tc text, comments; (almost) no effect while textwidth=0, but will format
  -- " with gq formatexp
  -- " q enables gq to manually format (with formatexp)
  -- " r automatically insert comment after <Enter> (exactly what we need for
  -- " lists and tables)

  -- " NOT USED BELOW
  -- " o not good puts comment on insert
  -- " n not needed formats numbered list.  we let asciidc do the final
  -- " formatting
  -- " j remove comment leader when joining lines.  this is a default with a
  -- " wierd effect for us as you can't compete a list properly
  -- "
  vim.bo.smartindent = 1 -- " copies indent from previous line

  vim.o.formatlistpat = "\\s*" -- Optional leading whitespace
  vim.opt.formatlistpat:append "[" -- Start character class
  vim.opt.formatlistpat:append "\\[({]\\?" -- |  Optionally match opening punctuation
  vim.opt.formatlistpat:append "\\(" -- |  Start group
  vim.opt.formatlistpat:append "[0-9]\\+" -- |  |  Numbers
  vim.opt.formatlistpat:append "\\|" -- or
  vim.opt.formatlistpat:append "[a-zA-Z]\\+" -- |  |  Letters
  vim.opt.formatlistpat:append "\\)" -- |  End groupop
  vim.opt.formatlistpat:append "[\\]:.)}" -- |  Closing punctuation
  vim.opt.formatlistpat:append "]" -- End character class
  vim.opt.formatlistpat:append "\\s\\+" -- One or more spaces
  vim.opt.formatlistpat:append "\\|" -- or
  vim.opt.formatlistpat:append "^\\s*[-–+o*•]\\s\\+" -- Bullet points
end

M.toggleGuillemets = function()
  -- require("nvim-autopairs").disable()
  vim.cmd [[
  if mapcheck('"', "i") == ""
  imap <expr> " getline('.')[col('.')-2]=~'\S' ? ' »' : '« '
 "   imap <expr> ' getline('.')[col('.')-2]=~'\S' ? ' »' : '« '
  "    iunmap '
  echo "Mapped guillemets"
  else
    iunmap "
    echo "Mapped quotes"
  endif
]]
end

M.mapGuillemets = function()
  -- need mapcheck and also disable autopairs
  vim.keymap.set("i", '"', function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local leftchar = vim.api.nvim_buf_get_text(0, row - 1, col - 2, row - 1, col - 1, { nil })
    print(table.unpack(leftchar))

    if table.unpack(leftchar):match "%S" then
      return " »"
    else
      return "« "
    end
  end, { expr = true, replace_keycodes = true })
end

M.toggleBar = function()
  -- local function bartoggle()
  -- if vim.api.nvim_get_option("ruler") == false then
  --   vim.o.ruler = true
  -- else
  --   vim.o.ruler = false
  -- end

  vim.cmd [[
  if &laststatus
  set noruler
  set laststatus=0
  else
  set ruler
  set laststatus=3
  endif
]]
end

M.translate = function()
  vim.o.scrollbind = true
  vim.o.splitright = true
  cmd [[bn]]
  vim.o.scrollbind = true
  vim.cmd [[bp]]
  vim.cmd [[colorscheme default]]
end

-- This don't work
-- OneSentencePerLine = function()
--   vim.cmd([[
--   if mode() =~# '^[iR]'
--     return
--   endif
--   let start = v:lnum
--   let end = start + v:count - 1
--   execute start.','.end.'join'
--   s/[;.!?]\zs\s*\ze\S/\r/g
-- ]])
-- end
--
-- vim.bo.formatexpr = require('functions').oneSentencePerLine()
-- this doesn't work yet. I'm waiting...
function M.asciidoctable()
  vim.cmd [[execute "'<,'>s/   */|/g"]]
  vim.cmd [[execute "'<,'>s/^/|/g"]]
  vim.cmd [[execute "'<,'>s/^||/|/g"]]
  vim.cmd [[call append(line("'<")-1, '[width="100%",cols="2",frame="topbot",options="header",stripes="even"]')]]
  vim.cmd [[call append(line("'<")-1, '|===')]]
  vim.cmd [[call append(line("'>"), '|===')]]
  vim.cmd [["execute a:firstline . "," . a:lastline . "s/   */|/g"]]
  vim.cmd [["execute "'<,'>s/(^)[^|]/\1/g"]]
end

-- used by luasnip and Insert_uuid function
function M.Generate_uuid()
  local u = require "uuid"
  return u()
end

M.Insert_uuid = function()
  -- Get row and column cursor,
  -- use unpack because it's a tuple.
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local uuid = M.Generate_uuid()
  -- local uuid = M.test_uuid()
  -- Notice the uuid is given as an array parameter, you can pass multiple strings.
  -- The firs 4 params are for start and end of row and columns.
  -- See earlier docs for param clarification or `:help nvim_buf_set_text`.
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end
vim.keymap.set("i", "<M-u>", M.Insert_uuid, { noremap = true, silent = true })

local preserve = function(arguments)
  local args = string.format("keepjumps keeppatterns execute %q", arguments)
  -- local original_cursor = vim.fn.winsaveview()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_command(args)
  local lastline = vim.fn.line "$"
  -- vim.fn.winrestview(original_cursor)
  if line > lastline then
    line = lastline
  end
  print("line:", line)
  print("col:", col)
  vim.api.nvim_win_set_cursor(0, { line, col })
end

M.update_meta = function()
  -- We only can run this function if the file is modifiable
  if not vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "modifiable") then
    return
  end
  if vim.fn.line "$" >= 7 then
    os.setlocale "en_US.UTF-8"
    -- time = os.date("%a, %d %b %Y %H:%M")
    local time = os.date "%Y-%m-%d"
    preserve("sil! keepp keepj 1,20s/\\vlast_edited_date:\\zs.*/ " .. time .. "/ei")
    preserve("sil! keepp keepj 1,20s/\\vrev-date:\\zs.*/ " .. time .. "/ei")
  end
end

M.toggle_lines = function()
  require("lsp_lines").toggle()
end

function M.enable_virtual_text()
  vim.diagnostic.config { virtual_text = true }
  vim.diagnostic.config { virtual_lines = false }
  -- vim.diagnostic.config { float = false }
end

local virtual_text_active = false

function M.show_virtual_text()
  return virtual_text_active
end

function M.toggle_virtual_text()
  virtual_text_active = not virtual_text_active
  if virtual_text_active then
    vim.diagnostic.config { virtual_text = true }
  else
    vim.diagnostic.config { virtual_text = false }
  end
end

local float_active = false

function M.show_float()
  return float_active
end

function M.toggle_float()
  float_active = not float_active
  if float_active then
    vim.diagnostic.config { float = true }
  else
    vim.diagnostic.config { float = false }
  end
end

return M
