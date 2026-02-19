(import-macros {: lz-package! : build-pack-table : build-before-all-hook : vim-pack! } :macros)

;; this must be enabled=false to keep vim out of the rtp....  see readme
; (lz-package! :eraserhd/parinfer-rust
;             {:enabled false})

; (lz-package! :eraserhd/parinfer-rust
;              :run
;             {:enabled false})

(lz-package! :eraserhd/parinfer-rust
  {:run ["cargo" "build" "--release"]
   :build-file "target/release/libparinfer_rust.so"})

(lz-package! :harrygallagher4/nvim-parinfer-rust
             {:nyoom-module editor.parinfer
              :enabled false
              :ft [:fennel :clojure :lisp :racket :scheme :janet :guile]})
