(import-macros {: lz-package! : vim-pack-spec!} :macros)

; off-spec language server support for java
(lz-package! :mfussenegger/nvim-jdtls {:after lang.java
                                        :ft :java}) 

