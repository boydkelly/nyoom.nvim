-- vim.opt.spelllang = "en,tech"
vim.g.languagetool_lang = "en_CA"
vim.opt.keymap = ""
vim.opt.background = "dark"

vim.cmd([[
  if mapcheck('"', "i") != "" 
    iunmap "
    echo "Mapped quotes"
  endif
]])
-- only the first line should be uncommented in nyoom once nvim-autopairs is sorted out
-- require("nvim-autopairs").setup()
-- require("nvim-autopairs").get_rule('"')

-- vim.cmd([[ iunmap " ]])
