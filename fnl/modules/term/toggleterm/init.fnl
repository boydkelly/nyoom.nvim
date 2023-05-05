(import-macros {: use-package!} :macros)

(use-package! :akinsho/toggleterm.nvim {:cmd :toggleterm
                                        :keys :"C-n"
                                        :call-setup toggleterm})
