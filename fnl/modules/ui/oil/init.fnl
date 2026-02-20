(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

(lz-package! :stevearc/oil.nvim
             {:nyoom-module ui.oil
              :enabled true
              :event :DeferredUIEnter
              :keys [{1 "-"
                      2 (fn []
                          (_G.toggle_oil_split))
                      :desc "Toggle Oil"}
                     {1 :<leader>fe
                      2 (fn []
                          (_G.toggle_oil_split))
                      :desc "Toggle Oil"}]})
