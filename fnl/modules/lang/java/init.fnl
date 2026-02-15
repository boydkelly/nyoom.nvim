(import-macros {: lz-package! : vim-pack-spec!} :macros)

; off-spec language server support for java
(lz-package! :mfussenegger/nvim-jdtls {:nyoom-module lang.java :ft :java})

;;todo
; (local jdtls (require :jdtls))
;
; (local config {
;   :cmd ["jdtls"] ;; Or the path to your mason-installed jdtls
;   :root_dir (jdtls.setup_dap_main_class_configs)
;   :settings {:java {
;                :signatureHelp {:enabled true}
;                :contentProvider {:preferred :fernflower}}}
; })
;
; ;; This is the magic command that starts the server
; (jdtls.start_or_attach config)
