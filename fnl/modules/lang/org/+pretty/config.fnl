(import-macros {: packadd!} :macros)
(local {: setup} (require :core.lib.setup))
(packadd! org-bullets.nvim)

(setup :headlines {:org {:headline_highlights false}})
(setup :org-bullets {:concealcursor true})
