(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :guns/vim-sexp
              {:ft [:fennel :clojure :lisp :racket :scheme :janet :guile]
               :config (tset vim.g :sexp_filetypes
                             "clojure,scheme,lisp,timl,fennel,janet,hy")
               :requires [(pack :tpope/vim-sexp-mappings-for-regular-people
                                {:after :vim-sexp})]})
