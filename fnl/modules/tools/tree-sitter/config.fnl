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

(nyoom-module-p! cc
                 (do
                   (table.insert treesitter-filetypes :c)
                   (table.insert treesitter-filetypes :cpp)))

(nyoom-module-p! clojure (table.insert treesitter-filetypes :clojure))
(nyoom-module-p! common-lisp (table.insert treesitter-filetypes :commonlisp))
(nyoom-module-p! csharp (table.insert treesitter-filetypes :c_sharp))
(nyoom-module-p! web
                 (do
                   (table.insert treesitter-filetypes :html)
                   (table.insert treesitter-filetypes :css)))

(nyoom-module-p! java (table.insert treesitter-filetypes :java))
(nyoom-module-p! javascript (table.insert treesitter-filetypes :javascript))
(nyoom-module-p! javascript.+ts
                 (do
                   (table.insert treesitter-filetypes :typescript)
                   (table.insert treesitter-filetypes :tsx)))

(nyoom-module-p! javascript.+svelte (table.insert treesitter-filetypes :svelte))
(nyoom-module-p! julia (table.insert treesitter-filetypes :julia))
(nyoom-module-p! kotlin (table.insert treesitter-filetypes :kotlin))
(nyoom-module-p! latex (table.insert treesitter-filetypes :latex))
(nyoom-module-p! ledger (table.insert treesitter-filetypes :ledger))
(nyoom-module-p! lua (table.insert treesitter-filetypes :lua))
(nyoom-module-p! yaml (table.insert treesitter-filetypes :yaml))
(nyoom-module-p! xml (table.insert treesitter-filetypes :xml))
(nyoom-module-p! json (table.insert treesitter-filetypes :json))
(nyoom-module-p! sql (table.insert treesitter-filetypes :sql))
; (nyoom-module-p! org (table.insert treesitter-filetypes :org))
(nyoom-module-p! python (table.insert treesitter-filetypes :python))
(nyoom-module-p! sh (table.insert treesitter-filetypes :bash))
(nyoom-module-p! sh.+fish (table.insert treesitter-filetypes :fish))
(nyoom-module-p! sh.+nu (table.insert treesitter-filetypes :nu))

(nyoom-module-p! zig (table.insert treesitter-filetypes :zig))

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

(table.insert treesitter-filetypes :gitignore)

(nyoom-module-p! neorg
  (do
    ;; Build a parser from source
    (fn build-parser [spec]
      (let [data-dir (vim.fn.stdpath :data)
            cache-dir (.. (vim.fn.stdpath :cache) :/tree-sitter)
            parser-dir (.. data-dir :/site/parser)
            queries-dir (.. data-dir :/site/queries)
            repo-name (spec.url:match "([^/]+)$")
            extract-dir (string.format "%s/%s-%s" cache-dir repo-name spec.rev)
            old-shell vim.o.shell]

        ;; Ensure cache dir exists
        (vim.fn.mkdir cache-dir :p)
        (vim.fn.mkdir parser-dir :p)
        (vim.fn.mkdir queries-dir :p)

        ;; --- Clone if missing ---
        (when (= (vim.fn.isdirectory extract-dir) 0)
          (vim.notify (string.format "Cloning %s..." spec.url))
          (vim.fn.system
            (string.format
              "git clone --depth 1 --branch %s %s %s"
              spec.rev spec.url extract-dir)))

        ;; Determine source path
        (var src-path extract-dir)
        (when (= (vim.fn.isdirectory (.. extract-dir :/src)) 1)
          (set src-path (.. extract-dir :/src)))

        ;; --- Compile parser ---
        (set vim.o.shell :bash)
        (local cc "cc -O2 -fPIC -fvisibility=default -I.")
        (var scanner-obj "")
        (var linker :cc)
        (local cmds [(string.format "cd %s" src-path) "rm -f *.o"])

        (table.insert cmds (string.format "%s -c parser.c -o parser.o" cc))

        ;; Scanner logic
        (if (= (vim.fn.filereadable (.. src-path :/scanner.c)) 1)
            (do
              (table.insert cmds (string.format "%s -c scanner.c -o scanner.o" cc))
              (set scanner-obj :scanner.o))

            (= (vim.fn.filereadable (.. src-path :/scanner.cc)) 1)
            (do
              (table.insert cmds (string.format "c++ -O2 -fPIC -fvisibility=default -I. -c scanner.cc -o scanner.o"))
              (set scanner-obj :scanner.o)
              (set linker :c++))

            nil)

        ;; Make parser destination
        (vim.fn.mkdir parser-dir :p)

        ;; Link .so
        (table.insert cmds (string.format "%s -shared parser.o %s -o %s/%s.so"
                                         linker scanner-obj parser-dir spec.lang))

        ;; Run compilation
        (local output (vim.fn.system (table.concat cmds " && ")))
        (set vim.o.shell old-shell)

        ;; Copy queries folder
        (let [queries-src (.. src-path :/queries)
              queries-dest (.. queries-dir :/ spec.lang)]
          (when (= (vim.fn.isdirectory queries-src) 1)
            (vim.fn.mkdir queries-dest :p)
            (vim.fn.system (string.format "cp -r %s/* %s/" queries-src queries-dest))))

        ;; Notify result
        (if (not= vim.v.shell_error 0)
            (vim.notify (string.format "[!] Error: %s" output) vim.log.levels.ERROR)
            (vim.notify (string.format "[+] %s installed." spec.lang) vim.log.levels.INFO))))

    ;; Sync and build all required norg parsers
    (fn norg-sync []
      (let [targets [{:lang :norg
                      :type :norg
                      :rev :main
                      :url "https://github.com/nvim-neorg/tree-sitter-norg"}
                     {:lang :norg_meta
                      :type :norg_meta
                      :rev :main
                      :url "https://github.com/nvim-neorg/tree-sitter-norg-meta"}]]
        (each [_ spec (ipairs targets)]
          (local (ok? metadata) (pcall vim.treesitter.language.inspect spec.lang))
          ;; If parser not loaded, ensure it's downloaded and built
          (if (not ok?)
              (build-parser spec)))))
              ; (vim.notify (string.format "Parser %s loaded (ABI %s)" spec.lang metadata.abi_version))))))

    ;; Execution
    (norg-sync)
    (table.insert treesitter-filetypes :norg)))

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

(command! TSUpdateSync `(ts-sync) {:desc "Sync all parsers defined in config"})

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

;; no need to run nvim-treesitter setup unless changing default options
