(import-macros {: lz-package! : vim-pack-spec!} :macros)


;; not sue how to deal with this;; not a fake-module
; (lz-package! :eraserhd/parinfer-rust {:nyoom-module :editor.parinfer :run "cargo build --release"})

(lz-package! :harrygallagher4/nvim-parinfer-rust
              {:nyoom-module editor.parinfer
               :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})
