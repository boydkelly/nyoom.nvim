(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :p00f/clangd_extensions.nvim
              {:nyoom-module lang.cc :ft [:c :cpp]})
