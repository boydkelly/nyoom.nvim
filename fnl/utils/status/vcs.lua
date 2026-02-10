local M = {}

function M.jj_bookmark_or_git_branch()
  local current_bufname = vim.api.nvim_buf_get_name(0)
  local cwd
  local branch = ""

  -- Determine a safe CWD (Current Working Directory)
  local is_virtual = vim.startswith(current_bufname, "oil://")
    or vim.startswith(current_bufname, "minipick://")
    or vim.startswith(current_bufname, "ministarter://")
    or vim.startswith(current_bufname, "minifiles://")

  if current_bufname ~= nil and current_bufname ~= "" and not is_virtual then
    -- It's a real file path, use its directory
    cwd = vim.fn.fnamemodify(current_bufname, ":p:h")
  else
    -- Fallback to the actual Neovim CWD for virtual buffers or no-name buffers
    cwd = vim.uv.cwd()
  end

  -- 1. Check for Jujutsu (.jj) repository
  if vim.fs.root(cwd, ".jj") then
    local result = vim
      .system({
        "jj",
        "log",
        "--ignore-working-copy",
        "-r",
        "@-",
        "-n",
        "1",
        "--no-graph",
        "--no-pager",
        "-T",
        "separate(' ', format_short_change_id(self.change_id()), self.bookmarks())",
      }, { text = true, cwd = cwd }) -- Execute in the determined 'cwd'
      :wait()
    branch = vim.trim(result.stdout or "")

  -- 2. Check for Git repository
  elseif vim.fs.root(cwd, ".git") then
    -- A. Try gitsigns/git branch
    branch = vim.g.gitsigns_head
      or vim.b.gitsigns_head
      or vim.trim(vim.system({ "git", "branch", "--show-current" }, { text = true, cwd = cwd }):wait().stdout or "")

    -- B. Check for DETACHED HEAD if the branch name is empty
    if branch == "" then
      local result = vim.system({ "git", "rev-parse", "--short", "HEAD" }, { text = true, cwd = cwd }):wait()
      local commit_id = vim.trim(result.stdout or "")

      -- If a short commit ID is returned, it means we are in a detached state.
      if commit_id ~= "" then
        branch = "[HEAD: " .. commit_id .. "]"
      end
    end
  end
  return branch
end

-- vim.api.nvim_create_autocmd("User", {
--   pattern = "GitSignsUpdate",
--   callback = function()
--     _cache_valid = false
--     vim.schedule(vim.cmd.redrawstatus)
--   end,
-- })

return M
