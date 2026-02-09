(local {: setup} (require :core.lib.setup))
(setup :gitsigns
       {:signs {:add {:hl :diffAdded
                      :text "│"
                      :numhl :GitSignsAddNr
                      :linehl :GitSignsAddLn}
                :change {:hl :diffChanged
                         :text "│"
                         :numhl :GitSignsChangeNr
                         :linehl :GitSignsChangeLn}
                :delete {:hl :diffRemoved
                         :text ""
                         :numhl :GitSignsDeleteNr
                         :linehl :GitSignsDeleteLn}
                :changedelete {:hl :diffChanged
                               :text "‾"
                               :numhl :GitSignsChangeNr
                               :linehl :GitSignsChangeLn}
                :topdelete {:hl :diffRemoved
                            :text "~"
                            :numhl :GitSignsDeleteNr
                            :linehl :GitSignsDeleteLn}}})

; (fn []
;                         (autocmd! BufRead *
;                                   `(fn []
;                                      (vim.fn.system (.. "git -C "
;                                                         (vim.fn.expand "%:p:h")
;                                                         " rev-parse"))
;                                      (when (= vim.v.shell_error 0)
;                                        (vim.schedule (fn []
;                                                        ((. (require :packer)
;                                                            :loader) :gitsigns.nvim)))))))
