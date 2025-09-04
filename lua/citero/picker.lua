---@class PickerItem
---@field key string Citation key
---@field title string Entry title
---@field text string Text for fuzzy matching
---@field type string Entry type
---@field citation string Formatted citation

---@class CiteroPickerModule
local M = {}

local config = require('citero.config')
local bibtex = require('citero.bibtex')

---Check if Snacks.nvim picker is available
---@return boolean True if Snacks picker is available
local function has_snacks()
  local ok, snacks = pcall(require, 'snacks')
  return ok and snacks.picker ~= nil
end

---Format citation with given format string
---@param key string Citation key
---@param format_string string Format string with %s placeholder
---@return string Formatted citation
local function format_citation(key, format_string)
  return string.format(format_string, key)
end

---Insert text at cursor position
---@param text string Text to insert
local function insert_at_cursor(text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local new_line = line:sub(1, col) .. text .. line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, { row, col + #text })
end

---Open citation key picker
---@param opts? table Picker options
M.cite_key = function(opts)
  opts = opts or {}

  if not has_snacks() then
    vim.notify('Snacks.nvim is required for citero.nvim picker functionality', vim.log.levels.ERROR)
    return
  end

  local Snacks = require('snacks')
  local citation_format = opts.format or config.get_citation_format(vim.bo.filetype)

  local entries, err = bibtex.get_entries()
  if not entries then
    vim.notify('Citero: ' .. err, vim.log.levels.ERROR)
    return
  end

  -- Transform entries for picker
  ---@type PickerItem[]
  local picker_items = {}
  for _, entry in ipairs(entries) do
    table.insert(picker_items, {
      key = entry.key,
      title = entry.title,
      text = entry.title, -- for fuzzy matching
      type = entry.type,
      citation = format_citation(entry.key, citation_format),
    })
  end

  -- Remove format from opts to avoid conflict with picker's format function
  local picker_opts = vim.tbl_deep_extend('force', {}, opts)
  picker_opts.format = nil -- Remove format override

  local picker_config = vim.tbl_deep_extend('force', {
    title = 'Zotero Citation Keys',
    items = picker_items,
    layout = config.get('picker').layout,
    format = function(item, _)
      return {
        { string.format('%s  ⟨%s⟩', item.title, item.citation) },
      }
    end,
    actions = {
      confirm = function(picker, item)
        vim.api.nvim_set_current_win(picker.main)
        insert_at_cursor(item.citation)
        picker:close()
      end,
    },
  }, picker_opts)

  Snacks.picker(picker_config)
end

---Browse Zotero papers
---@param opts? table Picker options
M.zotero_papers = function(opts)
  opts = opts or {}

  if not has_snacks() then
    vim.notify('Snacks.nvim is required for citero.nvim picker functionality', vim.log.levels.ERROR)
    return
  end

  local Snacks = require('snacks')
  local storage_path = config.get('zotero_storage_path')

  if vim.fn.isdirectory(storage_path) ~= 1 then
    vim.notify('Zotero storage directory not found: ' .. storage_path, vim.log.levels.WARN)
    return
  end

  local picker_config = vim.tbl_deep_extend('force', {
    title = 'Zotero Papers',
    dirs = { storage_path },
    ft = 'pdf',
    follow = true,
    actions = {
      confirm = function(picker, item)
        local name = vim.fs.basename(item.file):gsub('%.%w+$', '')
        vim.fn.setreg('+', name)

        if opts.copy_without_open then
          vim.notify('Copied to clipboard: ' .. string.format('%q', name))
          picker:close()
          return
        end

        vim.ui.open(item.file)
      end,
    },
  }, opts)

  Snacks.picker.files(picker_config)
end

---Browse note-taking files
---@param opts? table Picker options
M.note_taking = function(opts)
  opts = opts or {}

  if not has_snacks() then
    vim.notify('Snacks.nvim is required for citero.nvim picker functionality', vim.log.levels.ERROR)
    return
  end

  local Snacks = require('snacks')
  local notes_path = config.get('note_taking_path')

  if vim.fn.isdirectory(notes_path) ~= 1 then
    vim.notify('Note-taking directory not found: ' .. notes_path, vim.log.levels.WARN)
    return
  end

  local picker_config = vim.tbl_deep_extend('force', {
    title = 'Note Taking',
    dirs = { notes_path },
    ft = { 'typ' },
    follow = true,
    actions = {
      confirm = require('snacks').picker.actions.jump,
    },
  }, opts)

  Snacks.picker.files(picker_config)
end

return M
