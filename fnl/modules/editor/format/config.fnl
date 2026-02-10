(local {: setup} (require :core.lib.setup))
(import-macros {: nyoom-module-p! : map! : let! : command! : autocmd!} :macros)

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
             :formatters_by_ft {:asciidoc [:trim_whitespace]
                                :css [:prettier]
                                :fennel [:fnlfmt]
                                :html [:prettier]
                                :javascript [:prettier]
                                :json [:prettier]
                                :lua [:stylua]
                                :markdown [:prettier]
                                :nu [:trim_whitespace]
                                :python [:isort :black]
                                :sh [:shfmt :trim_whitespace]
                                :svelte [:prettier]
                                :toml [:taplo]
                                :typescript [:prettier]
                                :typescriptreact [:prettier]
                                :yaml [:yamlfmt]}
             :notify_on_error false})

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

(setup :conform opts)
