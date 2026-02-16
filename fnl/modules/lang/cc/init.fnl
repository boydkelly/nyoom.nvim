(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :p00f/clangd_extensions.nvim
              {:nyoom-module lang.cc :ft [:c :cpp]})
