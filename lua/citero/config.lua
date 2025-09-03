local M = {}

local defaults = {
  zotero_storage_path = vim.fn.expand('~/Zotero/storage'),
  note_taking_path = vim.fn.expand('~/Documents/note-taking'),
  bib_filename = 'zotero.bib',
  keymaps = true,
  citation_formats = {
    tex = '\\cite{%s}',
    latex = '\\cite{%s}',
    typst = '@%s',
  },
  picker = {
    layout = {
      preset = 'default',
      preview = false,
    },
  },
}

local config = vim.deepcopy(defaults)

M.setup = function(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend('force', defaults, opts)

  -- Normalize paths
  config.zotero_storage_path = vim.fs.normalize(config.zotero_storage_path)
  config.note_taking_path = vim.fs.normalize(config.note_taking_path)

  -- Validate configuration
  M.validate()
end

M.validate = function()
  -- Validate that required paths exist
  if vim.fn.isdirectory(config.zotero_storage_path) ~= 1 then
    vim.notify(
      string.format('Citero: Zotero storage path not found: %s', config.zotero_storage_path),
      vim.log.levels.WARN
    )
  end

  if vim.fn.isdirectory(config.note_taking_path) ~= 1 then
    vim.notify(
      string.format('Citero: Note-taking path not found: %s', config.note_taking_path),
      vim.log.levels.WARN
    )
  end

  -- Check if BibTeX file exists
  local bib_path = M.get_bib_path()
  if not bib_path then
    vim.notify(
      string.format(
        'Citero: BibTeX file (%s) not found in current directory tree or %s',
        config.bib_filename,
        config.note_taking_path
      ),
      vim.log.levels.WARN
    )
  end
end

M.get = function(key)
  if key then
    return config[key]
  end
  return config
end

M.get_citation_format = function(filetype)
  return config.citation_formats[filetype] or config.citation_formats.typst
end

M.get_bib_path = function()
  -- Search upward from current directory
  local bib_path = vim.fs.find({ config.bib_filename }, { upward = true })[1]
  if bib_path then
    return vim.fs.normalize(bib_path)
  end

  -- Fallback to note_taking_path
  local fallback = vim.fs.joinpath(config.note_taking_path, config.bib_filename)
  if vim.fn.filereadable(fallback) == 1 then
    return fallback
  end

  return nil
end

return M
