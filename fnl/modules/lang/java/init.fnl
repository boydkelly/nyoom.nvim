(import-macros {: use-package!} :macros)

; off-spec language server support for java
(use-package! :mfussenegger/nvim-jdtls {:after lang.java
                                        :ft :java}) 

