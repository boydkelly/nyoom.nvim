(local {: setup} (require :core.lib.setup))
(local opts {:disable_on {:bt [:help :nofile :terminal]
                          :ft [""
                               :nvim-pack
                               :oil
                               :log
                               :TelescopePrompt
                               :TelescopeResults
                               :alpha
                               :checkhealth
                               :notify
                               :qf]}
             :lsp {:enabled true}
             :manual_mode false
             :patterns [:.git :.jj]
             :silent_chdir true
             :telescope {:disable_file_picker false}})

(setup :project opts)
