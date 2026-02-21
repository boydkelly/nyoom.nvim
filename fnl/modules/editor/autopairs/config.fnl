(local {: setup} (require :core.lib.setup))

(local opts {:check_ts true
             :disable_filetype [:asciidoctor :asciidoc :markdown :norg :fennel]
             :enable_check_bracket_line false
             :ignored_next_char "[%w%.]"
             :ts_config {:java false
                         :javascript [:template_string]
                         :lua [:string]}})

(setup :nvim-autopairs opts)

