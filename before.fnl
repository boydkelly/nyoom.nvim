(when vim.b.did_ftplugin_adoc
  (lua "return "))

(set vim.b.did_ftplugin_adoc 1)

(local opts {:buffer true :noremap true :silent true})

(vim.notify "Appplying settings for asciidoc")

(set vim.opt_local.formatexpr "v:lua.require'utils.prose'.onesentence_api()")

(set vim.opt_local.spell true)

(set vim.wo.foldmethod :syntax)

(set vim.wo.foldenable false)

(set vim.wo.virtualedit :block)

(set vim.bo.textwidth 0)

(set vim.bo.wrapmargin 2)

(set vim.wo.wrap true)

(set vim.wo.linebreak true)

(set vim.opt_local.whichwrap "b,s,<,>,[,]")

(set vim.wo.showbreak " »")

(set vim.wo.breakindent true)

(set vim.wo.breakindentopt "min:20,shift:2,sbr")

(set vim.wo.listchars "tab:> ,trail:-,nbsp:+")

(set vim.o.list true)

(set vim.bo.formatoptions :tcqr)

(set vim.bo.smartindent true)

(set vim.opt_local.formatlistpat "\\s*")

(vim.opt_local.formatlistpat:append "[")

(vim.opt_local.formatlistpat:append "\\[({]\\?")

(vim.opt_local.formatlistpat:append "\\(")

(vim.opt_local.formatlistpat:append "[0-9]\\+")

(vim.opt_local.formatlistpat:append "\\|")

(vim.opt_local.formatlistpat:append "[a-zA-Z]\\+")

(vim.opt_local.formatlistpat:append "\\)")

(vim.opt_local.formatlistpat:append "[\\]:.)}")

(vim.opt_local.formatlistpat:append "]")

(vim.opt_local.formatlistpat:append "\\s\\+")

(vim.opt_local.formatlistpat:append "\\|")

(vim.opt_local.formatlistpat:append "^\\s*[-–+o*•]\\s\\+")

(vim.cmd "syntax match normal /^= / conceal")

(vim.keymap.set :v :t ":lua require('utils.prose').asciidoctable()<cr>" opts)

(vim.keymap.set :n :<leader>mor :<cmd>AsciidocOpenRAW<cr>
                (vim.tbl_extend :force opts {:desc "Open raw"}))

(vim.keymap.set :n :<leader>mop :<cmd>AsciidocOpenPDF<cr>
                (vim.tbl_extend :force opts {:desc "Open pdf"}))

(vim.keymap.set :n :<leader>moh :<cmd>AsciidocOpenHTML<cr>
                (vim.tbl_extend :force opts {:desc "Open html"}))

(vim.keymap.set :n :<leader>mod :<cmd>AsciidocOpenDOCX<cr>
                (vim.tbl_extend :force opts {:desc "Open docx"}))

(vim.keymap.set :n :<leader>mch :<cmd>Asciidoc2HTML<cr>
                (vim.tbl_extend :force opts {:desc "Convert html"}))

(vim.keymap.set :n :<leader>mcp :<cmd>Asciidoc2PDF<cr>
                (vim.tbl_extend :force opts {:desc "Convert pdf"}))

(vim.keymap.set :n :<leader>mcd :<cmd>Asciidoc2DOCX<cr>
                (vim.tbl_extend :force opts {:desc "Convert docx"}))

(vim.keymap.set :n :<leader>mp :<cmd>AsciidocPastImage<cr>
                (vim.tbl_extend :force opts {:desc "Paste image"}))

(set vim.g.asciidoctor_executable :asciidoctor)

(set vim.g.asciidoctor_pdf_executable :asciidoctor-pdf)

(set vim.g.asciidoctor_pdf_themes_path "~/_resources/themes")

(set vim.g.asciidoctor_pdf_fonts_path "~/_resources/fonts")

(set vim.g.asciidoctor_pandoc_executable :pandoc)

(set vim.g.asciidoctor_pandoc_reference_doc :reference.docx)

(set vim.g.asciidoctor_folding 1)

(set vim.g.asciidoctor_fold_options 0)

(set vim.g.asciidoctor_syntax_conceal 2)

(set vim.g.asciidoctor_syntax_indented 1)

(set vim.g.asciidoctor_fenced_languages [:css :html :bash :vim])

(set vim.opt_local.conceallevel 2)

