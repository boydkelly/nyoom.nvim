vim.opt.keymap = "dyu"
vim.opt.spell = true
-- :imap <expr> " getline('.')[col('.')-2]=~'\S' ?  ' »' : '« '
-- ":imap <expr> ' getline('.')[col('.')-2]=~'\S' ?  ' »' : '« '
require("nvim-autopairs").remove_rule('"') -- remove rule "
require("utils.functions").toggleGuillemets()
vim.opt.background = "dark"
