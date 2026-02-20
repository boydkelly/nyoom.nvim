local module = "nvim-autopairs"
local ok, nvim_autopairs = pcall(require, module)
if not ok then
  vim.notify("Couldn't load module '" .. module .. "'", vim.log.levels.WARN)
  return
end
nvim_autopairs.setup()

-- will intefere with french quotes
local opts = {
  disable_filetype = { "asciidoctor", "asciidoc", "markdown", "norg" },
  enable_check_bracket_line = false, -- Don't add pairs if it already has a close pair in the same line
  ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
  check_ts = true, -- use treesitter to check for a pair.
  ts_config = {
    lua = { "string" }, -- it will not add pair on that treesitter node
    javascript = { "template_string" },
    java = false, -- don't check treesitter on java
  },
}
--add custom rules here
-- local rule = require "nvim-autopairs.rule"
-- local autopairs = require "nvim-autopairs"
-- autopairs.remove_rule '"'
-- -- basically works but cursor will remain before end quote
-- autopairs.add_rules {
--   rule('« ', ' »', { "asciidoc", "markdown" }),
--   rule('"', " »"):set_end_pair_length(2):replace_endpair(function()
--     return "<BS>«  »"
--   end),
-- }
