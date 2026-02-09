(local {: setup} (require :core.lib.setup))
(local {: autoload} (require :core.lib.autoload))
(import-macros {: set!
                : local-set!
                : packadd!
                : nyoom-module-p!
                : map!
                : custom-set-face!
                : augroup!
                : autocmd!
                : command!
                : clear!} :macros)

;; Conditionally enable leap-ast
(nyoom-module-p! bindings
                 (do
                   (packadd! leap-ast.nvim)
                   (let [leap-ast (autoload :leap-ast)]
                     (map! [nxo] :gs `(leap-ast.leap) {:desc "Leap AST"}))))

(packadd! nvim-treesitter-textobjects)
(packadd! nvim-ts-context-commentstring)

;; setup hl groups for ts-rainbow

(custom-set-face! :TSRainbowRed [] {:fg "#878d96" :bg :NONE})
(custom-set-face! :TSRainbowYellow [] {:fg "#a8a8a8" :bg :NONE})
(custom-set-face! :TSRainbowBlue [] {:fg "#8d8d8d" :bg :NONE})
(custom-set-face! :TSRainbowOrange [] {:fg "#a2a9b0" :bg :NONE})
(custom-set-face! :TSRainbowGreen [] {:fg "#8f8b8b" :bg :NONE})
(custom-set-face! :TSRainbowViolet [] {:fg "#ada8a8" :bg :NONE})
(custom-set-face! :TSRainbowCyan [] {:fg "#878d96" :bg :NONE})

(local treesitter-filetypes [:vimdoc :fennel :vim :regex :query])

;; conditionally install parsers

(nyoom-module-p! clojure (table.insert treesitter-filetypes :clojure))
(nyoom-module-p! common-lisp (table.insert treesitter-filetypes :commonlisp))
(nyoom-module-p! csharp (table.insert treesitter-filetypes :c_sharp))
(nyoom-module-p! java (table.insert treesitter-filetypes :java))
(nyoom-module-p! julia (table.insert treesitter-filetypes :julia))
(nyoom-module-p! kotlin (table.insert treesitter-filetypes :kotlin))
(nyoom-module-p! latex (table.insert treesitter-filetypes :latex))
(nyoom-module-p! ledger (table.insert treesitter-filetypes :ledger))
(nyoom-module-p! lua (table.insert treesitter-filetypes :lua))
(nyoom-module-p! nix (table.insert treesitter-filetypes :nix))
; (nyoom-module-p! org (table.insert treesitter-filetypes :org))
(nyoom-module-p! python (table.insert treesitter-filetypes :python))
(nyoom-module-p! sh (table.insert treesitter-filetypes :bash))
(nyoom-module-p! sh.+fish (table.insert treesitter-filetypes :fish))
(nyoom-module-p! sh.+nu (table.insert treesitter-filetypes :nu))

(nyoom-module-p! zig (table.insert treesitter-filetypes :zig))

(nyoom-module-p! cc
                 (do
                   (table.insert treesitter-filetypes :c)
                   (table.insert treesitter-filetypes :cpp)))

(nyoom-module-p! rust
                 (do
                   (table.insert treesitter-filetypes :rust)
                   (table.insert treesitter-filetypes :toml)))

(nyoom-module-p! markdown
                 (do
                   (table.insert treesitter-filetypes :markdown)
                   (table.insert treesitter-filetypes :markdown_inline)))

(nyoom-module-p! vc-gutter
                 (do
                   (table.insert treesitter-filetypes :git_rebase)
                   (table.insert treesitter-filetypes :gitattributes)
                   (table.insert treesitter-filetypes :gitcommit)))

;; (table.insert treesitter-filetypes :gitignore)

;   (nyoom-module-p! neorg
;     (do
;       (tset ts-parsers :norg
;             {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg"
;                             :files [:src/parser.c :src/scanner.cc]
;                             :branch :main}})
;       (table.insert treesitter-filetypes :norg))))

;; the unusual
;; this is a noop if it already installed
;; (vim.notify "NYOOM: installing treesitter parsers" vim.log.levels.INFO)

(fn ts-install []
  (let [languages (table.concat treesitter-filetypes " ")]
    (vim.cmd (.. "TSInstall! " languages))))

(fn ts-sync []
  (let [ts-install (require :nvim-treesitter.install)]
    (let [job (ts-install.install treesitter-filetypes)]
      (if (= (type job) :table)
          (do
            (print "Nyoom: Compiling parsers (this will block Neovim to prevent a crash)...")
            (job:wait 300000)
            (print "Nyoom: Sync finished."))
          (print "Nyoom: All parsers are already up to date.")))))

(command! TSUpdateSync `(ts-sync)
          {:desc "Sync all parsers defined in config"})

(augroup! treesitter-setup (clear!)
          (autocmd! [FileType] *
                    (fn [event]
                      (let [buf event.buf
                            ft (vim.api.nvim_get_option_value :filetype {: buf})
                            lang (vim.treesitter.language.get_lang ft)]
                        (when lang
                          ;; 1. Start Highlighting
                          (pcall vim.treesitter.start buf lang)
                          ;; 2. Set Indentation (Now correctly scoped inside the 'when')
                          (local-set! indentexpr
                                      "v:lua.require'nvim-treesitter'.indentexpr()"))))
                    {:desc "Nyoom: Start treesitter highlighting and indentation"}))
