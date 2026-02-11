(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :nvim-telescope/telescope-fzf-native.nvim
             {:fake-module completion.telescope.+native
              :opt true
              :run :make
              :build-file :build/libfzf.so})
