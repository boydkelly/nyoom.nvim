(import-macros {: packadd! : pack : rock : use-package!
                : rock! : nyoom-init-modules!
                : nyoom-compile-modules! : unpack! : autocmd!} :macros)

; (packadd! "packer.nvim")

;; defer autoload calls to runtime
(fn get-init  [] (_G.autoload :packer))
(fn get-echo! [] (_G.autoload :core.lib.io))

(get-echo!) "Loading Packer"
(get-init) {}
  :compile_path (.. (vim.fn.stdpath :config) :/lua/packer_compiled.lua)
  :auto_reload_compiled false
  :display {:non_interactive (= 0 (length (vim.api.nvim_list_uis)))}

;; ...rest unchanged

;; compile healthchecks

(_G.echo! "Compiling Nyoom Doctor")
(_G.build (vim.fn.stdpath :config) {:verbosity 0}
       (.. (vim.fn.stdpath :config) :/fnl/core/doctor.fnl)
       (fn []
         (.. (vim.fn.stdpath :config) :/lua/health.lua)))

;; packer can manage itself

;; (use-package! :EdenEast/packer.nvim {:opt true :branch :feat/lockfile})
;(use-package! :wbthomason/packer.nvim {:opt true})

;; libraries

(use-package! :nvim-lua/plenary.nvim {:module :plenary})
(use-package! :MunifTanjim/nui.nvim {:module :nui})
(use-package! :nyoom-engineering/oxocarbon.nvim)

;; include modules

(echo! "Initializing Module System")
(include :fnl.modules)
(nyoom-init-modules!)

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

(_G.echo! "Installing Packages")
(unpack!)

;; Compile modules

(_G.echo! "Compiling Nyoom Modules")
(nyoom-compile-modules!)
