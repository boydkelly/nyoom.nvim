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
-- require("nvim-autopairs").get_rule('"')
require("nvim-autopairs").setup()

-- vim.cmd([[ iunmap " ]])
