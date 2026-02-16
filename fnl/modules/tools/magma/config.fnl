(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)
(vim.cmd ":UpdateRemotePlugins")
;deal with this edge case later
;(lz-package! :dccsillag/magma-nvim {:nyoom-module ":UpdateRemotePlugins"})
