(local {: setup} (require :core.lib.setup))

(import-macros {: map!} :macros)

;; Commands and History
(map! [n] :<leader>a: "<cmd>Pick commands<cr>"
      {:desc "Run command"})

(map! [n] :<leader>a "<cmd>Pick history<cr>"
      {:desc "Run from command history"})

;; Neovim Objects
(map! [n] :<leader>ao "<cmd>Pick options<cr>"
      {:desc "Set nvim option"})

(map! [n] :<leader>nm "<cmd>Pick marks<cr>"
      {:desc "Marks"})

;; Files and Explorer
(map! [n] :<leader>fr "<cmd>Pick oldfiles<cr>"
      {:desc "Recent files"})

(map! [n] :<leader>fx "<cmd>Pick explorer<cr>"
      {:desc "Explorer"})

;; Help and System
(map! [n] :<leader>hm "<cmd>Pick manpages<cr>"
      {:desc "Man pages"})

(map! [n] :<leader>sK "<cmd>Pick keymaps<cr>"
      {:desc "Keymaps"})

(map! [n] :<leader>sr "<cmd>Pick registers<cr>"
      {:desc "Registers"})

;; UI / Theme
(map! [n] :<leader>eh "<cmd>Pick hl_groups<cr>"
      {:desc "Find hl groups"})

;; Buffer Search (with scope argument)
(map! [n] :<leader>sb "<cmd>Pick buf_lines scope='current'<cr>"
      {:desc "Search lines" :nowait true})

;;(setup :mini.extra)
