(import-macros {: lz-package! : build-pack-table : build-before-all-hook : vim-pack! } :macros)

(vim-pack! :eraserhd/parinfer-rust)

;; not sue how to deal with this;; not a nyoom-module
; (lz-package! :eraserhd/parinfer-rust {:nyoom-module :editor.parinfer :run "cargo build --release"})

(lz-package! :harrygallagher4/nvim-parinfer-rust
             {:nyoom-module editor.parinfer
              :enabled true
              :cmd :ParinferToggle
              :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})
