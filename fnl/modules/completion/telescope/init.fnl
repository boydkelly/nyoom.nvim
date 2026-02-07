(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

(lz-package! :nvim-lua/telescope.nvim
             {:nyoom-module completion.telescope
              :module [:telescope]
              :event :UIEnter
              :requires [(lz-pack! :nvim-telescope/telescope-ui-select.nvim
                                   {:opt true})
                         (lz-pack! :nvim-telescope/telescope-file-browser.nvim
                                   {:opt true})
                         (lz-pack! :nvim-telescope/telescope-media-files.nvim
                                   {:opt true})
                         (lz-pack! :nvim-telescope/telescope-project.nvim
                                   {:opt true})
                         (lz-pack! :LukasPietzschmann/telescope-tabs
                                   {:opt true})
                         (lz-pack! :jvgrootveld/telescope-zoxide {:opt true})]})

