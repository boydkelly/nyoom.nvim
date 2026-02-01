(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :pwntester/octo.nvim {:cmd :Octo
                                    :call-setup octo})
