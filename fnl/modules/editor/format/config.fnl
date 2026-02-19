(import-macros {: nyoom-module-p! : command! : autocmd! : map!} :macros)
(local {: setup} (require :core.lib.setup))
(local conform (require :conform))

; unlayered formatters
(local formatters {:asciidoc [:trim_whitespace]
                   :nu [:trim_whitespace]})

(fn register-fmt [ft names]
  (tset formatters ft names))

(nyoom-module-p! cc (register-fmt :c [:clang-format]))
(nyoom-module-p! fennel (register-fmt :fennel [:fnlfmt]))
(nyoom-module-p! lua (register-fmt :lua [:stylua]))
(nyoom-module-p! python (register-fmt :python [:isort :black]))
(nyoom-module-p! rust (register-fmt :rust [:rustfmt]))
(nyoom-module-p! sh (register-fmt :sh [:shfmt :trim_whitespace]))
(nyoom-module-p! toml (register-fmt :toml [:taplo]))

(nyoom-module-p! javascript
  (do (register-fmt :css [:prettier])
      (register-fmt :html [:prettier])
      (register-fmt :javascript [:prettier])
      (register-fmt :json [:prettier])
      (register-fmt :markdown [:prettier])
      (register-fmt :svelte [:prettier])
      (register-fmt :typescript [:prettier])
      (register-fmt :typescriptreact [:prettier])
      (register-fmt :yaml [:yamlfmt])))

(local opts {:format_on_save (fn [bufnr]
                               (let [ft (. (. vim.bo bufnr) :filetype)
                                     disable-filetypes {:c true
                                                        :cpp true
                                                        :svelte true}]
                                 (if (and (= vim.g.autoformat_enabled true)
                                          (not (. (. vim.b bufnr)
                                                  :disable_autoformat)))
                                     {:lsp_fallback (not (. disable-filetypes
                                                            ft))
                                      :timeout_ms (or vim.g.conform_timeout
                                                      1000)}
                                     {:lsp_fallback false :timeout_ms 100})))
             :formatters {:shfmt {:prepend_args [:-i :2]}
                          :yamlfix {:env {:YAMLFIX_LINE_LENGTH :210
                                          :YAMLFIX_SEQUENCE_STYLE :block_style}}}
             :formatters_by_ft formatters
             :notify_on_error false})

(setup :conform opts)

(autocmd! FileType [lua
                    python
                    javascript
                    typescript
                    markdown
                    yaml
                    json
                    sh
                    html
                    css
                    toml
                    svelte]
          (fn []
            (set vim.bo.formatexpr "v:lua.require'conform'.formatexpr()")))

(command! Format
          (fn [args]
            (let [conform (require :conform)
                  range (if (not= args.count -1)
                            (let [lines (vim.api.nvim_buf_get_lines 0
                                                                    (- args.line2
                                                                       1)
                                                                    args.line2
                                                                    true)
                                  end-line (. lines 1)]
                              {:end [args.line2 (end-line:len)]
                               :start [args.line1 0]})
                            nil)]
              (conform.format {:async true :lsp_fallback true : range})))
          {:range true})

(map! [n] :<leader>cfc
      (fn []
        ((. (require :conform) :format) {:async true :lsp_fallback true}))
      {:desc "Format with Conform"})

(map! [n] :<leader>cfi :<cmd>ConformInfo<cr> {:desc "Format Info"})
