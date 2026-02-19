(import-macros {: build-before-all-hook } :macros)
(local {: setup} (require :core.lib.setup))

;; build/run if necessary
(build-before-all-hook
  :parinfer-rust
  ["cargo" "build" "--release"]
  "target/release/libparinfer_rust.so")

;; safe to require nvim-parinfer-rust
(local parinfer (require :parinfer))
(parinfer.setup {:trail_highlight false})
