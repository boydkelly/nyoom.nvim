(local {: setup} (require :core.lib.setup))
(local opts {:datapath :/home/bkelly/.local/share/nvim
             :disable_on {:bt [:help :nofile :terminal]
                          :ft [""
                               :nvim-pack
                               :oil
                               :log
                               :TelescopePrompt
                               :TelescopeResults
                               :alpha
                               :checkhealth
                               :lazy
                               :notify
                               :packer
                               :qf]}
             :lsp {:enabled true}
             :manual_mode false
             :patterns [:.git :.jj :go.mod :=content :=translate :=search]
             :silent_chdir false
             :telescope {:disable_file_picker false}})

(setup :project opts)
