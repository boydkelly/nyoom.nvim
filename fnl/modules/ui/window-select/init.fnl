(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :s1n7ax/nvim-window-picker {:after ui.window-select
                                          :keys :<space>w})
