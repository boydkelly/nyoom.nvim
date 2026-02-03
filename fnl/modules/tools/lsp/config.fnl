(import-macros {: autocmd! : augroup! : clear! : nyoom-module-p!} :macros)

(local lsp-servers [])

(nyoom-module-p! cc (table.insert lsp-servers :clangd))
(nyoom-module-p! python (table.insert lsp-servers :pyright))
(nyoom-module-p! lua (table.insert lsp-servers :lua_ls))
(nyoom-module-p! fennel (table.insert lsp-servers :fennel-ls))
(nyoom-module-p! csharp (table.insert lsp-servers :omnisharp))
(nyoom-module-p! clojure (table.insert lsp-servers :clojure_lsp))
(nyoom-module-p! java (table.insert lsp-servers :jdtls))
(nyoom-module-p! sh (table.insert lsp-servers :bashls))
(nyoom-module-p! julia (table.insert lsp-servers :julials))
(nyoom-module-p! json (table.insert lsp-servers :jsonls))
(nyoom-module-p! kotlin (table.insert lsp-servers :kotlin_langage_server))
(nyoom-module-p! latex (table.insert lsp-servers :texlab))
(nyoom-module-p! markdown (table.insert lsp-servers :marksman))
(nyoom-module-p! nim (table.insert lsp-servers :nimls))
(nyoom-module-p! nix (table.insert lsp-servers :rnix))
(nyoom-module-p! yaml (table.insert lsp-servers :yaml_ls))
(nyoom-module-p! zig (table.insert lsp-servers :zls))

(fn setup-lsp []
  (vim.diagnostic.config {:virtual_lines false
                          :underline true
                          :update_in_insert false
                          :signs {:text {vim.diagnostic.severity.ERROR "●"
                                         vim.diagnostic.severity.WARN  "●"
                                         vim.diagnostic.severity.INFO  "●"
                                         vim.diagnostic.severity.HINT  "●"}}})

  (augroup! nyoom-lsp-attach
    (autocmd! LspAttach *
              (fn [event]
                (let [buf event.buf
                      client (vim.lsp.get_client_by_id event.data.client_id)]
                  ;; Note: Add your (buf-map!) calls here for gd, K, etc.
                  (when (client.supports_method :textDocument/formatting)
                    (augroup! lsp-format (clear! {:buffer buf})
                      (autocmd! BufWritePre <buffer>
                                #(vim.lsp.buf.format {:bufnr buf})
                                {:buffer buf})))))))

  (each [_ server (ipairs lsp-servers)]
    (pcall vim.lsp.enable server)))

;; The "Just-In-Time" Loader
(let [loader (let [loaded {:status false}]
               (fn []
                 ;; Only run if not loaded AND we are in a "real" file buffer
                 (when (and (not loaded.status) (= vim.bo.buftype ""))
                   (set loaded.status true)
                   (setup-lsp)
                   ;; Re-trigger FileType so enabled servers attach to current buffer
                   (when (not= vim.bo.filetype "")
                     (vim.cmd (.. "doautocmd FileType " vim.bo.filetype))))))]

  ;; Register for future files
  (autocmd! FileType * loader {:desc "Nyoom: JIT LSP Loader"})

  ;; Immediate check for CLI open (e.g., nvim file.fnl)
  (when (and (not= vim.bo.filetype "") (= vim.bo.buftype ""))
    (loader)))
