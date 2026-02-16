(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :dccsillag/magma-nvim {:nyoom-module tools.magma
                                    :enabled true
                                    :cmd :MagmaInit})
;(lz-package! :dccsillag/magma-nvim {:nyoom-module ":UpdateRemotePlugins"})
