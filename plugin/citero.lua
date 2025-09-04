if vim.g.loaded_citero then
  return
end
vim.g.loaded_citero = 1

local citero = require('citero')

-- User commands
vim.api.nvim_create_user_command('CiteroCite', function(opts)
  citero.cite_key()
end, {
  desc = 'Open citation key picker',
})

vim.api.nvim_create_user_command('CiteroPapers', function(opts)
  local copy_only = opts.bang
  citero.browse_papers({ copy_without_open = copy_only })
end, {
  bang = true,
  desc = 'Browse Zotero papers (use ! to copy name without opening)',
})

vim.api.nvim_create_user_command('CiteroNotes', function(opts)
  citero.browse_notes()
end, {
  desc = 'Browse note-taking files',
})

-- Default keymap suggestions (users can override)
---Setup default keymaps for Citero
local function setup_keymaps()
  ---@type vim.keymap.set.Opts
  local opts = { noremap = true, silent = true, desc = 'Citero: ' }

  vim.keymap.set(
    'n',
    '<leader>zc',
    citero.cite_key,
    vim.tbl_extend('force', opts, { desc = opts.desc .. 'Citation picker' })
  )
  vim.keymap.set(
    'n',
    '<leader>zp',
    citero.browse_papers,
    vim.tbl_extend('force', opts, { desc = opts.desc .. 'Browse papers' })
  )
  vim.keymap.set(
    'n',
    '<leader>zn',
    citero.browse_notes,
    vim.tbl_extend('force', opts, { desc = opts.desc .. 'Browse notes' })
  )
end

-- Auto-setup with defaults if not configured
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if not citero.config.get() then
      citero.setup()
    end

    -- Only set up keymaps if user hasn't disabled them
    if citero.config.get('keymaps') ~= false then
      setup_keymaps()
    end
  end,
  once = true,
})
