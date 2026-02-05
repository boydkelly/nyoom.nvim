-- lua/generate_unicode_ref.lua
local M = {}
-- Expose it as a Neovim command with no arguments
vim.api.nvim_create_user_command("GenerateUnicodeData", function()
  M.gen_unicode_data()
end, {})

function M.gen_unicode_data()
  local base_dir = vim.fn.stdpath "data" .. "/site/unicode/"
  local input_filepath = base_dir .. "UnicodeData.txt"
  local output_filepath = base_dir .. "UnicodeRef.csv"

  vim.notify "Attempting to generate Unicode reference file..."
  vim.notify("Input file: " .. input_filepath)
  vim.notify("Output file: " .. output_filepath)

  local input_file = io.open(input_filepath, "r")
  if not input_file then
    vim.notify("Error: Could not open input file " .. input_filepath .. ". Make sure it exists.")
    return
  end

  local output_file = io.open(output_filepath, "w")
  if not output_file then
    vim.notify("Error: Could not open output file for writing " .. output_filepath .. ". Check permissions.")
    input_file:close()
    return
  end

  -- Write CSV header
  output_file:write "HexCode,        Character,    Description\n"

  local line_count = 0
  local processed_count = 0

  for line in input_file:lines() do
    line_count = line_count + 1

    -- Skip lines that don't start with a hex code OR contain "<control>"
    if line:match "^%x+" and not line:match "<control>" then
      local parts = vim.split(line, ";", { plain = true })
      if #parts >= 2 then
        local hex_code = parts[1]
        local char_desc = parts[2]

        local code_point_int = tonumber(hex_code, 16)
        local unicode_char = vim.fn.nr2char(code_point_int)

        -- Escape commas in the descriptio2934n
        char_desc = char_desc:gsub(",", "\\,")

        -- Proper CSV: hex_code, character, description
        local csv_line = string.format("%s            ,%s,    %s\n", hex_code, unicode_char, char_desc)

        output_file:write(csv_line)
        processed_count = processed_count + 1
      end
    end
  end

  -- for line in input_file:lines() do
  --   line_count = line_count + 1
  --   -- Skip empty lines or comments (lines starting with '#')
  --   if line:match "^%x+" then -- Check if line starts with hex (a code point entry)
  --     local parts = vim.split(line, ";", { plain = true })
  --     if #parts >= 2 then
  --       local hex_code = parts[1]
  --       local char_name = parts[2]
  --
  --       local code_point_int = tonumber(hex_code, 16)
  --       local unicode_char = vim.fn.nr2char(code_point_int)
  --
  --       -- Basic escaping for commas in the description.
  --       char_name = char_name:gsub(",", "\\,")
  --
  --       -- Format: HexCodePoint,Character,Description
  --       local csv_line = string.format("%s,%s,%s\n", hex_code, unicode_char, char_name)
  --       output_file:write(csv_line)
  --       processed_count = processed_count + 1
  --     end
  --   end
  -- end

  input_file:close()
  output_file:close()

  vim.notify(
    string.format(
      "Generated '%s' with %d entries from '%s' (%d total lines read).",
      output_filepath,
      processed_count,
      input_filepath,
      line_count
    )
  )
end
return M
