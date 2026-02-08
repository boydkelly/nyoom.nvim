;; disable builtin vim plugins and providers, small speedup
; (vim.notify "NYOOM: Fennel runtime reached" vim.log.levels.INFO)

(local default-plugins [:2html_plugin
                        :getscript
                        :getscriptPlugin
                        :gzip
                        :logipat
                        :netrw
                        ; :netrwPlugin
                        :netrwSettings
                        :netrwFileHandlers
                        :matchit
                        :tar
                        :tarPlugin
                        :rrhelper
                        ; :spellfile_plugin
                        :vimball
                        :vimballPlugin
                        :zip
                        :zipPlugin
                        :tutor
                        :rplugin
                        :syntax
                        :synmenu
                        :optwin
                        :compiler
                        :bugreport
                        :ftplugin])

(local default-providers [:node :perl :ruby])

(each [_ plugin (pairs default-plugins)] (tset vim.g (.. :loaded_ plugin) 1))
(each [_ provider (ipairs default-providers)]
  (tset vim.g (.. :loaded_ provider :_provider) 0))

;; If NYOOM_PROFILE is set, enable profiling
(when (os.getenv :NYOOM_PROFILE) ; (vim.notify "NYOOM: Enabling profiler" vim.log.levels.WARN)
  ((. (require :core.lib.profile) :toggle)))

; (vim.notify "NYOOM: Loading core.lib" vim.log.levels.INFO)

;; Load Nyoom standard library and expose globals
(let [stdlib (require :core.lib)] ; (vim.notify "NYOOM: core.lib loaded, injecting globals" vim.log.levels.INFO)
  (each [k v (pairs stdlib)]
    (rawset _G k v)))

; (vim.notify "NYOOM: Requiring core" vim.log.levels.INFO)

;; Finally load Nyoom core
(require :core)
; (print "CORE: END")

; (vim.notify "NYOOM: core loaded successfully" vim.log.levels.INFO)
