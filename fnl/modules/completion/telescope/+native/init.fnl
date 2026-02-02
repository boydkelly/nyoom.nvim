(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :nvim-telescope/telescope-fzf-native.nvim
  {:opt true :run :make
   :build-file :build/libfzf.so})
