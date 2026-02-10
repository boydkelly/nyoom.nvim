(local opts {:noremap true :silent true})

(vim.keymap.set :n :<C-f> :<PageDown> opts)

(vim.keymap.set :n :<C-b> :<PageUp> opts)

(vim.keymap.set :n :x "\"_x" {:desc "Delete character to black hole"})

(vim.keymap.set :n :J "mzJ`z" {:desc "Join lines and keep cursor position"})

(vim.keymap.set :n :YY "mzHGY`z" {:desc "Yank Buffer"})

(vim.keymap.set :n :<leader>q :<cmd>wqa<cr> {:desc :Quit})

(vim.keymap.set :n :i (fn []
                        (or (and (: (vim.api.nvim_get_current_line) :find
                                    "^%s*$")
                                 "\"_S") :i))
                {:expr true})

(vim.keymap.set :n :<ESC> ":nohlsearch<Bar>:echo<cr>" opts)

(vim.keymap.set :n :<leader>bn :<cmd>bnext<cr> {:desc "Next buffer"})

(vim.keymap.set :n :<leader>bp :<cmd>bprevious<cr> {:desc "Prev buffer"})

(vim.keymap.set :n :<leader>bb "<cmd>buffer #<cr>" {:desc "Alternate buffer"})

(vim.keymap.set :n :<leader>bo :<cmd>edit<cr> {:desc "Open buffer"})

(vim.keymap.set :n :<leader>bd :<cmd>bd<cr> {:desc "Close buffer"})

(vim.keymap.set :n :<leader>bq
                (fn []
                  ((. (require :utils.base) :Close_other_buffers)))
                {:desc "Close other buffers"})

(vim.keymap.set :n :<leader>bw :<cmd>bwipeout<cr> {:desc "Wipe buffer"})

(vim.keymap.set :n :<leader>bs :<cmd>split<cr> {:desc "Horizontal split"})

(vim.keymap.set :n :<leader>bv :<cmd>vsplit<cr> {:desc "Vertical split"})

(vim.keymap.set :n :<leader>ba
                (fn []
                  ((. (require :utils.base) :Auto_split)))
                {:desc "Auto split"})

(vim.keymap.set :n :<C-w>ns :<cmd>new<cr>
                {:desc "Split new window below" :remap true})

(vim.keymap.set :n :<C-w>nv :<cmd>vnew<cr>
                {:desc "Split new window right" :remap true})

(vim.keymap.set :n :<S-Up> "<cmd>resize +2<cr>")

(vim.keymap.set :n :<S-Down> "<cmd>resize -2<cr>")

(vim.keymap.set :n :<S-Left> "<cmd>vertical resize -2<cr>")

(vim.keymap.set :n :<S-Right> "<cmd>vertical resize +2<cr>")

(vim.keymap.set :n :n "v:searchforward ? 'nzzzv' : 'Nzzzv'"
                {:desc "Next search result" :expr true})

(vim.keymap.set :n :N "v:searchforward ? 'Nzzzv' : 'nzzzv'"
                {:desc "Prev search result" :expr true})

(vim.keymap.set [:x :n :s] :<C-s> ":w<cr><esc>" {:desc "Save file"})

(vim.keymap.set :n :<leader>hk
                (fn []
                  (let [word (vim.fn.expand :<cword>)
                        buf (vim.api.nvim_get_current_buf)
                        clients (vim.lsp.get_active_clients {:bufnr buf})]
                    (when (> (length clients) 0)
                      (local (ok _) (pcall vim.lsp.buf.hover))
                      (when ok
                        (lua "return ")))
                    (local man-exists (= (vim.fn.executable :man) 1))
                    (when man-exists
                      (vim.cmd (.. "!man " word))
                      (lua "return "))
                    (local tldr-exists (= (vim.fn.executable :tldr) 1))
                    (when tldr-exists
                      (vim.cmd (.. "!" "tldr " word))
                      (lua "return "))
                    (vim.fn.jobstart [:xdg-open
                                      (.. "https://duckduckgo.com/?q=" word)]
                                     {:detach true})))
                {:desc "Lookup keyword (LSP/man/tldr/web)"})

(vim.keymap.set :n :<leader>ci ":silent LspInfo<cr>"
                {:desc "Lsp Info" :silent true})

(vim.keymap.set :n :<leader>cl ":lopen<cr>" {:desc "Location List"})

(vim.keymap.set :n :<leader>cd
                (fn []
                  (vim.diagnostic.setqflist {:bufnr 0
                                             :open true
                                             :scope :buffer}))
                {:desc "Buffer Diagnostics → Quickfix"})

(vim.keymap.set :n :<leader>cD
                (fn []
                  (vim.diagnostic.setqflist {:open true :scope :workspace}))
                {:desc "Workspace Diagnostics → Quickfix"})

(fn open-term [direction]
  (vim.cmd (.. direction " | term"))
  (local win (vim.api.nvim_get_current_win))
  (local buf (vim.api.nvim_get_current_buf))
  (tset (. vim.bo buf) :buflisted false)
  (if (= direction :vsplit) (vim.api.nvim_win_set_width win 80)
      (vim.api.nvim_win_set_height win 10))
  (tset (. vim.wo win) :winbar "%#String#   Terminal %* %=")
  (vim.cmd.startinsert))

(vim.keymap.set :n :<leader>ts
                (fn []
                  (open-term :split)) {:desc "Terminal Below"})

(vim.keymap.set :n :<leader>tv
                (fn []
                  (open-term :vsplit)) {:desc "Terminal Right"})

(vim.keymap.set :t :<esc><esc> "<C-\\><C-n>" {:desc "Enter Normal Mode"})

(vim.keymap.set :t :<C-d> "<C-\\><C-n>:close<CR>"
                {:desc "Close terminal" :silent true})

(vim.keymap.set :n :<leader>fW "<cmd>noautocmd w<cr>"
                {:desc "Save (noautocmd/formatting)"})

(vim.keymap.set :n :<leader>fn :<cmd>enew<cr> {:desc "New File"})

(vim.keymap.set :n :<leader>ikd "<cmd>set spelllang=dyu<cr>" {:desc :Julakan})

(vim.keymap.set :n :<leader>ike "<cmd>set spelllang=en<cr>" {:desc :English})

(vim.keymap.set :n :<leader>ikf "<cmd>set spelllang=fr<cr>" {:desc "Français"})

(vim.keymap.set :n :<leader>ets
                (fn []
                  ((. (require :utils.toggle) :toggle_spell)))
                {:desc :Spelling})

(vim.keymap.set :n :<leader>etw
                (fn []
                  ((. (require :utils.toggle) :toggle_wrap)))
                {:desc "Word Wrap"})

(vim.keymap.set :n :<leader>etn
                (fn []
                  ((. (require :utils.toggle) :change_number)))
                {:desc :Number})

(vim.keymap.set :n :<leader>etc
                (fn []
                  ((. (require :utils.toggle) :toggle_conceal)))
                {:desc :Conceal})

(vim.keymap.set :n :<leader>etb
                (fn []
                  ((. (require :utils.toggle) :toggle_background)))
                {:desc :Background})

(vim.keymap.set :n :<leader>etS
                (fn []
                  ((. (require :utils.toggle) :toggle_statusline)))
                {:desc :Status})

(vim.keymap.set :n :<leader>etg
                (fn []
                  ((. (require :utils.prose) :toggle_guillemets)))
                {:desc "Toggle Guillemets"})

(vim.keymap.set :n :<leader>etB
                (fn []
                  ((. (require :utils.toggle) :toggle_scrollbind)))
                {:desc :Scrollbind :silent true})

(vim.keymap.set :n :<leader>ei vim.show_pos {:desc "Cursor HL group"})

(vim.keymap.set :n :<leader>nu "<cmd>normal! g;<cr>" {:desc "Last change"})

(vim.keymap.set :n :<leader>no "<cmd>normal! <C-o><cr>" {:desc "Older jump"})

(vim.keymap.set :n :<leader>nn "<cmd>normal! <C-i><cr>" {:desc "Newer jump"})

(vim.keymap.set :n :<leader>nl "<cmd>normal! m'<cr>"
                {:desc "Set temporary mark"})

(vim.keymap.set :n :<leader>am
                (fn []
                  ((. (require :utils.base) :show_messages)))
                {:desc "Show :messages in floating window"})

(vim.keymap.set :n :<leader>as :<cmd>StartupTime<cr>
                {:desc "Profile startup time"})

(vim.keymap.set :n :<leader>ah ":silent checkhealth<CR>"
                {:desc "Check health" :silent true})

(vim.keymap.set :n :<leader>ape (fn []
                                  (let [plugin-manifest (.. (vim.fn.stdpath :config)
                                                            :/lua/config/plugins.lua)]
                                    nil))
                {:desc "Edit plugin manifest"})

(local ps (require :utils.pluginspecs))

(vim.keymap.set :n :<leader>apc (fn []
                                  (ps.cmd))
                {:desc "Check for unused plugins"})

(vim.keymap.set :n :<leader>apf
                (fn []
                  (ps.cmd {:dry false :force true}))
                {:desc "Remove unused plugins"})

(vim.keymap.set :n :<leader>apu
                (fn []
                  (vim.pack.update)) {:desc "Update plugins"})

