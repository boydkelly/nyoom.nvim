(import-macros {: set! : local-set! : map! } :macros)
(local {: register} (autoload :which-key))

(register {:<leader> {:n {:a {:c {:d [:<cmd>Asciidoc2DOCX<CR> "Convert to docx"]
          :h [:<cmd>Asciidoc2HTML<CR>
               "Convert html"]
          :name :+Convert
          :p [:<cmd>Asciidoc2PDF<CR>
               "Convert pdf"]}
          :i [:<cmd>AsciidocPasteImage<CR>
               "Paste Image"]
          :name :+AsciiDoc
          :o {:d [:<cmd>AsciidocOpenDOCX<CR>
                   "Open docx"]
          :h [:<cmd>AsciidocOpenHTML<CR>
               "Open html"]
          :name :+Open
          :p [:<cmd>AsciidocOpenPDF<CR>
               "Open pdf"]
          :r [:<cmd>AsciidocOpenRAW<cr>
               "Open raw"]}}}}})
(local-set! spell)
(map! [v] :t":lua require('utils.functions').asciidoctable()<cr>" )
(local-set! foldmethod :syntax)
(local-set! foldenable false)
(tset vim.g :asciidoctor_executable "asciidoctor")
(tset vim.g :asciidoctor_pdf_executable "asciidoctor-pdf")
(tset vim.g :asciidoctor_pdf_themes_path "~/_resources/themes")
(tset vim.g :asciidoctor_pdf_fonts_path "~/_resources/fonts")
(tset vim.g :asciidoctor_pandoc_executable "pandoc")
(tset vim.g :asciidoctor_pandoc_reference_doc "reference.docx")
(tset vim.g :asciidoctor_folding 1)
(tset vim.g :asciidoctor_fold_options 0)
(tset vim.g :asciidoctor_syntax_conceal 1)
(tset vim.g :asciidoctor_syntax_indented 1)
(tset vim.g :asciidoctor_fenced_languages [:css :html :bash :vim])
(vim.cmd "syntax match normal /^= / conceal")
