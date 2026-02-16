(import-macros {: lz-package! : vim-pack-spec!} :macros)
(vim.cmd ":UpdateRemotePlugins")
;deal with this edge case later
;(lz-package! :dccsillag/magma-nvim {:nyoom-module ":UpdateRemotePlugins"})
