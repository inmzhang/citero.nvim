---@class CiteroLayoutConfig
---@field preset string Layout preset
---@field preview boolean Show preview

---@class CiteroPickerConfig
---@field layout CiteroLayoutConfig Layout configuration

---@class CiteroConfig
---@field zotero_storage_path string Path to Zotero storage directory
---@field note_taking_path string Path to note-taking directory
---@field bib_filename string Name of BibTeX file
---@field keymaps boolean Enable default keymaps
---@field citation_formats table<string, string> Citation formats for different filetypes
---@field picker CiteroPickerConfig Picker configuration

---@class CiteroConfigModule
local M = {}

---@type CiteroConfig
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

---@type CiteroConfig
local config = vim.deepcopy(defaults)

---Setup configuration with user options
---@param opts? CiteroConfig User configuration options
M.setup = function(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend('force', defaults, opts)

  -- Normalize paths
  config.zotero_storage_path = vim.fs.normalize(config.zotero_storage_path)
  config.note_taking_path = vim.fs.normalize(config.note_taking_path)

  -- Validate configuration
  M.validate()
end

---Validate current configuration
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

---Get configuration value
---@param key? string Configuration key, returns full config if nil
---@return any Configuration value or full configuration
M.get = function(key)
  if key then
    return config[key]
  end
  return config
end

---Get citation format for filetype
---@param filetype string File type
---@return string Citation format string
M.get_citation_format = function(filetype)
  return config.citation_formats[filetype] or config.citation_formats.typst
end

---Get BibTeX file path
---@return string? BibTeX file path or nil if not found
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
