local M = {}

function M.dump_leader_to_buffer()
  local mappings = vim.api.nvim_get_keymap "n"
  local lines = { "Leader Keymaps:", "----------------" }

  for _, m in ipairs(mappings) do
    -- We check for both literal "<leader>" and the actual leader key (usually space or \)
    local leader = vim.g.mapleader or "\\"
    if m.desc and (m.lhs:find "<leader>" or m.lhs:find(leader)) then
      table.insert(lines, string.format("%-10s | %s", m.lhs, m.desc))
    end
  end

  -- Create a new buffer
  local bufnr = vim.api.nvim_create_buf(false, true) -- (not listed, scratch buffer)

  -- Set the lines in the buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Open the buffer in a new vertical split
  vim.api.nvim_open_win(bufnr, true, { split = "right" })

  -- Optional: Set filetype to markdown for nice highlighting
  vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
end

M.dump_leader_to_buffer()

return M
