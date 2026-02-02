(local {: setup} (require :core.lib.setup))

(setup :ibl
       {:exclude {:buftypes [:terminal]
                  :filetypes [:help
                              :terminal
                              :alpha
                              :packer
                              :lspinfo
                              :TelescopePrompt
                              :TelescopeResults
                              :mason
                              ""]}
        ;; If show_start failed here, we remove it. 
        ;; The default for indent in v3 is usually to NOT show the first level anyway.
        :indent {:char "│"} 
        :scope {:enabled true
                :show_start true}
        :whitespace {:remove_blankline_trail true}})
