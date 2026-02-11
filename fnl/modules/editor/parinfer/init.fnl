(import-macros {: lz-package! : vim-pack-spec!} :macros)

; (lz-package! :eraserhd/parinfer-rust
;              {:nyoom-module :editor.parinfer
;               :run ("cargo build --release")
;               :event :UIEnter
;               :enabled true})

(lz-package! :harrygallagher4/nvim-parinfer-rust
             {:nyoom-module editor.parinfer
              :enabled true
              :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})
