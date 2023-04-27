vim.opt.keymap = "fr"
vim.opt.spell = true
vim.g.languagetool_lang = "fr_FR"
require("nvim-autopairs").remove_rule('"') -- remove rule (
require("utils.functions").toggleGuillemets()

-- works ok but would need to type the non breaking space or use arrow key to continue typing
-- local function guillements()
--   local rule = require("nvim-autopairs.rule")
--   local autopairs = require("nvim-autopairs")
--
--   autopairs.add_rules({
--     -- rule("« ", " »", { "asciidoc", "markdown" }),
--     rule('"', " »"):set_end_pair_length(2):replace_endpair(function()
--       return "<BS>«  »"
--     end),
--   })
-- end
--
-- guillements()
