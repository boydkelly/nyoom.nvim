(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :pwntester/octo.nvim {:cmd :Octo
                                    :call-setup octo})
