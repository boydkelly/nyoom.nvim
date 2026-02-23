(local M {})

(local ENABLE_LSP_PROGRESS true)

(var lsp-progress-active false)

(var shade-frame 1)

(local mode-info {"\019" {:hl :StatusVisual :label ""}
                  "\022" {:hl :StatusVisual :label "▥"}
                  :! {:hl :StatusTerminal :label ">"}
                  :R {:hl :StatusReplace :label "⇄"}
                  :Rv {:hl :StatusReplace :label "⇄"}
                  :S {:hl :StatusVisual :label "■"}
                  :V {:hl :StatusVisual :label "▤"}
                  :c {:hl :StatusCommand :label "▶"}
                  :ce {:hl :StatusCommand :label "▶"}
                  :cv {:hl :StatusCommand :label "▶"}
                  :i {:hl :StatusInsert :label "■"}
                  :ic {:hl :StatusInsert :label "■"}
                  :n {:hl :StatusNormal :label "●"}
                  :no {:hl :StatusNormal :label "●"}
                  :r {:hl :StatusReplace :label "⇄"}
                  :r? {:hl :StatusCommand :label "﹖"}
                  :rm {:hl :StatusReplace :label "⇄"}
                  :s {:hl :StatusVisual :label "■"}
                  :t {:hl :StatusTerminal :label ">"}
                  :v {:hl :StatusVisual :label "▤"}})

(local shade-frames ["░░░░"
                     "▒░░░"
                     "▓▒░░"
                     "▓▓▒░"
                     "▓▓▓▒"
                     "▓▓▓▓"
                     "▒▓▓▓"
                     "░▒▓▓"
                     "░░▒▓"
                     "░░░▒"])

(fn hl [group text]
  (string.format "%%#%s#%s" group text))

(fn get-shade []
  (let [mode (. (vim.api.nvim_get_mode) :mode)
        hl-group (or (and (. mode-info mode) (. (. mode-info mode) :hl))
                     :StatusLine)]
    (when (not ENABLE_LSP_PROGRESS)
      (let [___antifnl_rtns_1___ [(hl hl-group "▓▒░ ")]]
        (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
    (local shade (or (and lsp-progress-active
                          (or (. shade-frames shade-frame) "░░░░"))
                     "▓▒░ "))
    (hl hl-group shade)))

(fn get-filetype []
  (let [filetype vim.bo.filetype
        disabled {:DressingSelect true
                  :TelescopePrompt true
                  :TelescopeResults true
                  :lazy true
                  :minipick true
                  :ministarter true
                  :neo-tree true}]
    (when (or (= filetype "") (. disabled filetype))
      (lua "return \"\""))
    (var (icon iconhl) nil)
    (local (ok micons) (pcall require :mini.icons))
    (if (and ok micons.get)
        (do
          (set (icon iconhl) (micons.get :filetype filetype))
          (.. " " (hl iconhl icon) (hl :StatusFiletype (.. " " filetype))))
        (hl :StatusFiletype (.. "[" filetype "]")))))

(fn get-encoding []
  (let [encoding vim.bo.fileencoding]
    (when (= encoding :utf-8)
      (lua "return \"\""))
    (hl :StatusEncoding (.. " " encoding))))

(fn get-mode []
  (let [mode (. (vim.api.nvim_get_mode) :mode)
        entry (or (. mode-info mode) {:hl :StatusLine :label "??"})]
    (.. (hl entry.hl (.. " " entry.label " ░▒▓")) "%*")))

(fn get-git-repo []
  (let [handle (io.popen "git rev-parse --show-toplevel 2> /dev/null")
        result (: (handle:read :*a) :gsub "\n" "")]
    (handle:close)
    (when (not= result "")
      (let [___antifnl_rtn_1___ (.. (hl :StatusGit
                                        (.. " " (result:match "^.+/(.+)$")))
                                    "%*")]
        (lua "return ___antifnl_rtn_1___")))
    ""))

(fn get-git-branch []
  (let [handle (io.popen "git rev-parse --abbrev-ref HEAD 2>/dev/null")
        result (: (handle:read :*a) :gsub "\n" "")]
    (handle:close)
    (when (not= result "")
      (let [___antifnl_rtn_1___ (.. (hl :StatusGit (.. " Ξ " result)) "%*")]
        (lua "return ___antifnl_rtn_1___")))
    ""))

(fn get-git-diff []
  (let [filename (vim.fn.expand "%")]
    (when (or (= filename "") (= (vim.fn.filereadable filename) 0))
      (lua "return \"\""))
    (local handle
           (io.popen (.. "git diff --numstat -- " (vim.fn.shellescape filename)
                         " 2>/dev/null")))
    (when (not handle)
      (lua "return \"\""))
    (var (added removed changed) (values 0 0 0))
    (each [line (handle:lines)]
      (var (a d) (line:match "^(%d+)%s+(%d+)"))
      (when (and a d)
        (set (a d) (values (tonumber a) (tonumber d)))
        (when (and a d)
          (if (and (> a 0) (> d 0))
              (let [min (math.min a d)]
                (set changed (+ changed min))
                (set added (+ added (- a min)))
                (set removed (+ removed (- d min))))
              (do
                (set added (+ added a))
                (set removed (+ removed d)))))))
    (handle:close)
    (local parts {})
    (when (> added 0)
      (table.insert parts (hl :DiffAdded (.. "+" added))))
    (when (> changed 0)
      (table.insert parts (hl :DiffChanged (.. "~" changed))))
    (when (> removed 0)
      (table.insert parts (hl :DiffRemoved (.. "-" removed))))
    (or (and (> (length parts) 0) (.. " " (table.concat parts " "))) "")))

(fn get-fileinfo []
  (let [filename (vim.fn.expand "%:t")]
    (when (= filename "")
      (lua "return \"\""))
    (hl :StatusLine (.. " " filename))))

(fn get-lsp-diagnostic []
  (when (not (next (vim.lsp.get_clients {:bufnr 0})))
    (lua "return \"\""))

  (fn sev-count [s]
    (length (vim.diagnostic.get 0 {:severity s})))

  (local result
         {:errors (sev-count vim.diagnostic.severity.ERROR)
          :warnings (sev-count vim.diagnostic.severity.WARN)})
  (local parts {})
  (when (> result.warnings 0)
    (table.insert parts (hl :DiagnosticWarn (tostring result.warnings))))
  (when (> result.errors 0)
    (table.insert parts (hl :DiagnosticError (tostring result.errors))))
  (or (and (> (length parts) 0) (.. " " (table.concat parts " ") " ")) ""))

(fn get-location []
  (when (= vim.v.hlsearch 0)
    (let [___antifnl_rtns_1___ [(hl :StatusLine "%l:%c ")]]
      (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
  (local (ok count) (pcall vim.fn.searchcount {:recompute true}))
  (when (or (or (not ok) (= count.total 0)) (= count.current nil))
    (lua "return \"\""))
  (local total (or (and (> count.total count.maxcount) (.. ">" count.maxcount))
                   count.total))
  (hl :StatusLine (.. " " total " matches ")))

(fn get-keymap []
  (when (and (> (vim.opt.iminsert:get) 0) vim.b.keymap_name)
    (let [___antifnl_rtns_1___ [(hl :StatusLine (.. "[" vim.b.keymap_name "]"))]]
      (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
  "")

(global Statusline {})

(global Statusline (fn []
                     (table.concat [(get-mode)
                                    (get-git-repo)
                                    (get-git-branch)
                                    (get-fileinfo)
                                    (get-git-diff)
                                    "%="
                                    (get-lsp-diagnostic)
                                    (get-filetype)
                                    (get-encoding)
                                    (get-keymap)
                                    (hl :Statusline " %B ")
                                    (get-location)
                                    (get-shade)])))

(when ENABLE_LSP_PROGRESS
  (local shade-timer (vim.loop.new_timer))
  (shade-timer:start 0 250
                     (vim.schedule_wrap (fn []
                                          (when lsp-progress-active
                                            (set shade-frame
                                                 (+ (% shade-frame
                                                       (length shade-frames))
                                                    1))
                                            (vim.cmd.redrawstatus))))))

(local debounce-timer (vim.loop.new_timer))

(fn pulse []
  (when (not ENABLE_LSP_PROGRESS)
    (lua "return "))
  (set lsp-progress-active true)
  (debounce-timer:stop)
  (debounce-timer:start 2000 0
                        (fn []
                          (set lsp-progress-active false)
                          (vim.schedule (fn []
                                          (vim.cmd.redrawstatus)))))
  (vim.cmd.redrawstatus))

(set M.pulse pulse)

(when ENABLE_LSP_PROGRESS
  (vim.api.nvim_create_autocmd :LspProgress
                               {:callback (fn []
                                            (M.pulse))}))

(set vim.opt.cmdheight 0)

(set vim.opt.statusline "%!v:lua.Statusline()")

M
