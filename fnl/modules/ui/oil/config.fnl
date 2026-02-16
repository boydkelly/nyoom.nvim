(import-macros {: map!} :macros)
(local {: setup} (require :core.lib.setup))
(set _G.oil_win_id nil)
(set _G.oil_source_win nil)

(fn _G.get_oil_winbar []
  (let [bufnr (vim.api.nvim_win_get_buf vim.g.statusline_winid)
        dir ((. (require :oil) :get_current_dir) bufnr)]
    (if dir (vim.fn.fnamemodify dir ":~") (vim.api.nvim_buf_get_name 0))))

(fn _G.toggle_oil_split []
  (if (and _G.oil_win_id (vim.api.nvim_win_is_valid _G.oil_win_id))
      (do
        (vim.api.nvim_set_current_win _G.oil_win_id)
        ((. (. (require :oil.actions) :close) :callback))
        (vim.api.nvim_win_close _G.oil_win_id false)
        (set _G.oil_win_id nil))
      (do
        (set _G.oil_source_win (vim.api.nvim_get_current_win))
        (local width (math.floor (* vim.o.columns 0.25)))
        (vim.cmd (.. "topleft " width :vsplit))
        (set _G.oil_win_id (vim.api.nvim_get_current_win))
        ((. (require :oil) :open)))))

;; I want to be able to open Oil in any file
(map! [n] "-" #(_G.toggle_oil_split) {:desc "Toggle Oil"})
(map! [n] :<leader>fe #(_G.toggle_oil_split) {:desc "Toggle Oil"})

(setup :oil {:delete_to_trash true
             :keymaps {:<BS> {1 :actions.parent :mode :n}
                       :<C-c> false
                       :<CR> {:callback (fn []
                                          (local oil (require :oil))
                                          (local entry (oil.get_cursor_entry))
                                          (if (and entry (= entry.type :file))
                                              (do
                                                (local dir
                                                       (oil.get_current_dir))
                                                (local filepath
                                                       (.. dir entry.name))
                                                (var target-win
                                                     _G.oil_source_win)
                                                (when (or (not target-win)
                                                          (not (vim.api.nvim_win_is_valid target-win)))
                                                  (local wins
                                                         (vim.api.nvim_list_wins))
                                                  (each [_ win (ipairs wins)]
                                                    (local buf
                                                           (vim.api.nvim_win_get_buf win))
                                                    (when (and (not= (. (. vim.bo
                                                                           buf)
                                                                        :filetype)
                                                                     :oil)
                                                               (not= win
                                                                     _G.oil_win_id))
                                                      (set target-win win))))
                                                (if (and target-win
                                                         (vim.api.nvim_win_is_valid target-win))
                                                    (do
                                                      (vim.api.nvim_set_current_win target-win)
                                                      (vim.cmd (.. "edit "
                                                                   (vim.fn.fnameescape filepath)))
                                                      (when (and _G.oil_win_id
                                                                 (vim.api.nvim_win_is_valid _G.oil_win_id))
                                                        (vim.api.nvim_win_close _G.oil_win_id
                                                                                false)
                                                        (set _G.oil_win_id nil)))
                                                    (oil.select)))
                                              (oil.select)))}}
             :view_options {:show_hidden true}
             :win_options {:winbar "%!v:lua.get_oil_winbar()"}})

