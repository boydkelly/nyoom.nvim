_G.list_nyoom_mods = function()
	-- Use rawget to safely check the global table for the slash-named key
	local m = _G["nyoom/modules"] or {}
	local names = {}

	-- Extract keys
	for name, _ in pairs(m) do
		table.insert(names, name)
	end

	-- Sort them alphabetically so the list isn't random
	table.sort(names)

	-- Create the string
	local output = table.concat(names, "\n")

	if #names == 0 then
		vim.notify("No modules found in _G['nyoom/modules']", vim.log.levels.WARN)
	else
		vim.notify("Active Modules:\n" .. output, vim.log.levels.INFO)
	end
end
