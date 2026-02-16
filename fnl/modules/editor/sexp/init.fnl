(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)
;; hack work around; nyoom-modul requires a config
(vim-pack-spec! :guns/vim-sexp)
(lz-package! :guns/vim-sexp
             {:module: :sexp :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]
              :requires [(lz-trigger-load :tpope/vim-sexp-mappings-for-regular-people
                                          {:after :vim-sexp})]})
