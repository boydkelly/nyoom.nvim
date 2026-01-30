(import-macros {: packadd! : pack : rock : use-package!
                : vim-pack-add! : vim-pack-spec!
                : rock! : nyoom-init-modules!
                : nyoom-compile-modules! : unpack! : autocmd!} :macros)

(set _G.nyoom/pack [])

;; defer autoload calls to runtime
; (fn get-echo! [] (_G.autoload :core.lib.io))
;
; (get-echo!) "Loading Packer"
;
;; compile healthchecks

(_G.echo! "Compiling Nyoom Doctor")
(_G.build (vim.fn.stdpath :config) {:verbosity 0}
       (.. (vim.fn.stdpath :config) :/fnl/core/doctor.fnl)
       (fn []
         (.. (vim.fn.stdpath :config) :/lua/health.lua)))
;
;; libraries
; (print "NYOOM: packages.fnl - START")

(vim-pack-spec! :nvim-lua/plenary.nvim {:module :plenary})
(vim-pack-spec! :MunifTanjim/nui.nvim {:module :nui})
(vim-pack-spec! :nyoom-engineering/oxocarbon.nvim)

;; BREADCRUMB 2
(print (.. "NYOOM: Staged " (length _G.nyoom/pack) " specs. Calling vim-pack-add!"))
; (_G.echo! "Test Installing Packages")
(vim-pack-add!)

; (print "NYOOM: packages.fnl - END")
;; include modules

; (_G.echo! "Initializing Module System")
; (include :fnl.modules)
; (nyoom-init-modules!)

;; To install a package with Nyoom you must declare them here and run 'nyoom sync'
;; on the command line, then restart nvim for the changes to take effect
;; The syntax is as follows:

;; (use-package! :username/repo {:opt true
;;                               :defer reponame-to-defer
;;                               :call-setup pluginname-to-setup
;;                               :cmd [:cmds :to :lazyload]
;;                               :event [:events :to :lazyload]
;;                               :ft [:ft :to :load :on]
;;                               :requires [(pack :plugin/dependency)]
;;                               :run :commandtorun
;;                               :as :nametoloadas
;;                               :branch :repobranch
;;                               :setup (fn [])
;;                                        ;; same as setup with packer.nvim)})
;;                               :config (fn [])})
;;                                        ;; same as config with packer.nvim)})

;; ---------------------
;; Put your plugins here
;; ---------------------

;; Send plugins to packer

; (_G.echo! "Installing Packages")
; (unpack!)

;; Compile modules

; (_G.echo! "Compiling Nyoom Modules")
; (nyoom-compile-modules!)
