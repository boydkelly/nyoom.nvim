(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :eraserhd/parinfer-rust {:opt true :run "cargo build --release"})

(lz-package! :harrygallagher4/nvim-parinfer-rust
              {:after editor.parinfer
               :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})
