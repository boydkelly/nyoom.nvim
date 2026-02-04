(local {: setup} (require :core.lib.setup))
(local {: autoload} (require :core.lib.autoload))
(import-macros {: set! : local-set! : packadd! : nyoom-module-p! : map! : custom-set-face! : augroup! : autocmd! : clear! } :macros)

;; Conditionally enable leap-ast

(nyoom-module-p! bindings
                 (do
                   (packadd! leap-ast.nvim)
                   (let [leap-ast (autoload :leap-ast)]
                     (map! [nxo] :gs `(leap-ast.leap) {:desc "Leap AST"}))))

(local treesitter-filetypes [:vimdoc :fennel :vim :regex :query :norg])

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

(nyoom-module-p! python (table.insert treesitter-filetypes :python))

(nyoom-module-p! sh (table.insert treesitter-filetypes :bash))

(nyoom-module-p! sh.+fish (table.insert treesitter-filetypes :fish))

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

  ;; 1. Register Norg
;; (table.insert treesitter-filetypes :gitignore)))
;; load dependencies

(let [(ok? ts-install) (pcall require :nvim-treesitter.install)]
  (when ok?
    (nyoom-module-p! neorg
      (ts-install.add_parser :norg
        {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg"
                        :files [:src/parser.c :src/scanner.cc]
                        :branch :main}}))
    (nyoom-module-p! org
      (ts-install.add_parser :org
        {:install_info {:url "https://github.com/milisims/tree-sitter-org"
                        :files [:src/parser.c :src/scanner.cc]
                        :branch :main}}))))

(nyoom-module-p! neorg (table.insert treesitter-filetypes :norg))

(nyoom-module-p! org (table.insert treesitter-filetypes :org))


(packadd! nvim-treesitter-textobjects)
(packadd! nvim-ts-context-commentstring)

;; setup hl groups for ts-rainbow

(custom-set-face! :TSRainbowRed  [] {:fg "#878d96" :bg :NONE})
(custom-set-face! :TSRainbowYellow [] {:fg "#a8a8a8" :bg :NONE})
(custom-set-face! :TSRainbowBlue [] {:fg "#8d8d8d" :bg :NONE})
(custom-set-face! :TSRainbowOrange [] {:fg "#a2a9b0" :bg :NONE})
(custom-set-face! :TSRainbowGreen [] {:fg "#8f8b8b" :bg :NONE})
(custom-set-face! :TSRainbowViolet [] {:fg "#ada8a8" :bg :NONE})
(custom-set-face! :TSRainbowCyan [] {:fg "#878d96" :bg :NONE})

;; the usual

(setup :nvim-treesitter)
;; the unusual
;;
;; (vim.notify "NYOOM: installing treesitter parsers" vim.log.levels.INFO)
;;
(let [ts (require :nvim-treesitter)]
  (ts.install treesitter-filetypes)
  (let [job (ts.install treesitter-filetypes)]
    (when job
      (job:wait 300000))))

;; 3. Create the Autocmd with the correct events
;
;(augroup! treesitter-setup
(augroup! treesitter-setup
  (clear!)
  (autocmd! [FileType BufReadPost BufNewFile] *
            (fn [event]
              (let [buf event.buf
                    bt (vim.api.nvim_get_option_value :buftype {:buf buf})
                    ft event.match]
                (when (and (= bt "")
                           (not (vim.tbl_contains [:checkhealth] ft)))
                  (let [lang (or (vim.treesitter.language.get_lang ft) ft)]
                    ;; 1. Start Highlighting
                    (pcall vim.treesitter.start buf lang)

                    ;; 2. Set Indentation using Nyoom's paradigm
                    ;; local-set! handles the buffer scoping for us
                    (local-set! indentexpr "v:lua.require'nvim-treesitter'.indentexpr()")))))
            {:desc "Nyoom: Start treesitter highlighting"}))
