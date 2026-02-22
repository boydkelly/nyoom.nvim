(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :boydkelly/vim-asciidoctor
              {:nyoom-module lang.asciidoc
               :version :asciidoc
               :before :lang.asciidoc.before
               :ft [:asciidoc :asciidoctor]})
