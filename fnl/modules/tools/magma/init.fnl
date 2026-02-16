(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :dccsillag/magma-nvim {:nyoom-module tools.magma
                                    :enabled true
                                    :cmd :MagmaInit})
;(lz-package! :dccsillag/magma-nvim {:nyoom-module ":UpdateRemotePlugins"})
