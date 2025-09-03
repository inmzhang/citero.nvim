local M = {}

local config = require('citero.config')

local function clean_title(title_block)
  if not title_block then
    return nil
  end

  -- Remove surrounding braces, quotes, and extra whitespace
  local title = title_block:gsub('^[{%s]*', ''):gsub('[}%s]*$', ''):gsub('^"', ''):gsub('"$', '')

  -- Handle LaTeX escape sequences and common formatting
  title = title:gsub('\\%w+%s*', ''):gsub('[{}]', ''):gsub('%s+', ' '):match('^%s*(.-)%s*$')

  return title ~= '' and title or nil
end

local function parse_bib_entry(entry_text)
  -- Match entry type and key
  local entry_type, key = entry_text:match('^@(%w+)%s*{%s*([%w%-%_%.:]+)%s*,')
  if not key then
    return nil
  end

  -- Extract the body (everything after the key)
  local body = entry_text:match('@%w+%s*{%s*[%w%-%_%.:]+%s*,(.-)%s*}%s*$')
  if not body then
    return nil
  end

  -- Try to match title field with various patterns
  local title_block = body:match('[Tt][Ii][Tt][Ll][Ee]%s*=%s*(%b{})')
    or body:match('[Tt][Ii][Tt][Ll][Ee]%s*=%s*"([^"]*)"')
    or body:match('[Tt][Ii][Tt][Ll][Ee]%s*=%s*{([^}]*)}')

  local title = clean_title(title_block)
  if not title then
    return nil
  end

  return {
    key = key,
    type = entry_type:lower(),
    title = title,
    raw = entry_text,
  }
end

M.parse_file = function(file_path)
  if not file_path or vim.fn.filereadable(file_path) ~= 1 then
    return nil, 'BibTeX file not found or not readable: ' .. (file_path or 'nil')
  end

  local file = io.open(file_path, 'r')
  if not file then
    return nil, 'Could not open BibTeX file: ' .. file_path
  end

  local content = file:read('*a')
  file:close()

  if not content or content == '' then
    return nil, 'BibTeX file is empty: ' .. file_path
  end

  local entries = {}

  -- Match complete BibTeX entries
  for entry in content:gmatch('@%w+%s*{[^@]*}') do
    local parsed = parse_bib_entry(entry)
    if parsed then
      table.insert(entries, parsed)
    end
  end

  if #entries == 0 then
    return nil, 'No valid entries found in BibTeX file: ' .. file_path
  end

  return entries
end

M.get_entries = function()
  local bib_path = config.get_bib_path()
  if not bib_path then
    return nil,
      string.format(
        'BibTeX file (%s) not found. Please ensure it exists in current directory or parent directories, or in %s',
        config.get('bib_filename'),
        config.get('note_taking_path')
      )
  end

  return M.parse_file(bib_path)
end

return M
