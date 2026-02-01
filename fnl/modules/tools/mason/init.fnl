(import-macros {: lz-package! : vim-pack-spec!} :macros)

; Install language servers and such
(lz-package! :williamboman/mason.nvim {:after tools.mason
                                        :cmd [:Mason
                                              :MasonLog]})

