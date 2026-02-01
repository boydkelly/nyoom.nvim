(import-macros {: lz-package! : vim-pack-spec!} :macros)

; Install language servers and such
(use-package! :williamboman/mason.nvim {:after tools.mason
                                        :cmd [:Mason
                                              :MasonLog]})

