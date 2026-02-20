(import-macros {: map! : packadd! } :macros)
(packadd! :tv.nvim)
(local h (. (require :tv) :handlers))

(map! [n] :<leader>sma "<cmd>Tv mandenkan-all<cr>" {:desc "Mandenkan all"})
(map! [n] :<leader>smc "<cmd>Tv mandenkan-cours<cr>" {:desc "Mandenkan cours"})
(map! [n] :<leader>smd "<cmd>Tv mandenkan-dico<cr>" {:desc "Mandenkan dico"})
(map! [n] :<leader>smp "<cmd>Tv mandenkan-docs<cr>" {:desc "Mandenkan docs"})
(map! [n] :<leader>smw "<cmd>Tv mandenkan-wt<cr>" {:desc "Mandenkan wt"})

(map! [n] :<leader>fd (fn [] (vim.cmd.Tv :dotfiles)) {:desc "Dotfiles"})
(map! [n] :<leader>fc (fn [] (vim.cmd.Tv :neovim)) {:desc "Neovim files"})
(map! [n] :<leader>st (fn [] (vim.cmd.Tv :text)) {:desc "Grep Text"})
(map! [n] :<leader>su (fn [] (vim.cmd.Tv :unicode)) {:desc "Insert Unicode"})
