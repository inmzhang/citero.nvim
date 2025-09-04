---@class CiteroModule
local M = {}

local config = require('citero.config')
local picker = require('citero.picker')
local utils = require('citero.utils')

---Setup citero with user configuration
---@param opts? CiteroConfig User configuration options
M.setup = function(opts)
  config.setup(opts)
end

---Open citation key picker
---@param opts? table Picker options
M.cite_key = function(opts)
  local ok, err = pcall(function()
    local ft = vim.bo.filetype
    local citation_format = config.get_citation_format(ft)
    picker.cite_key(vim.tbl_extend('force', { format = citation_format }, opts or {}))
  end)

  if not ok then
    vim.notify('Citero cite_key error: ' .. tostring(err), vim.log.levels.ERROR)
  end
end

---Browse Zotero papers
---@param opts? table Picker options
M.browse_papers = function(opts)
  local ok, err = pcall(function()
    picker.zotero_papers(opts)
  end)

  if not ok then
    vim.notify('Citero browse_papers error: ' .. tostring(err), vim.log.levels.ERROR)
  end
end

---Browse note-taking files
---@param opts? table Picker options
M.browse_notes = function(opts)
  local ok, err = pcall(function()
    picker.note_taking(opts)
  end)

  if not ok then
    vim.notify('Citero browse_notes error: ' .. tostring(err), vim.log.levels.ERROR)
  end
end

M.config = config

return M
