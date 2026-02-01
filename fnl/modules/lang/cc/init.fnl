(import-macros {: lz-package! : vim-pack-spec!} :macros)

(use-package! :p00f/clangd_extensions.nvim
              {:after lang.cc :ft [:c :cpp]})
