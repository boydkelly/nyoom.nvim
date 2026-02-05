local config_root = vim.fn.stdpath "config"
local source_dir = config_root .. "/lua/specs"
local dest_dir = config_root .. "/lua/lz_specs"
vim.fn.mkdir(dest_dir, "p")

-- Extract plugin name from "owner/plugin.nvim" or "plugin.nvim"
local function get_plugin_name(entry_string)
  -- Match '"owner/plugin.nvim"' or '"plugin.nvim"'
  local owner_plugin = entry_string:match('"[^"]*/([^"]+)"')
  local plugin_only = entry_string:match('"([^"/]+)"') -- Match plugin.nvim directly

  if owner_plugin then
    return owner_plugin
  elseif plugin_only then
    return plugin_only
  end
  return "unknown_plugin" -- Default if no name found
end

-- Generate after = function() require("setup.name") end
local function build_after_block(name)
  name = name:gsub("%.nvim$", "")
  return string.format(
    [[after = function()
  require("setup.%s")
end,]],
    name
  )
end

-- Convert a single plugin block
-- This function now returns the converted block string AND a table of its flattened dependencies.
local function convert_plugin_block(block_content)
  -- The input `block_content` is the string content *inside* the outer `{}` of a plugin spec.
  -- Example: '"marioortizmanero/adoc-pdf-live.nvim", ft = "asciidoc", ...'

  local plugin_identifier_match = block_content:match('"[^"]+"')
  if not plugin_identifier_match then
      -- vim.notify("Could not find plugin identifier in block: " .. block_content:sub(1, 100) .. "...", vim.log.levels.WARN)
      return nil, {} -- Cannot process if no plugin identifier, return empty deps
  end

  local plugin_name = get_plugin_name(plugin_identifier_match)
  local short_name = plugin_name:gsub("%.nvim$", "")

  -- Prepare lines for the new block
  local new_lines = {}
  table.insert(new_lines, string.format('"%s",', plugin_name))
  table.insert(new_lines, build_after_block(short_name))

  -- Remove the initial plugin identifier from the block content as we've processed it
  block_content = block_content:gsub(plugin_identifier_match .. ",%s*", "", 1) -- Remove "plugin_id",

  -- **Refined Config Removal (Line-by-Line with Nesting)**
  local temp_block_lines = vim.split(block_content, '\n')
  local cleaned_content_lines = {}
  local in_config_block = false
  local config_brace_level = 0 -- To track { } nesting within the config block

  for i, line in ipairs(temp_block_lines) do
      local trimmed_line = line:match("^%s*(.*)$") -- trim leading whitespace

      if in_config_block then
          -- Update brace level
          config_brace_level = config_brace_level + select(2, line:gsub("{", "{"))
          config_brace_level = config_brace_level - select(2, line:gsub("}", "}"))

          -- Check for the 'end' that closes the config function (at logical level 0 for its braces)
          if trimmed_line:match("^end%s*[,}]?$") and config_brace_level <= 0 then
              in_config_block = false
              -- Do NOT add this 'end' line to cleaned_content_lines as it's part of the removed block
          end
          -- If `in_config_block` is true, we simply skip adding the line.
      else
          -- If not in a config block, check if we're starting one
          if trimmed_line:match("^config%s*=%s*function%s*%b()%s*$") then
              in_config_block = true
              config_brace_level = 0 -- Reset level for this config block
              -- If the config function definition itself has braces, count them.
              config_brace_level = config_brace_level + select(2, line:gsub("{", "{"))
              config_brace_level = config_brace_level - select(2, line:gsub("}", "}"))
          else
              -- Add the line if it's not part of a config block
              table.insert(cleaned_content_lines, line)
          end
      end
  end
  block_content = table.concat(cleaned_content_lines, '\n')

  -- **Handling Dependencies (Robust Extraction and Flattening)**
  local extracted_deps = {}
  local dependency_pattern = "dependencies%s*=%s*({%b})%s*[,}]?" -- Matches the full dependencies table

  -- Use a loop with `gmatch` to process the block string piece by piece
  -- This allows us to handle non-dependency fields more easily too.
  local remaining_block_parts = {}
  local last_pos = 1
  for match_start, match_end, dep_full_str in block_content:gmatch("()(" .. dependency_pattern .. ")()") do
      -- Add content before this dependency block
      table.insert(remaining_block_parts, block_content:sub(last_pos, match_start - 1))

      -- Process the dependency block
      local dep_table_content = dep_full_str:match(dependency_pattern) -- Extract inner part of `({%b})`
      if dep_table_content then
          -- Remove outer curly braces for easier internal matching
          local inner_deps_str = dep_table_content:sub(2, -2) -- Remove outer {}

          -- Now, parse `inner_deps_str` for individual dependencies (strings or tables)
          local current_item_pos = 1
          while current_item_pos <= #inner_deps_str do
              local item_str_match, item_end_pos

              -- Try to match a table `{...}` first (for complex dependencies)
              item_str_match, item_end_pos = inner_deps_str:match("()%s*({%b})%s*[,}]?()", current_item_pos)
              if item_str_match then
                  local converted_dep_block, nested_sub_deps = convert_plugin_block(item_str_match:sub(2,-2)) -- Recurse
                  if converted_dep_block then
                      table.insert(extracted_deps, converted_dep_block)
                  end
                  -- If nested_sub_deps exist, add them to `extracted_deps` too for full flattening.
                  for _, sub_dep in ipairs(nested_sub_deps) do
                      table.insert(extracted_deps, sub_dep)
                  end
                  current_item_pos = item_end_pos + 1
                  goto continue_parsing_deps
              end

              -- Try to match a string `"[...]" ` (for simple dependencies)
              item_str_match, item_end_pos = inner_deps_str:match("()%s*(\"[^\"]+\")%s*[,}]?()", current_item_pos)
              if item_str_match then
                  local plugin_name_from_simple = get_plugin_name(item_str_match)
                  local short_name_from_simple = plugin_name_from_simple:gsub("%.nvim$", "")
                  table.insert(extracted_deps, string.format('  {\n    "%s",\n    %s\n  }', plugin_name_from_simple, build_after_block(short_name_from_simple)))
                  current_item_pos = item_end_pos + 1
                  goto continue_parsing_deps
              end

              -- No match, move to next character to avoid infinite loop
              current_item_pos = current_item_pos + 1
              ::continue_parsing_deps::
          end
      end

      last_pos = match_end + 1 -- Update last_pos to continue after this dependency block
  end
  table.insert(remaining_block_parts, block_content:sub(last_pos)) -- Add any remaining content
  block_content = table.concat(remaining_block_parts, '') -- Reconstruct block_content without dependencies

  -- **Extracting Remaining Fields (e.g., lazy, event, opts_extend, version)**
  local added_fields_tracker = {}
  local lines_for_field_extraction = vim.split(block_content, '\n')

  for _, line in ipairs(lines_for_field_extraction) do
      -- Matches: key = "string", key = word, key = {balanced_table}
      -- Prioritize matching a full table `{}` for value.
      local key_match, val_match_full_table, val_match_string, val_match_word
      local matched_key, matched_value_str

      -- Attempt to match key = { ... }
      key_match, val_match_full_table = line:match("^(%s*[%w_]+%s*=%s*)({%b})%s*[,}]?$")
      if key_match then
          matched_key = key_match:match("^%s*([%w_]+)")
          matched_value_str = val_match_full_table
      else
          -- Attempt to match key = "string"
          key_match, val_match_string = line:match("^(%s*[%w_]+%s*=%s*)(\"[^\"]*\"%s*)[,]?$")
          if key_match then
              matched_key = key_match:match("^%s*([%w_]+)")
              matched_value_str = val_match_string:match("^%s*(.*)$") -- Get the matched string value
          else
              -- Attempt to match key = word (number, boolean)
              key_match, val_match_word = line:match("^(%s*[%w_]+%s*=%s*)([%w_]+%s*)[,]?$")
              if key_match then
                  matched_key = key_match:match("^%s*([%w_]+)")
                  matched_value_str = val_match_word:match("^%s*(.*)$") -- Get the matched word value
              end
          end
      end

      if matched_key and not added_fields_tracker[matched_key] then
          -- Skip common fields that might be re-added or are part of special logic
          if matched_key ~= "version" then -- We standardize version later
              table.insert(new_lines, string.format("%s = %s,", matched_key, matched_value_str:gsub("%s*$", ""))) -- Trim trailing whitespace from value
              added_fields_tracker[matched_key] = true
          end
      end
  end

  -- Ensure 'version = "*",' is added if not present (or adjust as needed)
  if not added_fields_tracker.version then
      table.insert(new_lines, 'version = "*",')
  end

  return "  {\n    " .. table.concat(new_lines, "\n    ") .. "\n  }", extracted_deps
end

-- extract_dependencies is effectively superseded by logic within convert_plugin_block
-- Keeping it as a placeholder or for potential future use, but its core work is now integrated.
local function extract_dependencies(text)
  local out = {}
  local cleaned = text:gsub("dependencies%s*=%s*{(.-)}", function(dep_block)
    -- This logic has been moved to convert_plugin_block
    return "" -- Simply remove the block from the main text
  end)
  return cleaned, out -- Returns empty out, as logic is moved.
end

-- Convert a full plugin spec file
local function convert_file(src, dst)
  local lines = {}
  for line in io.lines(src) do
    table.insert(lines, line)
  end
  local content = table.concat(lines, "\n")

  content = content:gsub("%-%-.*", "") -- remove comments

  local output = { "return {\n" }
  local all_extracted_deps = {} -- To collect all dependencies from top-level and nested plugins

  -- Modified: Use {%b} to match outermost plugin blocks robustly
  -- This matches `{` followed by any characters until a balanced `}` is found.
  for block_str in content:gmatch("{%b}") do
    -- Remove the outermost curly braces from the captured block_str
    local inner_block_content = block_str:sub(2, -2) -- Remove the `{` and `}`

    -- Call convert_plugin_block, which now also returns dependencies
    local converted_main_block, block_deps = convert_plugin_block(inner_block_content)
    if converted_main_block then
      table.insert(output, converted_main_block .. ",\n")
      -- Add any dependencies found within this block to the global list
      for _, dep_item in ipairs(block_deps) do
          table.insert(all_extracted_deps, dep_item .. ",\n")
      end
    end
  end

  -- Add all collected flattened dependencies at the end of the return table
  for _, dep_block in ipairs(all_extracted_deps) do
    table.insert(output, dep_block)
  end

  table.insert(output, "}\n")

  local f = io.open(dst, "w")
  if f then
    f:write(table.concat(output))
    f:close()
  else
    vim.notify("Failed to write to " .. dst, vim.log.levels.ERROR)
  end
end

-- Run over all plugin files
for _, src in ipairs(vim.fn.glob(source_dir .. "/*.lua", true, true)) do
  local dst = dest_dir .. "/" .. vim.fn.fnamemodify(src, ":t")
  convert_file(src, dst)
end

vim.notify "Plugin specs converted to lz_specs/"
