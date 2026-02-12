(import-macros {: lz-package! : vim-pack-spec! : lz-trigger-load!} :macros)

(lz-package! :nvim-lua/telescope.nvim
             {:nyoom-module completion.telescope
              :module :telescope
              :event :UIEnter
              :requires [(lz-trigger-load! :nvim-telescope/telescope-ui-select.nvim
                                           {:opt true})
                         (lz-trigger-load! :nvim-telescope/telescope-file-browser.nvim
                                           {:opt true})
                         (lz-trigger-load! :nvim-telescope/telescope-media-files.nvim
                                           {:opt true})
                         (lz-trigger-load! :nvim-telescope/telescope-project.nvim
                                           {:opt true})
                         (lz-trigger-load! :LukasPietzschmann/telescope-tabs
                                           {:opt true})
                         (lz-trigger-load! :jvgrootveld/telescope-zoxide
                                           {:opt true})]})

