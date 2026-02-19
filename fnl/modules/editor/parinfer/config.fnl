(import-macros {: packadd! : vim-pack! : autocmd!} :macros)
(local {: setup} (require :core.lib.setup))
(local parinfer (require :parinfer))

(local binary-path (.. (vim.fn.stdpath :cache) "/parinfer-rust/target/release/libparinfer_rust.so"))

(if (= (vim.fn.filereadable binary-path) 0)
    (do
      (vim.notify "Nyoom: Parinfer binary missing. Building..." vim.log.levels.WARN)
      (packadd! :parinfer-rust)
      (parinfer.setup {:managed true})
      ; (setup :parinfer {:managed true})
      (vim.cmd "ParinferInstall"))
    ;(setup :parinfer {:managed true :trail_highlight false})
    )
