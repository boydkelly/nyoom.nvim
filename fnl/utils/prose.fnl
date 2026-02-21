(local M {})

(set M.prose
     (fn []
       (let [opt vim.opt_local]
         (set opt.virtualedit :block)
         (set opt.textwidth 0)
         (set opt.wrapmargin 0)
         (set opt.wrap true)
         (set opt.linebreak true)
         (set opt.showbreak " »")
         (set opt.breakindent true)
         (set opt.breakindentopt "min:20,shift:2,sbr")
         (set opt.list true)
         (set opt.listchars {:nbsp "+" :tab "> " :trail "-"})
         (set opt.smartindent true)
         (set opt.whichwrap "b,s,<,>,[,]")
         (set opt.comments "://,b:#,:%,b:-,b:*,b:.,:\\|")
         (set opt.formatoptions :tcqr)
         (set vim.opt.formatlistpat
              "\\s*\\[\\({]?\\(\\d\\+\\|[a-zA-Z]\\+\\)[\\]:.)}]\\s\\+\\|^\\s*[-–+o*•]\\s\\+"))))

(fn clear-quote-map []
  (when (not= (vim.fn.mapcheck "\"" :i) "")
    (pcall vim.api.nvim_del_keymap :i "\"")))

(fn M.set_quotes []
  (clear-quote-map)
  (local (has-autopairs autopairs) (pcall require :nvim-autopairs))
  (when has-autopairs
    (local Rule (require :nvim-autopairs.rule))
    (autopairs.add_rule (Rule "\"" "\"")))
  (local has-mini (or (. package.loaded :mini.pairs)
                      (pcall require :mini.pairs)))
  (when has-mini
    ((. (require :setup) :mini_pairs) :quotes)))

(fn M.set_guillemets []
  (clear-quote-map)
  (local (has-autopairs autopairs) (pcall require :nvim-autopairs))
  (when has-autopairs
    (autopairs.remove_rule "\""))
  (vim.keymap.set :i "\""
                  (fn []
                    (let [col (vim.fn.col ".")
                          prev (: (vim.fn.getline ".") :sub (- col 1) (- col 1))]
                      (or (and (prev:match "%S") " »") "« ")))
                  {:desc "Guillemets (Auto-detected Pair Plugin)" :expr true})
  (vim.notify "Guillemets input enabled"))

(fn M.toggle_guillemets []
  (if (not= (vim.fn.mapcheck "\"" :i) "") (M.set_quotes) (M.set_guillemets)))

(set M.scrollbind
     (fn []
       (let [cur-win (vim.api.nvim_get_current_win)]
         (set vim.wo.scrollbind true)
         (set vim.o.splitright true)
         (vim.cmd :bn)
         (set vim.wo.scrollbind true)
         (vim.api.nvim_set_current_win cur-win))))

(fn M.onesentence_cmd []
  (when (: (vim.fn.mode) :match "^[iR]")
    (lua "return 0"))
  (local start vim.v.lnum)
  (local finish (- (+ start vim.v.count) 1))
  (vim.cmd (string.format "%d,%djoin" start finish))
  (vim.cmd "silent! s/[.:;?!'\"”»][ ]\\zs\\s*\\ze\\S/\\r/g")
  0)

(fn M.onesentence_api []
  (when (: (vim.fn.mode) :match "^[iR]")
    (lua "return 0"))
  (local bufnr (vim.api.nvim_get_current_buf))
  (local start-line (- vim.v.lnum 1))
  (local end-line (+ start-line vim.v.count))
  (local lines (vim.api.nvim_buf_get_lines bufnr start-line end-line false))
  (var text (table.concat lines " "))
  (set text (text:gsub "([%.:;?!%\"%'”»])%s+(%S)" "%1\n%2"))
  (local new-lines (vim.split text "\n" {:plain true}))
  (vim.api.nvim_buf_set_lines bufnr start-line end-line false new-lines)
  0)

(fn M.asciidoctable []
  (let [min-space 3
        start-line (vim.fn.line "'<")
        end-line (vim.fn.line "'>")
        lines (vim.api.nvim_buf_get_lines 0 (- start-line 1) end-line false)
        transformed {}]
    (each [_ line (ipairs lines)]
      (var converted (line:gsub (.. (string.rep " " min-space) "+") "|"))
      (set converted (converted:gsub "^%|+" ""))
      (set converted (.. "|" converted))
      (table.insert transformed converted))
    (local header ["[width=\"100%\",cols=\"2\",frame=\"topbot\",options=\"header\",stripes=\"even\"]"
                   "|==="])
    (local footer ["|==="])
    (vim.api.nvim_buf_set_lines 0 (- start-line 1) end-line false transformed)
    (vim.api.nvim_buf_set_lines 0 (- start-line 1) (- start-line 1) false
                                header)
    (vim.api.nvim_buf_set_lines 0
                                (+ (+ (- start-line 1) (length header))
                                   (length transformed))
                                (+ (+ (- start-line 1) (length header))
                                   (length transformed))
                                false footer)))

(fn M.SetUsLayout []
  (os.execute "gdbus call --session --dest org.gnome.Shell --object-path /dev/ramottamado/EvalGjs --method dev.ramottamado.EvalGjs.Eval 'imports.ui.status.keyboard.getInputSourceManager().inputSources[0].activate()'"))

(fn M.SetCALayout []
  (os.execute "gdbus call --session --dest org.gnome.Shell --object-path /dev/ramottamado/EvalGjs --method dev.ramottamado.EvalGjs.Eval 'imports.ui.status.keyboard.getInputSourceManager().inputSources[1].activate()'"))

(local adoc-grp (vim.api.nvim_create_augroup :asciidoc {:clear false}))

(local prose-grp (vim.api.nvim_create_augroup :prose_lang {:clear false}))

(set M.translate (fn []
                   (let [original-buf (vim.api.nvim_get_current_buf)
                         original-win (vim.api.nvim_get_current_win)
                         path (vim.api.nvim_buf_get_name original-buf)
                         cur-line (. (vim.api.nvim_win_get_cursor 0) 1)]
                     (var target-path nil)
                     (if (path:match :/fr/)
                         (set target-path (path:gsub :/fr/ :/dyu/))
                         (path:match :/dyu/)
                         (set target-path (path:gsub :/dyu/ :/fr/))
                         (do
                           (vim.notify "File path does not contain /fr/ or /dyu/. Translation pair not applicable."
                                       vim.log.levels.INFO)
                           (lua "return ")))
                     (if (= (vim.fn.filereadable target-path) 1)
                         (do
                           (vim.cmd (.. "vsplit "
                                        (vim.fn.fnameescape target-path)))
                           (local target-buf (vim.api.nvim_get_current_buf))
                           (vim.cmd "runtime! plugin/asciidoctor.vim")
                           (set vim.opt_local.conceallevel 0)
                           (set vim.g.asciidoctor_syntax_conceal 0)
                           (vim.api.nvim_exec_autocmds :BufReadPost
                                                       {:buffer target-buf
                                                        :group prose-grp
                                                        :modeline false})
                           (vim.api.nvim_exec_autocmds :BufReadPost
                                                       {:buffer target-buf
                                                        :group adoc-grp
                                                        :modeline false})
                           (vim.api.nvim_set_current_win original-win)
                           (var target-win-id nil)
                           (each [_ win-id (ipairs (vim.api.nvim_list_wins))]
                             (when (= (vim.api.nvim_win_get_buf win-id)
                                      target-buf)
                               (set target-win-id win-id)
                               (lua :break)))
                           (when target-win-id
                             (vim.api.nvim_set_current_win target-win-id)
                             (local target-line-count
                                    (vim.api.nvim_buf_line_count target-buf))
                             (local new-line
                                    (math.min cur-line target-line-count))
                             (vim.api.nvim_win_set_cursor 0 [new-line 0])
                             (set vim.wo.scrollbind true)
                             (vim.api.nvim_win_set_option original-win
                                                          :scrollbind true)
                             (vim.cmd "normal! zvzz")))
                         (vim.notify (.. "No corresponding file found: "
                                         target-path)
                                     vim.log.levels.WARN)))))

M

