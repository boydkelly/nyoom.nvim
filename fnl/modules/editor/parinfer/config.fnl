(import-macros {: packadd! } :macros)
(local {: setup} (require :core.lib.setup))
(packadd! :parinfer-rust)
(setup :parinfer {:trail_higlight false})
