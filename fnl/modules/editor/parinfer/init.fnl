(import-macros {: lz-package! : vim-pack-spec!} :macros)

; (lz-package! :eraserhd/parinfer-rust
;              {:nyoom-module :editor.parinfer
;               :run ("cargo build --release")
;               :event :UIEnter
;               :enabled true})
;; not sue how to deal with this;; not a fake-module
; (lz-package! :eraserhd/parinfer-rust {:nyoom-module :editor.parinfer :run "cargo build --release"})

(lz-package! :harrygallagher4/nvim-parinfer-rust
             {:nyoom-module editor.parinfer
              :enabled true
              :cmd :ParinferToggle
              :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})
