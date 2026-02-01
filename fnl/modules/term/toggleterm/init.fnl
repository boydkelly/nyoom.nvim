(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :akinsho/toggleterm.nvim {:cmd :ToggleTerm
                                       :call-setup toggleterm})
