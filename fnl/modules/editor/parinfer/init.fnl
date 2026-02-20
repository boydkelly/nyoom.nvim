(import-macros {: lz-package! : build-pack-table : build-before-all-hook : vim-pack! } :macros)

;; this must be enabled=false to keep vim out of the rtp....  see readme
; binary download method {managed = true } is problematic
(lz-package! :eraserhd/parinfer-rust
              {:enabled false})

(lz-package! :harrygallagher4/nvim-parinfer-rust
             {:nyoom-module editor.parinfer
              :enabled true
              :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})
