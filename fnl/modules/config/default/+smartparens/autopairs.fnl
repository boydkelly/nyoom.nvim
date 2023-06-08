((. (require :nvim-autopairs) 
    :setup) 
 {
 :check_ts true
 :enable_check_bracket_line false
 :ignored_next_char "[%w%.]"
 :ts_config {:java false
 :javascript [:template_string]
 :lua [:string]}
 })

((. (require :cmp) :setup) {})
(local cmp-autopairs (require :nvim-autopairs.completion.cmp))
(local cmp (require :cmp))
(cmp.event:on :confirm_done
              (cmp-autopairs.on_confirm_done {:map_char {:tex ""}})))
:event :InsertEnter}]

