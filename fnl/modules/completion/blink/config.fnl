(import-macros {: set! : nyoom-module-p! : packadd!} :macros)
(global module :blink.cmp)
(local (ok blink) (pcall require module))
(packadd! blink-cmp-spell)

(when (not ok)
  (vim.notify (.. "Couldn't load module '" module "'"))
  (lua "return "))

(fn apply-blink-hl []
  (let [blink-hl (vim.api.nvim_get_hl 0 {:link false :name :WarningMsg})]
    (vim.api.nvim_set_hl 0 :BlinkCmpMenu {:link :Pmenu})
    (vim.api.nvim_set_hl 0 :BlinkCmpMenuSelection {:link :PmenuShadow})
    (vim.api.nvim_set_hl 0 :BlinkCmpLabelMatch {:bold true :fg blink-hl.fg})
    (vim.api.nvim_set_hl 0 :PmenuKind {:bg blink-hl.fg :fg :NvimDarkGrey1})
    (vim.api.nvim_set_hl 0 :BlinkCmpKind {:bg blink-hl.fg :fg :NvimDarkGrey1})))

(apply-blink-hl)

(vim.api.nvim_create_autocmd :ColorScheme
                             {:callback apply-blink-hl :pattern "*"})

(local opts {:appearance {:nerd_font_variant :normal}
             :cmdline {:completion {:ghost_text {:enabled true}
                                    :list {:selection {:auto_insert true
                                                       :preselect false}}
                                    :menu {:auto_show (fn [ctx]
                                                        (= (vim.fn.getcmdtype)
                                                           ":"))
                                           :draw {:columns [[:kind_icon]
                                                            {1 :label
                                                             2 :label_description
                                                             :gap 1}]}}
                                    :trigger {:show_on_blocked_trigger_characters {}
                                              :show_on_x_blocked_trigger_characters nil}}
                       :enabled true
                       :keymap {:<S-Tab> [(fn [cmp]
                                            (cmp.select_prev))
                                          :snippet_backward
                                          :fallback]
                                :<Tab> [(fn [cmp]
                                          (cmp.select_next))
                                        :snippet_forward
                                        :fallback]
                                :preset :cmdline}}
             :completion {:accept {:auto_brackets {:enabled true}}
                          :documentation {:auto_show true
                                          :auto_show_delay_ms 250
                                          :treesitter_highlighting true
                                          :window {:border :none}}
                          :ghost_text {:enabled true}
                          :list {:selection {:auto_insert true
                                             :preselect false}}
                          :menu {:auto_show true
                                 :border :none
                                 :cmdline_position (fn []
                                                     (when (not= vim.g.ui_cmdline_pos
                                                                 nil)
                                                       (local pos
                                                              vim.g.ui_cmdline_pos)
                                                       (let [___antifnl_rtn_1___ [(- (. pos
                                                                                        1)
                                                                                     1)
                                                                                  (. pos
                                                                                     1)]]
                                                         (lua "return ___antifnl_rtn_1___")))
                                                     (local height
                                                            (or (and (= vim.o.cmdheight
                                                                        0)
                                                                     1)
                                                                vim.o.cmdheight))
                                                     [(- (- vim.o.lines height)
                                                         2)
                                                      2])
                                 :draw {:columns [[:kind_icon]
                                                  {1 :label
                                                   2 :label_description
                                                   :gap 1}
                                                  [:source_name]]
                                        :components {:kind_icon

{:text (fn [ctx]
         (.. " "
             (or (. (. (require :lspkind) :symbol_map) ctx.kind) "")
             " "))}

                                                     :label {:text (fn [item]
                                                                     item.label)}
                                                     :source_name {:text (fn [ctx]
                                                                           (.. "["ctx.source_name))}}}}}})"]"
:width {:max 10}
       :fuzzy {:implementation :prefer_rust
               :prebuilt_binaries {:download true :force_version :v1.8.0}}
             :keymap {:<CR> [:accept :fallback]
                      :<S-Tab> [(fn [cmp]
                                  (cmp.select_prev))
                                :snippet_backward
                                :fallback]
                      :<Tab> [(fn [cmp]
                                (cmp.select_next))
                              :snippet_forward
                              :fallback]
                      :preset :default}
             :signature {:enabled true}
             :snippets {:preset :luasnip}
             :sources {:default [:lsp :path :snippets :buffer :spell :hledger]
                       :per_filetype [{:markdown [:snippets :buffer :spell]}
                                      {:asciidoc [:snippets :buffer :spell]}
                                      {:ledger {1 :hledger
                                                :inherit_defaults false}}
                                      {:yaml [:lsp :snippets]}]
                       :providers {:buffer {:opts {}}
                                   :hledger {:module :blink.compat.source
                                             :name :hledger
                                             :opts {}
                                             :score_offset 3}
                                   :lsp {:fallbacks [:buffer]}
                                   :spell {:module :blink-cmp-spell
                                           :name :Spell
                                           :opts {}}}}

(blink.setup opts)
