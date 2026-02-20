(import-macros {: map! : packadd! } :macros)
(local {: setup} (require :core.lib.setup))
(packadd! :tv.nvim)
(local h (. (require :tv) :handlers))

(map! [n] :<leader>s
      :m {:name "Mandenkan"}
      :ma ["<cmd>Tv mandenkan-all<cr>" "Mandenkan all"]
      :mc ["<cmd>Tv mandenkan-cours<cr>" "Mandenkan cours"]
      :md ["<cmd>Tv mandenkan-dico<cr>" "Mandenkan dico"]
      :mp ["<cmd>Tv mandenkan-docs<cr>" "Mandenkan docs"]
      :mw ["<cmd>Tv mandenkan-wt<cr>" "Mandenkan wt"]
      :t [(fn [] (vim.cmd.Tv :text)) "Grep Text"]
      :u [(fn [] (vim.cmd.Tv :unicode)) "Insert Unicode"])

(map! [n] :<leader>f
      :d [(fn [] (vim.cmd.Tv :dotfiles)) "Dotfiles"]
      :c [(fn [] (vim.cmd.Tv :neovim)) "Neovim files"])

(local opts {:channels {:args [:--input-border=none]
                        :dotfiles {:handlers {:<C-q> h.send_to_quickfix
                                              :<C-s> h.open_in_split
                                              :<C-v> h.open_in_vsplit
                                              :<C-y> h.copy_to_clipboard
                                              :<CR> h.open_as_files}}
                        :files {:handlers {:<C-q> h.send_to_quickfix
                                           :<C-s> h.open_in_split
                                           :<C-v> h.open_in_vsplit
                                           :<C-y> h.copy_to_clipboard
                                           :<CR> h.open_as_files}}
                        :mandenkan-all {:handlers {:<C-s> h.open_in_split
                                                   :<C-v> h.open_in_vsplit
                                                   :<CR> h.open_at_line}
                                        :window {:height 1 :width 1}}
                        :mandenkan-cours {:handlers {:<C-s> h.open_in_split
                                                     :<C-v> h.open_in_vsplit
                                                     :<CR> h.open_at_line}
                                          :window {:height 1 :width 1}}
                        :mandenkan-dics {:handlers {:<C-s> h.open_in_split
                                                    :<C-v> h.open_in_vsplit
                                                    :<CR> h.open_at_line}
                                         :window {:height 1 :width 1}}
                        :mandenkan-docs {:handlers {:<C-s> h.open_in_split
                                                    :<C-v> h.open_in_vsplit
                                                    :<CR> h.open_at_line}
                                         :window {:height 1 :width 1}}
                        :mandenkan-wt {:handlers {:<C-s> h.open_in_split
                                                  :<C-v> h.open_in_vsplit
                                                  :<CR> h.open_at_line}
                                       :window {:height 1 :width 1}}
                        :nvim {:handlers {:<C-q> h.send_to_quickfix
                                          :<C-s> h.open_in_split
                                          :<C-v> h.open_in_vsplit
                                          :<C-y> h.copy_to_clipboard
                                          :<CR> h.open_as_files}}
                        :text {:handlers {:<C-q> h.send_to_quickfix
                                          :<C-s> h.open_in_split
                                          :<C-v> h.open_in_vsplit
                                          :<C-y> h.copy_to_clipboard
                                          :<CR> h.open_at_line}}
                        :unicode {:handlers {:<C-y> h.copy_to_clipboard
                                             :<CR> h.insert_at_cursor}}}
             :window {:border :none
                      :height 0.8
                      :title " tv.nvim "
                      :title_pos :center
                      :width 0.8}})

(setup :tv opts)
