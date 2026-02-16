(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

; Install language servers and such
(lz-package! :williamboman/mason.nvim {:nyoom-module tools.mason
                                        :enabled true 
                                        :cmd [:Mason
                                              :MasonLog]})
