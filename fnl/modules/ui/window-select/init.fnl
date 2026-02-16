(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :s1n7ax/nvim-window-picker {:nyoom-module ui.window-select
                                         :enabled true
                                         :keys :<space>w})
