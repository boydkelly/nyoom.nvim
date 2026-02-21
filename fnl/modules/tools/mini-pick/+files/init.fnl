(fn M.mini_files []
  (let [explore-at-file "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"]
    (vim.keymap.set :n :<A-e> "<Cmd>lua MiniFiles.open()<cr>" {:desc :Explore})
    (vim.keymap.set :n "-" explore-at-file {:desc "Explore@File"})
    (vim.keymap.set :n :<leader>ff "<Cmd>lua MiniFiles.open()<cr>"
                    {:desc :Explore})
    (vim.keymap.set :n :<leader>fF explore-at-file {:desc "Explore@File"})
    (local mf (require :mini.files))
    (mf.setup {:mappings {:close :<ESC> :go_in :L :go_in_plus :l}
               :options {:action :open}
               :windows {:border :single :preview false :width_preview 80}})))
