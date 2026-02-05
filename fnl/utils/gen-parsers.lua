-- gen-parsers.lua
local file_path = arg[1] or "parsers.lua"
local p = dofile(file_path)

for lang, spec in pairs(p) do
  local i = spec.install_info
  if i and i.url and i.revision then
    print(lang .. "\t" .. i.url .. "\t" .. i.revision)
  elseif lang == "ecma" then
    -- Provide placeholders so the bash loop still sees the entry
    print(lang .. "\tVIRTUAL\tVIRTUAL")
  end
end
