local M = {}

function M.starter_custom()
	return {
		{
			name = "Recent Files",
			action = function()
				require("mini.extra").pickers.oldfiles()
			end,
			section = "Search",
		},
		{ name = "Projects", action = "Project", section = "Projects" }, -- Runs `:Project`
		{
			name = "Recent Projects",
			action = function()
				require("config.mini.pickers").projects()
			end,
			section = "Projects",
		}, -- `:ProjectRecents`
	}
end

--  ─( Colorscheme Picker )─────────────────────────────────────────────
local set_colorscheme = function(name)
	pcall(vim.cmd, "colorscheme " .. name)
end

M.colorscheme = function()
	local init_scheme = vim.g.colors_name
	local new_scheme = require("mini.pick").start({
		source = {
			items = vim.fn.getcompletion("", "color"),
			preview = function(_, item)
				set_colorscheme(item)
			end,
			choose = set_colorscheme,
		},
		mappings = {
			preview = {
				char = "<C-p>",
				func = function()
					local item = require("mini.pick").get_picker_matches()
					pcall(vim.cmd, "colorscheme " .. item.current)
				end,
			},
		},
	})
	if new_scheme == nil then
		set_colorscheme(init_scheme)
	end
end

M.nvimfiles = function()
	local cwd = vim.fn.stdpath("config")

	local handle = io.popen("fd --max-depth 4 --type f --print0 --base-directory " .. cwd)
	if not handle then
		vim.notify("Failed to run fd command.", vim.log.levels.ERROR)
		return
	end

	local file_paths = {}
	local output = handle:read("*a")
	handle:close()

	file_paths = vim.split(output, "\0", { plain = true })

	require("mini.pick").start({
		source = {
			name = "Neovim config files",
			cwd = cwd,
			items = file_paths,
			choose = function(selected_path)
				vim.cmd("edit " .. selected_path)
			end,
		},
	})
end

M.xgdfiles = function()
	local cwd = vim.env.HOME .. "/.config"

	local handle = io.popen("fd --max-depth 4 --type f --print0 --base-directory " .. cwd)
	if not handle then
		vim.notify("Failed to run fd command.", vim.log.levels.ERROR)
		return
	end

	local output = handle:read("*a")
	handle:close()

	local file_paths = {}
	file_paths = vim.split(output, "\0", { plain = true })

	require("mini.pick").start({
		source = {
			name = "XGD config files",
			cwd = cwd,
			items = file_paths,
			choose = function(selected_path)
				-- 'selected_path' will be the full path from 'fd'
				vim.cmd("edit " .. selected_path)
			end,
		},
	})
end

local function abs(cwd, path)
	return cwd .. "/" .. path
end

M.readme = function()
	local data_path = vim.fn.stdpath("data")

	require("mini.pick").builtin.cli({
		command = { "fd", "^README", "-i", "-H", "-I", "-t", "f" },
		options = { cwd = data_path },
	}, {
		source = {
			name = "Plugin Readmes",
			cwd = data_path,
			choose = function(item)
				-- Ensure we have a clean absolute path
				local full_path = vim.fs.normalize(data_path .. "/" .. item)

				-- Schedule the edit to ensure it triggers outside the picker's render loop
				vim.schedule(function()
					vim.cmd("edit " .. vim.fn.fnameescape(full_path))
				end)
			end,
		},
	})
end

M.recent_icons = function()
	local pick = require("mini.pick")
	local micons = require("mini.icons")

	-- Only readable files
	local items = vim.tbl_filter(vim.fn.filereadable, vim.v.oldfiles)

	-- Map to picker entries with filetype icon + hl

	local entries = vim.tbl_map(function(path)
		-- Detect filetype
		local ft = vim.filetype.match({ filename = path }) or "" -- fallback to empty string
		local icon, icon_hl = micons.get("filetype", ft) -- now safe
		return {
			text = (icon or "") .. " " .. path,
			hl = icon_hl,
		}
	end, items)

	pick.start({
		source = {
			name = "Recent files",
			items = entries,
			match = function(item, query)
				return pick.default_match(item.text, query)
			end,
			preview = function(item)
				return pick.preview_file(item.path)
			end,
			choose = function(item)
				return pick.choose_file(item.path)
			end,
		},
		on_draw_item = function(bufnr, item, idx)
			if item.hl then
				vim.api.nvim_buf_add_highlight(bufnr, -1, item.hl, idx - 1, 0, #(item.text:match("^%S+")))
			end
		end,
	})
end

M.recent = function()
	local pick = require("mini.pick")

	local items = vim.tbl_filter(function(f)
		return vim.fn.filereadable(f) == 1
	end, vim.v.oldfiles)

	pick.start({
		source = {
			name = "Recent files",
			items = items,
			match = pick.default_match,
			preview = pick.preview_file,
			choose = pick.choose_file,
		},
	})
end

function M.spellsuggest()
	local pick = require("mini.pick")
	local original_win = vim.api.nvim_get_current_win()
	local word = vim.fn.expand("<cword>")

	-- get screen position for floating window
	local function get_screen_pos()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local pos = vim.fn.screenpos(0, row, col + 1)
		return pos.row, pos.col
	end

	local screen_row, screen_col = get_screen_pos()
	local total_lines = vim.o.lines
	local height = 6
	local fits_below = (screen_row + height + 2 < total_lines)

	pick.start({
		source = {
			name = "Spelling suggestions",
			items = vim.fn.spellsuggest(word),

			choose = function(item)
				vim.api.nvim_win_call(original_win, function()
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))
					local line = vim.api.nvim_get_current_line()
					local word = vim.fn.expand("<cword>")

					-- find exact byte positions of <cword> in the line
					local s, e = line:find(vim.pesc(word), 1, true)
					if s then
						vim.api.nvim_buf_set_text(
							0,
							row - 1, -- line index
							s - 1, -- start col (0-based)
							row - 1, -- line index
							e, -- end col (0-based)
							{ item } -- replacement
						)
					end
				end)
			end,
		},

		prompt = "Correct spelling",
		window = {
			config = function()
				return {
					anchor = "NW",
					border = "single",
					height = height,
					width = math.floor(vim.o.columns * 0.28),
					row = fits_below and screen_row or (screen_row - height - 1),
					col = screen_col - 1,
				}
			end,
		},
	})
end

function M.unicode_characters()
	local unicode_csv = vim.fn.stdpath("data") .. "/site/unicode/UnicodeRef.csv"

	-- Load CSV
	local unicode_data = {}
	for line in io.lines(unicode_csv) do
		local code, char, desc = line:match("([^,]+),([^,]+),(.+)")
		if code and char and desc then
			table.insert(unicode_data, {
				id = code, -- required
				text = code .. " " .. char .. " " .. desc, -- fallback
				code = code,
				char = char,
				desc = desc,
			})
		end
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	require("mini.pick").start({
		backend = "fzf",
		source = {
			name = "Unicode characters",
			items = unicode_data,

			search = function(item, query)
				query = (query or ""):lower()
				return item.char:lower():find(query, 1, true)
					or item.code:lower():find(query, 1, true)
					or item.desc:lower():find(query, 1, true)
			end,

			choose = function(selection)
				vim.notify(vim.inspect(selection))
				if selection and selection.char then
					vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { selection.char })
				end
			end,
		},
		window = {
			-- Float window config (table or callable returning it)
			config = nil,

			-- String to use as caret in prompt
			prompt_caret = "▏",

			-- String to use as prefix in prompt
			prompt_prefix = "> ",
		},
	})
end

local win_config = function()
	local height = math.floor(0.618 * vim.o.lines)
	local width = math.floor(0.6 * vim.o.columns)
	return {
		anchor = "NW",
		height = height,
		width = width,
		border = "none",
		row = math.floor(0.5 * (vim.o.lines - height)),
		col = math.floor(0.5 * (vim.o.columns - width)),
	}
end

function M.projects()
	local recent_projects = require("project").get_recent_projects()

	local function format_for_display(project_path)
		local name = project_path:match("/([^/]+)$") or project_path
		return name, string.format("%-30s %s", name, project_path)
	end

	recent_projects = vim.tbl_reverse(recent_projects)

	local projects_display = {}
	local projects_data = {}

	for _, project_path in ipairs(recent_projects) do
		local name, display = format_for_display(project_path)
		table.insert(projects_display, display)
		projects_data[display] = { name = name, path = project_path }
	end

	require("mini.pick").start({
		-- window = {
		--   config = {
		--     border = "none",
		--     anchor = "NW",
		--     col = 0,
		--     row = 0,
		--     -- width = 40, -- Reduced width
		--     -- height = 10, -- Reduced height
		--   },
		-- },
		source = {
			name = "Projects",
			items = projects_display,
			choose = function(selection)
				local data = projects_data[selection]
				if not data or not data.path then
					return
				end

				local target_cwd = data.path
				vim.schedule(function()
					vim.fn.chdir(target_cwd)
					require("mini.pick").builtin.files(nil, {
						source = { name = "Files in " .. data.name, cwd = target_cwd },
					})
				end)
			end,
		},
		mappings = {
			set_root_on_esc = {
				char = "<Esc>",
				func = function()
					local MiniPick = require("mini.pick")

					-- Access the internal state safely
					local st = MiniPick.get_picker_state()

					-- If the picker is active and has matches
					if st and st.items and st.items.all and st.caret then
						local selection = st.items.all[st.caret]

						-- Check if this string exists in our data map
						local data = projects_data[selection]
						if data and data.path then
							vim.schedule(function()
								vim.cmd("ProjectRoot " .. vim.fn.fnameescape(data.path))
								vim.notify("Root set to: " .. data.path)
							end)
						end
					end

					-- Standard stop call
					return MiniPick.stop()
				end,
			},
		},
	})
end

return M
