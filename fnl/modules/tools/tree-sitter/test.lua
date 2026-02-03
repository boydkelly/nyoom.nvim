-- Treesitter textobjects dependency is a local plugin but proxied to nvim-treesitter-textobjects
-- this is to improve readibility iin the treesitter dependencies.
--
-- To recompile everything, delete all from these 2 directories:
--   * ~/.local/share/nvim/site/parser/
--   * ~/.local/share/nvim/site/queries/
--
-- Additional Refs:
--   * https://github.com/ThorstenRhau/neovim/blob/main/lua/optional/treesitter.lua

return {
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-context",
				opts = {
					max_lines = 4,
					multiline_threshold = 2,
				},
			},
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
				init = function()
					-- Disable entire built-in ftplugin mappings to avoid conflicts.
					-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
					vim.g.no_plugin_maps = true

					-- Or, disable per filetype (add as you like)
					-- vim.g.no_python_maps = true
					-- vim.g.no_ruby_maps = true
					-- vim.g.no_rust_maps = true
					-- vim.g.no_go_maps = true
				end,
				config = function()
					require("plugins.code.treesitter_textobjects_keymaps").setup()
				end,
			},
		},
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.install({
				"bash",
				"c",
				"comment",
				"cmake",
				"diff",
				"dockerfile",
				"editorconfig",
				"git_config",
				"git_rebase",
				"gitcommit",
				"gitignore",
				"go",
				"gomod",
				"gotmpl",
				"html",
				"java",
				"javascript",
				"jq",
				"json",
				"just",
				"kotlin",
				"latex",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"rust",
				"scala",
				"sql",
				"terraform",
				"toml",
				"vim",
				"vimdoc",
			}, {
				max_jobs = 8,
			})

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
					ts.install({ lang })
				end,
			})
		end,
	},
}
