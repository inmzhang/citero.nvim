---@class CiteroUtilsModule
local M = {}

---Display a notification with Citero prefix
---@param message string Notification message
---@param level? integer Log level (vim.log.levels)
M.notify = function(message, level)
  level = level or vim.log.levels.INFO
  vim.notify('Citero: ' .. message, level)
end

---Normalize file path
---@param path? string File path
---@return string? Normalized path or nil
M.normalize_path = function(path)
  if not path then
    return nil
  end

  -- Expand ~ and environment variables
  path = vim.fn.expand(path)

  -- Normalize the path
  return vim.fs.normalize(path)
end

---Check if file exists
---@param path? string File path
---@return boolean True if file exists and is readable, false otherwise
M.file_exists = function(path)
  return path and vim.fn.filereadable(path) == 1 or false
end

---Check if directory exists
---@param path? string Directory path
---@return boolean True if directory exists, false otherwise
M.directory_exists = function(path)
  return path and vim.fn.isdirectory(path) == 1 or false
end

---Get filetype group for citation format
---@param filetype string File type
---@return string Normalized filetype group
M.get_filetype_group = function(filetype)
  local tex_types = { 'tex', 'latex', 'plaintex' }
  local typst_types = { 'typ', 'typst' }

  if vim.tbl_contains(tex_types, filetype) then
    return 'tex'
  elseif vim.tbl_contains(typst_types, filetype) then
    return 'typst'
  else
    return filetype
  end
end

---Validate configuration and show warnings
---@param config table Configuration to validate
M.validate_config = function(config)
  local required_paths = {
    'zotero_storage_path',
    'note_taking_path',
  }

  ---@type string[]
  local warnings = {}

  for _, key in ipairs(required_paths) do
    local path = config[key]
    if path and not M.directory_exists(path) then
      table.insert(warnings, string.format('Directory not found: %s = %s', key, path))
    end
  end

  if #warnings > 0 then
    M.notify('Configuration warnings:\n' .. table.concat(warnings, '\n'), vim.log.levels.WARN)
  end
end

return M
