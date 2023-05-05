(import-macros {: use-package!} :macros)

(use-package! :akinsho/toggleterm.nvim 
              {:cmd [:ToggleTerm :TermExec]
              :key [["<C-\\>"] {1 :<leader>z0 2 :<Cmd>2ToggleTerm<Cr> :desc "Terminal #2"}]
              })
