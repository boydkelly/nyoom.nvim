local M = {}

M.prose = function()
	local opt = vim.opt_local
	-- opt_local takes care of both bo and wo
	--
	--   "search in folds doesnt work but defaults include search
	-- vim.bo.fdo:append('search')

	--  "allow cut virtual block mode colonm
	opt.virtualedit = "block"
	opt.textwidth = 0
	opt.wrapmargin = 0
	opt.wrap = true
	opt.linebreak = true --only on word boundries
	--  "make an indent to show wrap
	opt.showbreak = " »"
	opt.breakindent = true
	opt.breakindentopt = "min:20,shift:2,sbr"
	--  "yeah but do we actually need to format lists in asciidoc with vim?
	opt.list = true
	opt.listchars = { tab = "> ", trail = "-", nbsp = "+" }
	opt.smartindent = true

	opt.whichwrap = "b,s,<,>,[,]"
	opt.comments = "://,b:#,:%,b:-,b:*,b:.,:\\|"

	opt.formatoptions = "tcqr"
	--  "lists completion in asciidoc via comments feature
	--  fix vim.bo.comments = '://,b:#,:%,:XCOMM,b:-,b:*,b:.,:\|'

	-- " tc text, comments; (almost) no effect while textwidth=0, but will format
	-- " with gq formatexp
	-- " q enables gq to manually format (with formatexp)
	-- " r automatically insert comment after <Enter> (exactly what we need for
	-- " lists and tables)

	-- " NOT USED BELOW
	-- " o not good puts comment on insert
	-- " n not needed formats numbered list. We let asciidc do the final
	-- " formatting
	-- " j remove comment leader when joining lines.  This is a default with a
	-- " weird effect for us as you can't compete a list properly
	-- "

	-- vim.o.formatlistpat = "\\s*" -- Optional leading white space
	--  "[" -- Start character class
	--  "\\[({]\\?" -- |  Optionally match opening punctuation
	--  "\\(" -- |  Start group
	--  "[0-9]\\+" -- |  |  Numbers
	--  "\\|" -- or
	--  "[a-zA-Z]\\+" -- |  |  Letters
	--  "\\)" -- |  End groupop
	--  "[\\]:.)}" -- |  Closing punctuation
	--  "]" -- End character class
	--  "\\s\\+" -- One or more spaces
	--  "\\|" -- or
	--  "^\\s*[-–+o*•]\\s\\+" -- Bullet points
	vim.opt.formatlistpat = [[\s*\[\({]?\(\d\+\|[a-zA-Z]\+\)[\]:.)}]\s\+\|^\s*[-–+o*•]\s\+]]
end

-- Helper to clear existing mappings safely
local function clear_quote_map()
	if vim.fn.mapcheck('"', "i") ~= "" then
		pcall(vim.api.nvim_del_keymap, "i", '"')
	end
end

function M.set_quotes()
	-- 1. Clear any existing mapping (restores standard quotes)
	clear_quote_map()

	-- 2. Handle nvim-autopairs
	local has_autopairs, autopairs = pcall(require, "nvim-autopairs")
	if has_autopairs then
		local Rule = require("nvim-autopairs.rule")
		autopairs.add_rule(Rule('"', '"'))
	end

	-- 3. Handle mini.pairs
	-- Only run if mini.pairs is actually loaded or available in the package path
	local has_mini = package.loaded["mini.pairs"] or pcall(require, "mini.pairs")

	if has_mini then
		-- Now it's safe to call your helper because we know the plugin exists
		require("setup").mini_pairs("quotes")
	end

	vim.notify("Standard quote input restored", vim.log.levels.INFO)
end

function M.set_guillemets()
	-- 1. Detect and disable standard " for nvim-autopairs
	clear_quote_map()
	local has_autopairs, autopairs = pcall(require, "nvim-autopairs")
	if has_autopairs then
		autopairs.remove_rule('"')
	end

	-- 3. Apply your custom logic
	vim.keymap.set("i", '"', function()
		local col = vim.fn.col(".")
		local prev = vim.fn.getline("."):sub(col - 1, col - 1)
		-- If previous char is not whitespace, close with », else open with «
		return prev:match("%S") and " »" or "« "
	end, { expr = true, desc = "Guillemets (Auto-detected Pair Plugin)" })

	vim.notify("Guillemets input enabled")
end

--- Toggle for manual use or fallback
function M.toggle_guillemets()
	if vim.fn.mapcheck('"', "i") ~= "" then
		M.set_quotes()
	else
		M.set_guillemets()
	end
end

M.scrollbind = function()
	local cur_win = vim.api.nvim_get_current_win()
	vim.wo.scrollbind = true
	vim.o.splitright = true
	vim.cmd("bn") -- Move to next buffer
	vim.wo.scrollbind = true
	vim.api.nvim_set_current_win(cur_win)
end

function M.onesentence_cmd()
	-- Only run in operator-pending mode (e.g. gq)
	if vim.fn.mode():match("^[iR]") then
		return 0
	end

	local start = vim.v.lnum
	local finish = start + vim.v.count - 1

	-- Join the lines
	vim.cmd(string.format("%d,%djoin", start, finish))

	-- Now do the substitution
	vim.cmd([[silent! s/[.:;?!'"”»][ ]\zs\s*\ze\S/\r/g]])

	return 0 -- Required return value for formatexpr
end

function M.onesentence_api()
	if vim.fn.mode():match("^[iR]") then
		return 0
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local start_line = vim.v.lnum - 1 -- Lua indexing is 0-based
	local end_line = start_line + vim.v.count

	-- Get lines and join them
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
	local text = table.concat(lines, " ")

	-- Insert newline after sentence-ending punctuation
	text = text:gsub("([%.:;?!%\"%'”»])%s+(%S)", "%1\n%2")

	-- Replace the original lines
	local new_lines = vim.split(text, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(bufnr, start_line, end_line, false, new_lines)

	return 0
end

function M.asciidoctable()
	-- Get visual range
	local min_space = 3 -- Minimum number of spaces to trigger a column split

	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")

	-- Get lines in selection
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Convert text to table format
	local transformed = {}
	for _, line in ipairs(lines) do
		-- Replace multiple spaces with |
		local converted = line:gsub(string.rep(" ", min_space) .. "+", "|")

		-- Ensure it starts with a single |
		converted = converted:gsub("^%|+", "") -- remove any existing |
		converted = "|" .. converted
		table.insert(transformed, converted)
	end

	-- Table header lines
	local header = {
		'[width="100%",cols="2",frame="topbot",options="header",stripes="even"]',
		"|===",
	}

	local footer = { "|===" }

	-- Replace the visual block with formatted table
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, transformed)

	-- Insert header and footer
	vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, header)
	vim.api.nvim_buf_set_lines(
		0,
		start_line - 1 + #header + #transformed,
		start_line - 1 + #header + #transformed,
		false,
		footer
	)
end
--
-- reqires an unsupported extension
function M.SetUsLayout()
	os.execute("gdbus call --session --dest org.gnome.Shell --object-path /dev/ramottamado/EvalGjs --method dev.ramottamado.EvalGjs.Eval 'imports.ui.status.keyboard.getInputSourceManager().inputSources[0].activate()'")
end

function M.SetCALayout()
	os.execute("gdbus call --session --dest org.gnome.Shell --object-path /dev/ramottamado/EvalGjs --method dev.ramottamado.EvalGjs.Eval 'imports.ui.status.keyboard.getInputSourceManager().inputSources[1].activate()'")
end
--
-- Assuming you have defined these groups globally or can access them by ID
-- in your main autocmds file (like adocGrp = augroup("asciidoc")).
-- We redefine them here so M.buffpairgrp can reliably execute them.
local adocGrp = vim.api.nvim_create_augroup("asciidoc", { clear = false })
local proseGrp = vim.api.nvim_create_augroup("prose_lang", { clear = false })

-- NOTE: Ensure proseGrp and adocGrp are available in this scope (e.g., passed as arguments
-- if required, or defined globally/in the parent module).

M.translate = function()
	-- 1. Get initial context
	local original_buf = vim.api.nvim_get_current_buf()
	local original_win = vim.api.nvim_get_current_win()
	local path = vim.api.nvim_buf_get_name(original_buf)
	local cur_line = vim.api.nvim_win_get_cursor(0)[1]

	local target_path

	-- 2. Determine target path (Logic unchanged)
	if path:match("/fr/") then
		target_path = path:gsub("/fr/", "/dyu/")
	elseif path:match("/dyu/") then
		target_path = path:gsub("/dyu/", "/fr/")
	else
		vim.notify("File path does not contain /fr/ or /dyu/. Translation pair not applicable.", vim.log.levels.INFO)
		return
	end

	-- 3. Check file existence and proceed
	if vim.fn.filereadable(target_path) == 1 then
		-- Split the window (Normal vsplit command)
		vim.cmd("vsplit " .. vim.fn.fnameescape(target_path))
		local target_buf = vim.api.nvim_get_current_buf() -- Focus shifts to New Window

		-- --- 🅰️ APPLY SETTINGS TO NEW BUFFER (target_buf) ---
		-- The split causes BufRead/FileType events to fire for the new buffer,
		-- so we only need to enforce the options that might be overwritten (conceal)
		-- and run our custom groups (gx, spell, path).

		vim.cmd("runtime! plugin/asciidoctor.vim")
		vim.opt_local.conceallevel = 0
		vim.g.asciidoctor_syntax_conceal = 0 -- Re-enforce global variable

		vim.api.nvim_exec_autocmds("BufReadPost", { group = proseGrp, buffer = target_buf, modeline = false })
		vim.api.nvim_exec_autocmds("BufReadPost", { group = adocGrp, buffer = target_buf, modeline = false })

		-- 4. Jump back to the original window (MANDATORY step to apply settings to that window)
		vim.api.nvim_set_current_win(original_win)

		-- --- 6. SCROLLBIND/CURSOR MANAGEMENT ---
		local target_win_id = nil
		for _, win_id in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win_id) == target_buf then
				target_win_id = win_id
				break
			end
		end

		if target_win_id then
			-- Switch to the target window (final focus for scrollbind setup)
			vim.api.nvim_set_current_win(target_win_id)

			-- Set cursor position
			local target_line_count = vim.api.nvim_buf_line_count(target_buf)
			local new_line = math.min(cur_line, target_line_count)
			vim.api.nvim_win_set_cursor(0, { new_line, 0 })

			-- Set scrollbind options for both windows
			vim.wo.scrollbind = true -- For the currently focused (new) window
			vim.api.nvim_win_set_option(original_win, "scrollbind", true) -- For the original window

			-- Sync the scroll position.
			vim.cmd("normal! zvzz")

			-- Final Focus: The cursor is left on the target window.
		end
	else
		vim.notify("No corresponding file found: " .. target_path, vim.log.levels.WARN)
	end
end

return M
