(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

(lz-package! :nvim-lua/telescope.nvim
             {:nyoom-module completion.telescope
              :module [:telescope]
              :cmd :Telescope
              :requires [:nvim-telescope/telescope-ui-select.nvim
                         :nvim-telescope/telescope-file-browser.nvim
                         :nvim-telescope/telescope-media-files.nvim
                         :nvim-telescope/telescope-project.nvim
                         :LukasPietzschmann/telescope-tabs
                         :jvgrootveld/telescope-zoxide]})

