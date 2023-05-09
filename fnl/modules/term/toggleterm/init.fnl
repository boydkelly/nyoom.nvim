(import-macros {: use-package!} :macros)

(use-package! :akinsho/toggleterm.nvim {:cmd :toggleterm
                                        :keys [:<C-\>]
                                        :call-setup toggleterm})
