(local {: autoload} (require :core.lib.autoload))
(local {: setup} (require :core.lib.setup))
(import-macros {: packadd!} :macros)

;; (setup :nvim-material-icon)
;; (local material-icons (autoload :nvim-material-icon))

;;(setup :nvim-web-devicons {:override (material-icons.get_icons)})
; (setup :nvim-web-devicons)

;; 1. Ensure the material icons are in the runtimepath
(packadd! nvim-material-icon)

;; 2. Use a standard require (with pcall for safety) to get the icons.
;; Standard require is better here because it forces a search of the
;; new paths added by packadd immediately.
(let [(ok? material-icons) (pcall require :nvim-material-icon)]
  (if ok?
      ;; 3. Pass the overrides to devicons
      (setup :nvim-web-devicons {:override (material-icons.get_icons)})
      ;; Fallback if something went wrong
      (setup :nvim-web-devicons)))
