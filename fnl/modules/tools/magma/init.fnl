(import-macros {: lz-package! : vim-pack-spec!} :macros)

(use-package! :dccsillag/magma-nvim {:run ":UpdateRemotePlugins"
                                     :cmd :MagmaInit})
