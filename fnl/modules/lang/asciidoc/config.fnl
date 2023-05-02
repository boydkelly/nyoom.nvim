(import-macros {: set! : map! } :macros)
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
(set! vim.o.spell true)
(map! [v] :t":lua require('utils.functions').asciidoctable()<cr>" )
(set! vim.wo.foldmethod :syntax)
(set! vim.wo.foldenable false)
(set! vim.g.asciidoctor_executable :asciidoctor)
(set! vim.g.asciidoctor_pdf_executable :asciidoctor-pdf)
(set! vim.g.asciidoctor_pdf_themes_path "~/_resources/themes")
(set! vim.g.asciidoctor_pdf_fonts_path "~/_resources/fonts")
(set! vim.g.asciidoctor_pandoc_executable :pandoc)
(set! vim.g.asciidoctor_pandoc_reference_doc :reference.docx)
(set! vim.g.asciidoctor_folding 1)
(set! vim.g.asciidoctor_fold_options 0)
(set! vim.g.asciidoctor_syntax_conceal 1)
(set! vim.g.asciidoctor_syntax_indented 1)
(set! vim.g.asciidoctor_fenced_languages [:css :html :bash :vim])
(vim.cmd "syntax match normal /^= / conceal")
