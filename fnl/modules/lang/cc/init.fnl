(import-macros {: use-package!} :macros)

(use-package! :p00f/clangd_extensions.nvim
              {:after lang.cc :ft [:c :cpp]})
