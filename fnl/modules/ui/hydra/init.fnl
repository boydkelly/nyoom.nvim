(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :anuvyklack/hydra.nvim
              {:nyoom-module ui.hydra
               :module :hydra
               :keys [:<leader>g
                      :<leader>v
                      :<leader>f
                      :<leader>d
                      :<leader>m
                      :<leader>t]})
