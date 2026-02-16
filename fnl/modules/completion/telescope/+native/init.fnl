(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

(lz-package! :nvim-telescope/telescope-fzf-native.nvim
             {:nyoom-module completion.telescope.+native
              :run :make
              :build-file :build/libfzf.so})

