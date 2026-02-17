(local {: setup : autoload} (require :core.lib.setup))
(import-macros {: set! : map! : packadd! : nyoom-module-p!} :macros)
(include :modules.tools.mini-pick.pickers)
(local pickers (require :modules.tools.mini-pick.pickers))

(nyoom-module-p! mini-pick.+extra
                 (do
                 (packadd! :mini.extra)
                 (setup :mini.extra)
                 (include :modules.tools.mini-pick.+extra.keybinds)
                 ))
;;(local pickers (autoload :modules.tools.mini-pick.pickers))

;; Built-in Pickers
(map! [n] :<leader><space> "<cmd>Pick files<cr>" {:desc "Pick files"})
(map! [n] :<leader>bt "<cmd>Pick buffers<cr>" {:desc "List buffers"})
(map! [n] :<leader>hh "<cmd>Pick help<cr>" {:desc "Help"})
(map! [n] :<leader>sr "<cmd>Pick resume<cr>" {:desc "Resume last search"})

;; Word under cursor
(map! [n] :<leader>sk "<cmd>Pick grep pattern='<cword>'<cr>" {:desc "Word under cursor"})

;; Custom Pickers
(map! [n] :<leader>hr pickers.readme {:desc "Plugin readme files"})
(map! [n] :<leader>ec pickers.colorscheme {:desc "Change colorscheme"})
(map! [n] :<leader>su pickers.unicode_characters {:desc "Search unicode"})
(map! [n] :z= pickers.spellsuggest {:desc "Spell suggest"})

(nyoom-module-p! mini-pick
                 (do
                   (map! [n] :<leader><space> "<cmd>Pick git_files<CR>"
                         {:desc "Find file in project"})
                   (map! [n] "<leader>'" "<cmd>Pick resume<CR>"
                         {:desc "Resume last search"})
                   (map! [n] :<leader>. "<cmd>Pick files<CR>"
                         {:desc "Find file"})
                   (map! [n] :<leader>/ "<cmd>Pick grep_live<CR>"
                         {:desc "Search project"})
                   (map! [n] "<leader>:" "<cmd>Pick commands<CR>"
                         {:desc :M-x})
                   (map! [n] :<leader>< "<cmd>Pick buffers<CR>"
                         {:desc "Switch Buffer"})))

(fn custom-hl []
    (let [pick-hl (vim.api.nvim_get_hl 0 {:link false :name :WarningMsg})]
      (vim.api.nvim_set_hl 0 :MiniPickBorderText
                           {:bg pick-hl.fg :fg :NvimDarkGrey1})
      (vim.api.nvim_set_hl 0 :MiniPickMatchCurrent {:link :PmenuShadow})
      (vim.api.nvim_set_hl 0 :MiniPickMatchMarked {:bold true :fg pick-hl.fg})
      (vim.api.nvim_set_hl 0 :MiniPickMatchRanges {:bold true :fg pick-hl.fg})
      (vim.api.nvim_set_hl 0 :MiniPickNormal {:link :NormalFloat})
      (vim.api.nvim_set_hl 0 :MiniPickPrompt {:link :NormalFloat})
      (vim.api.nvim_set_hl 0 :MiniPickPromptCaret {:fg pick-hl.fg})
      (vim.api.nvim_set_hl 0 :MiniPickPromptPrefix {:fg pick-hl.fg})))

  (custom-hl)

  (vim.api.nvim_create_autocmd :ColorScheme {:callback custom-hl :pattern "*"})

  (fn win-config []
    (let [height (math.floor (* 0.618 vim.o.lines))
          width (math.floor (* 0.6 vim.o.columns))]
      {:anchor :NW
       :border :none
       :col (math.floor (* 0.5 (- vim.o.columns width)))
       : height
       :row (math.floor (* 0.5 (- vim.o.lines height)))
       : width}))

(setup :mini.pick {:backend :fzf
             :mappings {:choose_in_vsplit :<C-v>}
             :options {:use_cache true}
             :window {:config win-config}})

(local mp (require :mini.pick))
(set vim.ui.select mp.ui_select)
