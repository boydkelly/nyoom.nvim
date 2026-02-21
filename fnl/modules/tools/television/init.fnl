(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :alexpasmantier/tv.nvim {:nyoom-module tools.television
                                      :beforeAll :modules.tools.television.keybinds
                                      :cmd [:Tv]
                                      :keys [{1 :<leader>sma 2 "<cmd>Tv mandenkan-all<cr>" :desc "Mandenkan all"}
                                             {1 :<leader>smc
                                              2 "<cmd>Tv mandenkan-cours<cr>"
                                              :desc "Mandenkan cours"}
                                             {1 :<leader>smd 2 "<cmd>Tv mandenkan-dico<cr>" :desc "Mandenkan dico"}
                                             {1 :<leader>smp 2 "<cmd>Tv mandenkan-docs<cr>" :desc "Mandenkan docs"}
                                             {1 :<leader>smw 2 "<cmd>Tv mandenkan-wt<cr>" :desc "Mandenkan wt"}
                                             {1 :<leader>fd
                                              2 (fn []
                                                  (vim.cmd.Tv :dotfiles))
                                              :desc :Dotfiles}
                                             {1 :<leader>fc
                                              2 (fn []
                                                  (vim.cmd.Tv :neovim))
                                              :desc "Neovim files"}
                                             {1 :<leader>st
                                              2 (fn []
                                                  (vim.cmd.Tv :text))
                                              :desc "Grep Text"}
                                             {1 :<leader>su
                                              2 (fn []
                                                  (vim.cmd.Tv :unicode))
                                              :desc "Insert Unicode"}]
                                      :lazy true})
