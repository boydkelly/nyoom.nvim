(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :anuvyklack/hydra.nvim
              {:nyoom-module ui.hydra
               :module :hydra
               :keys [:<leader>g
                      :<leader>v
                      :<leader>f
                      :<leader>d
                      :<leader>m
                      :<leader>t]})
