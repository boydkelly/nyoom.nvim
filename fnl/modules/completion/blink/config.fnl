(import-macros {: set! : nyoom-module-p! : packadd!} :macros)
(local {: setup} (require :core.lib.setup))

(packadd! blink-cmp-spell)
(packadd! lspkind.nvim)
(packadd! cmp-conjure)
(packadd! copilot.lua)
(packadd! LuaSnip)

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

(local opts
  {:appearance {:nerd_font_variant :normal}
   :cmdline {:completion {:ghost_text {:enabled true}
                          :list {:selection {:auto_insert true :preselect false}}
                          :menu {:auto_show (fn [] (= (vim.fn.getcmdtype) ":"))
                                 :draw {:columns [[:kind_icon]
                                                  {1 :label 2 :label_description :gap 1}]}}
                          :trigger {:show_on_blocked_trigger_characters []}}
             :keymap {:<S-Tab> [:select_prev :snippet_backward :fallback]
                      :<Tab> [:select_next :snippet_forward :fallback]
                      :preset :cmdline}
             :enabled true}

   :completion {:accept {:auto_brackets {:enabled true}}
                :documentation {:auto_show true
                                :auto_show_delay_ms 250
                                :treesitter_highlighting true
                                :window {:border :none}}
                :ghost_text {:enabled true}
                :list {:selection {:auto_insert true :preselect false}}
                :menu {:auto_show true
                       :border :none
                       :min_width 10
                       ;; Cleaned up Fennel logic for cmdline position
                       :cmdline_position (fn []
                                           (if (not= nil vim.g.ui_cmdline_pos)
                                               (let [pos vim.g.ui_cmdline_pos]
                                                 [(- (. pos 1) 1) (. pos 1)])
                                               (let [height (if (= vim.o.cmdheight 0) 1 vim.o.cmdheight)]
                                                 [(- (- vim.o.lines height) 2) 2])))
                       :draw {:columns [[:kind_icon]
                                        {1 :label 2 :label_description :gap 1}
                                        [:source_name]]
                              :components {:kind_icon {:text (fn [ctx]
                                                               (let [lspkind (require :lspkind)]
                                                                 (.. " " (or (. lspkind.symbol_map ctx.kind) "") " ")))}
                                           :label {:text (fn [item] item.label)}
                                           :source_name {:text (fn [ctx] (.. "[" ctx.source_name "]"))}}}}
                       }

   :fuzzy {:implementation :prefer_rust
           :prebuilt_binaries {:download true :force_version :v1.8.0}}

   :keymap {:<CR> [:accept :fallback]
            :<S-Tab> [:select_prev :snippet_backward :fallback]
            :<Tab> [:select_next :snippet_forward :fallback]
            :preset :default}

   :signature {:enabled true}
   :snippets {:preset :luasnip}

   :sources {:default [:lsp :path :snippets :buffer :copilot]
             :per_filetype {:markdown [:snippets :buffer :spell]
                            :fennel [:lsp :path :snippets :buffer :conjure]
                            :clojure [:lsp :path :snippets :buffer :conjure]
                            :neorg [:snippets :buffer :spell]
                            :org [:snippets :buffer :spell]
                            :asciidoc [:snippets :buffer :spell]
                            :yaml [:lsp :snippets]
                            :ledger {:inherit_defaults false 1 :hledger}}
             :providers {:lsp {:fallbacks [:buffer]}
                         :buffer {:score_offset -1 :opts {}}
                         :conjure {:name "conjure"
                                   :module :blink.compat.source
                                   :score_offset 100} ;;

    :copilot {:name "copilot"
              :module :blink-cmp-copilot
              :score_offset 100
              :async true}  :spell {:name "Spell"
                                 :module :blink-cmp-spell
                                 :fallbacks [:buffer]
                                 :opts {}}
                         :hledger {:name "hledger"
                                   :module :blink.compat.source
                                   :score_offset 3
                                   :opts {}}}}})

; (blink.setup opts)
(setup :blink.cmp opts)
