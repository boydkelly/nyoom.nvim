(require-macros :macros)
(import-macros {: packadd! : colorscheme} :macros)

;; You can use the `colorscheme` macro to load a custom theme, or load it manually
;; via require. This is the default:

; (print "CONFIG: colorscheme")
(set! background :dark)
(packadd! oxocarbon.nvim)
(colorscheme oxocarbon)
;; (colorscheme oxocarbon)

;; The set! macro sets vim.opt options. By default it sets the option to true
;; Appending `no` in front sets it to false. This determines the style of line
;; numbers in effect. If set to nonumber, line numbers are disabled. For
;; relative line numbers, set 'relativenumber`

(set! nonumber)

;; The let option sets global, or `vim.g` options.
;; Heres an example with localleader, setting it to <space>m

(let! mapleader " ")
(let! maplocalleader ",")

;; map! is used for mappings
;; Heres an example, preseing esc should also remove search highlights

(map! [n] :<esc> :<esc><cmd>noh<cr> {:desc "No highlight escape"})

;; sometimes you want to modify a plugin thats loaded from within a module. For
;; this you can use the `after` function

; (_G.after :neorg
;        {:load {:core.dirman {:config {:workspaces {:main "~/neorg"}}}}})
;
; new cmd line; noice config disables this after startup...   Best of both.
((. (require :vim._core.ui2) :enable) {:enable true
                                       :msg {:target :cmd :timeout 2000}})

(require :utils.unicode)
; (set _G.notify_mods
;      (fn []
;        (let [m (or (. _G :nyoom/modules) {})
;              names {}]
;          (each [name _ (pairs m)]
;            (table.insert names name))
;          (table.sort names)
;          (local output (table.concat names "\n"))
;          (if (= (length names) 0)
;              (vim.notify "No modules found in _G['nyoom/modules']"
;                          vim.log.levels.WARN)
;              (vim.notify (.. "Active Modules:\n" output) vim.log.levels.INFO)))))
