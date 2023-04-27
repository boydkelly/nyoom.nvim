(local {: map} (vim.api.nvim_set_keymap))
(local {: buf-map} vim.api.nvim_buf_set_keymap))

(setup :toggleterm
             {:close_on_exit true
             :direction :vertical
             :float_opts {:border :single
             :highlights {:background :Normal
             :border :Normal}
             :winblend 3}
             :hide_numbers true
             :insert_mappings true
             :open_mapping :<C-n>
             :persist_mode false
             :persist_size true
             :shade_filetypes {}
             :shade_terminals true
             :shading_factor :1
             :shell vim.o.shell
             :size (fn [term]
                     (if (= term.direction
                            :horizontal)
                         15
                         (= term.direction
                            :vertical)
                         (* vim.o.columns 0.4)))
             :start_in_insert true})
)

(map :t :<ESC> "<C-\\><C-n>" {:noremap true :silent true})

(fn set-terminal-keymaps []
  (local opts {:noremap true})
  (buf-map 0 :t :<esc> "<C-\\><C-n>" opts)
  (buf-map 0 :t :<C-h> "<C-\\><C-n><C-W>h" opts)
  (buf-map 0 :t :<C-j> "<C-\\><C-n><C-W>j" opts)
  (buf-map 0 :t :<C-k> "<C-\\><C-n><C-W>k" opts)
  (buf-map 0 :t :<C-l> "<C-\\><C-n><C-W>l" opts))

(vim.api.nvim_create_autocmd :TermOpen
                             {:callback (fn []
                                          (set-terminal-keymaps))
                             :desc "Mappings for navigation with a terminal"
                             :pattern "term://*"
                             :key :C-n}))

}]
)
