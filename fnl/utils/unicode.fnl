(local M {})

(vim.api.nvim_create_user_command :GenerateUnicodeData
                                  (fn []
                                    (M.gen_unicode_data))
                                  {})

(fn M.gen_unicode_data []
  (let [base-dir (.. (vim.fn.stdpath :data) :/site/unicode/)
        input-filepath (.. base-dir :UnicodeData.txt)
        output-filepath (.. base-dir :UnicodeRef.csv)]
    (vim.notify "Attempting to generate Unicode reference file...")
    (vim.notify (.. "Input file: " input-filepath))
    (vim.notify (.. "Output file: " output-filepath))
    (local input-file (io.open input-filepath :r))
    (when (not input-file)
      (vim.notify (.. "Error: Could not open input file " input-filepath
                      ". Make sure it exists."))
      (lua "return "))
    (local output-file (io.open output-filepath :w))
    (when (not output-file)
      (vim.notify (.. "Error: Could not open output file for writing "
                      output-filepath ". Check permissions."))
      (input-file:close)
      (lua "return "))
    (output-file:write "HexCode,        Character,    Description\n")
    (var line-count 0)
    (var processed-count 0)
    (each [line (input-file:lines)]
      (set line-count (+ line-count 1))
      (when (and (line:match "^%x+") (not (line:match :<control>)))
        (local parts (vim.split line ";" {:plain true}))
        (when (>= (length parts) 2)
          (local hex-code (. parts 1))
          (var char-desc (. parts 2))
          (local code-point-int (tonumber hex-code 16))
          (local unicode-char (vim.fn.nr2char code-point-int))
          (set char-desc (char-desc:gsub "," "\\,"))
          (local csv-line
                 (string.format "%s            ,%s,    %s\n" hex-code
                                unicode-char char-desc))
          (output-file:write csv-line)
          (set processed-count (+ processed-count 1)))))
    (input-file:close)
    (output-file:close)
    (vim.notify (string.format "Generated '%s' with %d entries from '%s' (%d total lines read)."
                               output-filepath processed-count input-filepath
                               line-count))))

M

