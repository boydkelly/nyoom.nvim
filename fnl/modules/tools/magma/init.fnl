(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :dccsillag/magma-nvim {:run ":UpdateRemotePlugins"
                                     :cmd :MagmaInit})
