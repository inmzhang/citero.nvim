local M = {}

M.notify = function(message, level)
  level = level or vim.log.levels.INFO
  vim.notify('Citero: ' .. message, level)
end

M.normalize_path = function(path)
  if not path then
    return nil
  end

  -- Expand ~ and environment variables
  path = vim.fn.expand(path)

  -- Normalize the path
  return vim.fs.normalize(path)
end

M.file_exists = function(path)
  return path and vim.fn.filereadable(path) == 1
end

M.directory_exists = function(path)
  return path and vim.fn.isdirectory(path) == 1
end

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

M.validate_config = function(config)
  local required_paths = {
    'zotero_storage_path',
    'note_taking_path',
  }

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
