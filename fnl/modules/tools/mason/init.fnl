(import-macros {: lz-package! : vim-pack-spec!} :macros)

; Install language servers and such
(lz-package! :williamboman/mason.nvim {:nyoom-module tools.mason
                                        :enabled true 
                                        :cmd [:Mason
                                              :MasonLog]})
