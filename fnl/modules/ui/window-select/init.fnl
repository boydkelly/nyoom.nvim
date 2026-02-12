(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :s1n7ax/nvim-window-picker {:nyoom-module ui.window-select
                                         :enabled true
                                         :keys :<space>w})
