(import-macros {: autocmd! : augroup! : clear! : nyoom-module-p!} :macros)

;; 1. Collect Servers (The Nyoom Way)
(local lsp-servers [])

(nyoom-module-p! cc (table.insert lsp-servers :clangd))
(nyoom-module-p! python (table.insert lsp-servers :pyright))
(nyoom-module-p! lua (table.insert lsp-servers :lua_ls))
(nyoom-module-p! fennel (table.insert lsp-servers :fennel_ls))
(nyoom-module-p! fennel (table.insert lsp-servers :fennel-ls))

;; 2. The Setup Function
(fn setup-lsp []
  ;; Diagnostic UI
  (vim.diagnostic.config {:virtual_lines false
                          :underline true
                          :update_in_insert false
                          :signs {:text {vim.diagnostic.severity.ERROR "●"
                                         vim.diagnostic.severity.WARN  "●"
                                         vim.diagnostic.severity.INFO  "●"
                                         vim.diagnostic.severity.HINT  "●"}}})

  ;; Global LspAttach (Keybindings & Formatting)
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

  ;; Enable servers (The 2025 way - lspconfig registry lookup)
  (each [_ server (ipairs lsp-servers)]
    (pcall vim.lsp.enable server)))

;; 3. The "Just-In-Time" Loader
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
