(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

; view rust crate info with virtual text

(lz-package! :saecki/crates.nvim
              {:call-setup crates :event ["BufRead Cargo.toml"]})

; inlay-hints + lldb + niceties for rust-analyzer

(lz-package! :simrat39/rust-tools.nvim {:nyoom-module lang.rust :ft :rust})
