local M = {}

function M.quit()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_windows = vim.call("win_findbuf", bufnr)
  local modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })
  if modified and #buf_windows == 1 then
    vim.ui.input({
      prompt = "You have unsaved changes. Quit anyway? (y/n) ",
    }, function(input)
      if input == "y" then
        vim.cmd "qa!"
      end
    end)
  else
    vim.cmd "qa!"
  end
end

M.safe_require = function(module_name)
  local status_ok, module = pcall(require, module_name)
  if not status_ok then
    vim.notify("Couldn't load module '" .. module_name .. "'")
    do
      return
    end
  end
  return module
end

-- could this be used in lualine?
function M.get_short_cwd()
  local parts = vim.split(vim.fn.getcwd(), "/")
  return parts[#parts]
end

-- When current buffer is a file, get its directory.
-- from nvim-lin
function M.buffer_dir()
  local bufnr = vim.api.nvim_get_current_buf()
  if type(bufnr) == "number" and bufnr > 0 then
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if type(bufname) == "string" and string.len(bufname) > 0 then
      local bufdir = vim.fn.fnamemodify(bufname, ":h")
      if type(bufdir) == "string" and string.len(bufdir) > 0 and vim.fn.isdirectory(bufdir) > 0 then
        return bufdir
      end
    end
  end

  return nil
end

function M.project_dir()
  local ok, projdir = pcall(function()
    return require("project").get_project_root()
  end)

  if ok and projdir and vim.fn.isdirectory(projdir) == 1 then
    vim.notify("Using project root: " .. projdir, vim.log.levels.INFO)
    return projdir
  else
    local cwd = vim.loop.cwd()
    vim.notify("No project root found. Falling back to current working directory: " .. cwd, vim.log.levels.WARN)
    return cwd
  end
end

M.notify = function(message, level, title)
  local notify_options = {
    title = title,
    timeout = 5000,
  }
  vim.schedule(function()
    vim.notify(message, level, notify_options)
  end)
end

M.Insert_uuid = function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local uuid = require "utils.uuid"()
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

M.cursor_pos = function()
  -- local original_cursor = vim.fn.winsaveview()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  print("line:", line)
  print("col:", col)
  print("col:", col + 7)
  vim.api.nvim_win_set_cursor(0, { line, 7 })
end

M.update_meta = function()
  -- We only can run this function if the file is modifiable
  if not vim.api.nvim_buf_option_value(vim.api.nvim_get_current_buf(), "modifiable") then
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

function M.spellcheck_enabled()
  return vim.o.spell
end

-- local function create_select_menu(prompt, options_table)
--   local option_names = {}
--   local n = 0
--   for i, _ in pairs(options_table) do
--     n = n + 1
--     option_names[n] = i
--   end
--   table.sort(option_names)
--
--   local menu = function()
--     vim.ui.select(option_names, {
--       prompt = prompt,
--       format_item = function(item)
--         return item:gsub("%d. ", "")
--       end,
--     }, function(choice)
--       local action = options_table[choice]
--       if action ~= nil then
--         if type(action) == "string" then
--           vim.cmd(action)
--         elseif type(action) == "function" then
--           action()
--         end
--       end
--     end)
--   end
--
--   return menu
-- end
--
-- local options = {
--   ["Search History"] = "FzfLua search_history",
--   ["Help Tags"] = "FzfLua help_tags",
--   ["Colorscheme"] = "FzfLuz colorscheme",
--   ["Buffers"] = "FzfLua buffers",
-- }
--
-- local search_menu = create_select_menu("Search feature to use:", options)
-- vim.keymap.set("n", "<leader>fa", search_menu, { noremap = true, silent = true })

-- from mini nvim
function M.Auto_split()
  if vim.api.nvim_win_get_width(0) > math.floor(vim.api.nvim_win_get_height(0) * 2.3) then
    vim.cmd "vs"
  else
    vim.cmd "split"
  end
end

-- from chatgpt
function M.Close_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and buf ~= current then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end

-- utils/messages_split.lua
function M.show_messages()
  -- Grab classic Vim messages
  local lines = vim.split(vim.api.nvim_exec("messages", true), "\n")
  if #lines == 0 then
    return
  end

  -- Create scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Open bottom split
  vim.cmd "botright split"
  local win = vim.api.nvim_get_current_win()

  -- Optional: fixed-ish height
  vim.api.nvim_win_set_height(win, math.min(#lines, 15))

  -- Attach buffer
  vim.api.nvim_win_set_buf(win, buf)

  -- Buffer options
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false

  -- Close mapping
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
end

-- function for editinng french-index text pages
function M.extract_column(col2_start, col3_start)
  -- prompt if needed
  if not col2_start then
    col2_start = tonumber(vim.fn.input "Column 2 start: ")
  end
  if not col3_start then
    col3_start = tonumber(vim.fn.input "Column 3 start: ")
  end

  local buf = vim.api.nvim_get_current_buf()
  local line_count = vim.api.nvim_buf_line_count(buf)

  local col2_text = {}
  local col3_text = {}

  for i = 0, line_count - 1 do
    local line = vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1] or ""
    local line_chars = vim.str_utfindex(line)

    -- column 2 slice
    local col2_start_safe = math.min(col2_start - 1, line_chars)
    local col2_end_safe = math.min(col3_start - 2, line_chars)
    local col2_slice = line:sub(vim.str_byteindex(line, col2_start_safe) + 1, vim.str_byteindex(line, col2_end_safe))
    table.insert(col2_text, col2_slice)

    -- column 3 slice
    local col3_start_safe = math.min(col3_start - 1, line_chars)
    local col3_slice = line:sub(vim.str_byteindex(line, col3_start_safe) + 1)
    table.insert(col3_text, col3_slice)

    -- replace original line with only column 1
    local col1_end_safe = math.max(0, math.min(col2_start - 2, line_chars))
    local col1_slice = line:sub(1, vim.str_byteindex(line, col1_end_safe) + 1)
    vim.api.nvim_buf_set_lines(buf, i, i + 1, false, { col1_slice })
  end

  -- append empty line at bottom
  vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { "" })
  local bottom_line = vim.api.nvim_buf_line_count(buf)

  -- paste column 2
  vim.api.nvim_buf_set_lines(buf, bottom_line, bottom_line, false, col2_text)
  -- paste column 3 below column 2
  vim.api.nvim_buf_set_lines(buf, bottom_line + #col2_text, bottom_line + #col2_text, false, col3_text)
end

-- keymap
vim.keymap.set("n", "<M-f>", function()
  M.extract_column()
end, { noremap = true, silent = true })

-- Process all pages listed in columns.csv

function M.process_all_pages(lang)
  local base = vim.fn.expand "~/dev/jula/index-francais/"
  local csv = base .. "/data/" .. lang .. "/columns.csv"
  local pages_dir = base .. "/build/" .. lang .. "/pages"
  local out_dir = base .. "/build/" .. lang .. "/processed"

  vim.fn.mkdir(out_dir, "p")

  local lines = vim.fn.readfile(csv)
  for _, entry in ipairs(lines) do
    if entry ~= "" then
      local page, c2, c3 = entry:match "([^,]+),([^,]+),([^,]+)"
      if page and c2 and c3 then
        local col2_start = tonumber(c2)
        local col3_start = tonumber(c3)

        local infile = pages_dir .. "/" .. page .. ".txt"
        local outfile = out_dir .. "/" .. page .. ".txt"

        -- create a scratch buffer
        local buf = vim.api.nvim_create_buf(false, true)
        -- load the page into it
        local file_lines = vim.fn.readfile(infile)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, file_lines)

        -- switch to that buffer
        vim.api.nvim_set_current_buf(buf)

        -- run the extraction
        M.extract_column(col2_start, col3_start)

        -- get the processed lines back
        local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        -- write to outfile
        vim.fn.writefile(new_lines, outfile)

        -- delete the scratch buffer
        vim.api.nvim_buf_delete(buf, { force = true })

        print("Processed: " .. page)
      end
    end
  end
end

function M.get_plugin_path(name)
  for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
    if path:match(name) then
      return path
    end
  end
  return nil
end

-- Function to open the current file from another branch in a vertical split
function M.open_branch_split(branch)
  branch = branch or "devold" -- Default branch
  local filepath = vim.fn.expand "%" -- Get current file path relative to git root

  if filepath == "" then
    print "No file open"
    return
  end

  -- 1. Create a vertical split
  vim.cmd "vsplit"
  -- 2. Switch to the new window
  vim.cmd "wincmd l"
  -- 3. Use 'git show' to dump the branch's version into the buffer
  -- We use 'edit' to create a scratch buffer, then 'read' the git output
  vim.cmd "enew" -- Open a new empty buffer
  vim.cmd "setlocal buftype=nofile bufhidden=hide noswapfile" -- Make it a scratch buffer
  vim.cmd("silent! read !git show " .. branch .. ":" .. filepath)
  vim.cmd "1delete _" -- Remove the initial empty line

  -- Optional: Set filetype for syntax highlighting
  local ft = vim.bo.filetype
  vim.cmd("setlocal filetype=" .. ft)
  print("Opened " .. filepath .. " from " .. branch)
end

-- Create a user command for it
vim.api.nvim_create_user_command("GitCompare", function(opts)
  M.open_branch_split(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

-- Keybinding: <leader>gc (Git Compare)
vim.keymap.set("n", "<leader>fb", ":GitCompare devold<CR>", { desc = "Compare current file with devold" })

return M
