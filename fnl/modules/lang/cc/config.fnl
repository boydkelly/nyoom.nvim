(local setup (require :core.lib.setup))
(import-macros {: nyoom-module-p!} :macros)

(nyoom-module-p! lsp
  (do
    (setup :clangd_extensions)))
