local M = {}
local ENABLE_LSP_PROGRESS = true

local lsp_progress_active = false
local shade_frame = 1

local mode_info = {
  n = { label = "●", hl = "StatusNormal" }, -- **Normal** mode: The default, command-centric mode. (Alternative: "" or "")
  no = { label = "●", hl = "StatusNormal" }, -- **Normal-operator pending** mode: After an operator (like `d` for delete), waiting for a motion.
  i = { label = "■", hl = "StatusInsert" }, -- **Insert** mode: For typing text directly into the buffer.
  ic = { label = "■", hl = "StatusInsert" }, -- **Insert Completion** mode: Insert mode with completion pop-up active.
  v = { label = "▤", hl = "StatusVisual" }, -- **Visual** mode (character-wise): Selecting text character by character.
  V = { label = "▤", hl = "StatusVisual" }, -- **Visual Line** mode: Selecting text line by line.
  ["\22"] = { label = "▥", hl = "StatusVisual" }, -- **Visual Block** mode: Selecting a rectangular block of text. (Ctrl-V)
  s = { label = "■", hl = "StatusVisual" }, -- **Select** mode (character-wise): Similar to Visual, but typing replaces selection.
  S = { label = "■", hl = "StatusVisual" }, -- **Select Line** mode: Similar to Visual Line, but typing replaces selection.
  ["\19"] = { label = "", hl = "StatusVisual" }, -- **Select Block** mode: Similar to Visual Block, but typing replaces selection. (Ctrl-S)
  c = { label = "▶", hl = "StatusCommand" }, -- **Command-line** mode: For entering Ex commands (`:`), search commands (`/` or `?`), etc.
  cv = { label = "▶", hl = "StatusCommand" }, -- **Vim Ex** mode: Similar to Command-line, but specifically for Ex commands.
  ce = { label = "▶", hl = "StatusCommand" }, -- **Ex-editing** mode: Editing an Ex command on the command line.
  R = { label = "⇄", hl = "StatusReplace" },
  Rv = { label = "⇄", hl = "StatusReplace" },
  r = { label = "⇄", hl = "StatusReplace" },
  rm = { label = "⇄", hl = "StatusReplace" },
  ["r?"] = { label = "﹖", hl = "StatusCommand" }, -- **Prompt/Question during Replace**: A specific state where a prompt is shown within a replace-like context.
  ["!"] = { label = ">", hl = "StatusTerminal" }, -- **Terminal** mode (Job running): Interactive terminal buffer.
  t = { label = ">", hl = "StatusTerminal" }, -- **Terminal** mode: Another representation for the terminal buffer.
}

local shade_frames = {
  "░░░░",
  "▒░░░",
  "▓▒░░",
  "▓▓▒░",
  "▓▓▓▒",
  "▓▓▓▓",
  "▒▓▓▓",
  "░▒▓▓",
  "░░▒▓",
  "░░░▒",
}

local function hl(group, text)
  return string.format("%%#%s#%s", group, text)
end

local function get_shade()
  local mode = vim.api.nvim_get_mode().mode
  local hl_group = (mode_info[mode] and mode_info[mode].hl) or "StatusLine"
  --  local shade = lsp_progress_active and (frames[shade_frame] or "░░░") or "░▒▓"
  --  local shade = lsp_progress_active and (frames[shade_frame] or "░░░░") or "▓▒░ "
  -- If disabled, always show the static shade.
  if not ENABLE_LSP_PROGRESS then
    return hl(hl_group, "▓▒░ ")
  end

  local shade = lsp_progress_active and (shade_frames[shade_frame] or "░░░░") or "▓▒░ "

  return hl(hl_group, shade)
end

-- Safe default highlights for statusline (link or define)
-- vim.cmd [[
--     hi! link StatusNormal        DiagnosticInfo
--     hi! link StatusInsert        DiagnosticError
--     hi! link StatusReplace        DiagnosticHint
--     hi! link StatusCommand        DiagnosticOk
--     hi! link StatusVisual        DiagnosticWarn
--     hi! link StatusTerminal        IncSearch
--     hi! link StatusGit           StatusLine
--     hi! link StatusGitDiff       StatusLine
--     hi! link StatusDiagnosticError StatusLine
--     hi! link StatusDiagnosticWarn  StatusLine
--     hi! link StatusFiletype      StatusLine
--   ]]

local function get_filetype()
  local filetype = vim.bo.filetype
  local disabled = {
    DressingSelect = true,
    TelescopePrompt = true,
    TelescopeResults = true,
    lazy = true,
    minipick = true,
    ministarter = true,
    ["neo-tree"] = true,
  }
  if filetype == "" or disabled[filetype] then
    return ""
  end

  local icon, iconhl
  local ok, micons = pcall(require, "mini.icons")

  if ok and micons.get then
    icon, iconhl = micons.get("filetype", filetype)
    return " " .. hl(iconhl, icon) .. hl("StatusFiletype", " " .. filetype)
  else
    return hl("StatusFiletype", "[" .. filetype .. "]")
  end
end

local function get_encoding()
  local encoding = vim.bo.fileencoding -- Get the buffer's file encoding

  if encoding == "utf-8" then
    return ""
  end

  -- Return the encoding, potentially with highlighting
  -- Using a custom highlight group like "StatusEncoding" is good practice.
  return hl("StatusEncoding", " " .. encoding)
end

local function get_mode()
  local mode = vim.api.nvim_get_mode().mode
  local entry = mode_info[mode] or { label = "??", hl = "StatusLine" }
  --   return hl(entry.hl, " " .. entry.label .. " ░▒▓")
  return hl(entry.hl, " " .. entry.label .. " ░▒▓") .. "%*"
end

local function get_git_repo()
  local handle = io.popen "git rev-parse --show-toplevel 2> /dev/null"
  local result = handle:read("*a"):gsub("\n", "")
  handle:close()
  if result ~= "" then
    --     return hl("StatusGit", " " .. result:match "^.+/(.+)$")
    return hl("StatusGit", " " .. result:match "^.+/(.+)$") .. "%*"
  end
  return ""
end
local function get_git_branch()
  local handle = io.popen "git rev-parse --abbrev-ref HEAD 2>/dev/null"
  local result = handle:read("*a"):gsub("\n", "")
  handle:close()
  if result ~= "" then
    --    return hl("StatusGit", " Ξ " .. result)
    return hl("StatusGit", " Ξ " .. result) .. "%*"
  end
  return ""
end

local function get_git_diff()
  local filename = vim.fn.expand "%"
  if filename == "" or vim.fn.filereadable(filename) == 0 then
    return ""
  end
  local handle = io.popen("git diff --numstat -- " .. vim.fn.shellescape(filename) .. " 2>/dev/null")
  if not handle then
    return ""
  end

  local added, removed, changed = 0, 0, 0
  for line in handle:lines() do
    local a, d = line:match "^(%d+)%s+(%d+)"

    if a and d then
      a, d = tonumber(a), tonumber(d)
      if a and d then -- <-- extra check here
        if a > 0 and d > 0 then
          local min = math.min(a, d)
          changed = changed + min
          added = added + (a - min)
          removed = removed + (d - min)
        else
          added = added + a
          removed = removed + d
        end
      end
    end
  end
  handle:close()

  local parts = {}
  if added > 0 then
    -- table.insert(parts, hl("DiffAdded", "α " .. added))
    table.insert(parts, hl("DiffAdded", "+" .. added))
  end
  if changed > 0 then
    table.insert(parts, hl("DiffChanged", "~" .. changed))
  end
  if removed > 0 then
    table.insert(parts, hl("DiffRemoved", "-" .. removed))
  end

  return #parts > 0 and (" " .. table.concat(parts, " ")) or ""
end

local function get_fileinfo()
  local filename = vim.fn.expand "%:t"
  if filename == "" then
    return ""
  end
  return hl("StatusLine", " " .. filename)
end

local function get_lsp_diagnostic()
  if not next(vim.lsp.get_clients { bufnr = 0 }) then
    return ""
  end

  local function sev_count(s)
    return #vim.diagnostic.get(0, { severity = s })
  end
  local result = {
    errors = sev_count(vim.diagnostic.severity.ERROR),
    warnings = sev_count(vim.diagnostic.severity.WARN),
  }

  local parts = {}
  if result.warnings > 0 then
    table.insert(parts, hl("DiagnosticWarn", tostring(result.warnings)))
  end
  if result.errors > 0 then
    table.insert(parts, hl("DiagnosticError", tostring(result.errors)))
  end
  return #parts > 0 and (" " .. table.concat(parts, " ") .. " ") or ""
end

local function get_location()
  if vim.v.hlsearch == 0 then
    return hl("StatusLine", "%l:%c ")
  end

  local ok, count = pcall(vim.fn.searchcount, { recompute = true })
  if not ok or count.total == 0 or count.current == nil then
    return ""
  end

  local total = (count.total > count.maxcount and (">" .. count.maxcount)) or count.total
  return hl("StatusLine", " " .. total .. " matches ")
end

local function get_keymap()
  if vim.opt.iminsert:get() > 0 and vim.b.keymap_name then
    -- return hl("StatusLine", " ⌨️ " .. vim.b.keymap_name)
    return hl("StatusLine", "[" .. vim.b.keymap_name .. "]")
  end
  return ""
end

Statusline = {}

Statusline = function()
  return table.concat {
    -- Mode with its color highlight
    -- color(),
    -- string.format(" %s ", (modes[vim.api.nvim_get_mode().mode] or "--")),

    -- Git info (default color)
    get_mode(),
    get_git_repo(),
    get_git_branch(),

    -- File info and diff
    get_fileinfo(),

    get_git_diff(),
    "%=",

    -- Diagnostics (colored fg), separator
    get_lsp_diagnostic(),

    -- Filetype
    get_filetype(),
    get_encoding(),
    -- Search + keymap + encoding
    get_keymap(),
    hl("Statusline", " %B "),
    get_location(), -- including location
    get_shade(),
  }
end

if ENABLE_LSP_PROGRESS then
  local shade_timer = vim.loop.new_timer()
  shade_timer:start(
    0,
    250,
    vim.schedule_wrap(function()
      if lsp_progress_active then
        shade_frame = (shade_frame % #shade_frames) + 1
        vim.cmd.redrawstatus()
      end
    end)
  )
end

local debounce_timer = vim.loop.new_timer()

local function pulse()
  if not ENABLE_LSP_PROGRESS then
    return
  end -- Guard against calling pulse when disabled

  lsp_progress_active = true
  debounce_timer:stop()
  debounce_timer:start(2000, 0, function()
    lsp_progress_active = false
    vim.schedule(function()
      vim.cmd.redrawstatus()
    end)
  end)
  vim.cmd.redrawstatus()
end

M.pulse = pulse
-- Only create the autocmd if the feature is enabled
if ENABLE_LSP_PROGRESS then
  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function()
      M.pulse()
    end,
  })
end

vim.opt.cmdheight = 0
vim.opt.statusline = "%!v:lua.Statusline()"

return M
