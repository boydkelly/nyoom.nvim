-- Treesitter textobjects dependency is a local plugin but proxied to nvim-treesitter-textobjects
-- this is to improve readibility iin the treesitter dependencies.
--
-- To recompile everything, delete all from these 2 directories:
--   * ~/.local/share/nvim/site/parser/
--   * ~/.local/share/nvim/site/queries/
--
-- Additional Refs:
--   * https://github.com/ThorstenRhau/neovim/blob/main/lua/optional/treesitter.lua

local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

local ignore_filetypes = {
	"checkhealth",
	"blink-cmp-menu",
	"fidget",
	"mason",
	"mason_backdrop",
}

-- Auto-install parsers and enable highlighting on FileType
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Enable treesitter highlighting and indentation",
	callback = function(event)
		if vim.tbl_contains(ignore_filetypes, event.match) then
			return
		end

		local lang = vim.treesitter.language.get_lang(event.match) or event.match
		local buf = event.buf

		-- Start highlighting immediately (works if parser exists)
		pcall(vim.treesitter.start, buf, lang)

		-- Enable treesitter indentation
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		-- Install missing parsers (async, no-op if already installed)
	end,
})
