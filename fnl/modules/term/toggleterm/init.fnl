(import-macros {: use-package!} :macros)

(use-package! :akinsho/toggleterm.nvim
              {:cmd [:ToggleTerm :TermExec]
              :keys [:n :<C-\\> :<Cmd>ToggleTerm<Cr>]
              :call-setup toggleterm
              }
)
