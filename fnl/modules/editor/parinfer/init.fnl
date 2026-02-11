(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :eraserhd/parinfer-rust {:fake-module editor.parinfer} :enable
             true :run "cargo build --release")

(lz-package! :harrygallagher4/nvim-parinfer-rust
             {:nyoom-module editor.parinfer
              :enable true
              :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})

