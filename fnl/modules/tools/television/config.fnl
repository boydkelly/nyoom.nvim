(import-macros {: map! : packadd! } :macros)
(local {: setup} (require :core.lib.setup))
(packadd! :tv.nvim)
(local h (. (require :tv) :handlers))

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
