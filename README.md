# citero.nvim

A Neovim plugin for quickly searching and citing papers managed by Zotero.
Seamlessly browse your Zotero library and insert citations.

## Features

- 📚 **Browse Zotero papers** and open PDFs directly
- 🔍 **Fuzzy search** through BibTeX entries with live preview
- 📝 **File-type aware citations insertion** (LaTeX, Typst formats)

## Requirements

- Neovim >= 0.9
- [snacks.nvim](https://github.com/folke/snacks.nvim) for picker functionality
- [Zotero](https://www.zotero.org/) with Better BibTeX extension

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'inmzhang/citero.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {
    zotero_storage_path = vim.fn.expand('~/Zotero/storage'),
    note_taking_path = vim.fn.expand('~/Documents/notes'),
  },
}
```


## Setup

### 1. Export Zotero Library as BibTeX

In Zotero:
1. Go to **File → Export Library**
2. Choose **Better BibTeX** format
3. Check **Keep updated** for automatic synchronization
4. Save as `zotero.bib` in your note-taking directory or any parent directory

### 2. Configure Environment (Optional)

For Typst users, set up `TYPST_ROOT` to allow subdirectories to access your uniformly managed BibTeX file:

```bash
# In your note-taking directory
echo 'export TYPST_ROOT=$(pwd)' > .envrc
direnv allow  # if using direnv
```

### 3. Plugin Configuration

```lua
require('citero').setup({
  -- Zotero storage path (where PDFs are stored)
  zotero_storage_path = vim.fn.expand('~/Zotero/storage'),
  
  -- Note-taking directory
  note_taking_path = vim.fn.expand('~/Documents/notes'),
  
  -- BibTeX filename to search for
  bib_filename = 'zotero.bib',
  
  -- Citation formats for different file types
  citation_formats = {
    tex = '\\cite{%s}',    -- LaTeX format
    latex = '\\cite{%s}',  -- LaTeX format
    typst = '@%s',         -- Typst format  
  },
  
  -- Picker configuration
  picker = {
    layout = {
      preset = 'default',
      preview = false,
    }
  },
  
  -- Set to false to disable default keymaps
  keymaps = true,
})
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:CiteroCite` | Open citation key picker |
| `:CiteroPapers` | Browse Zotero PDF papers |
| `:CiteroPapers!` | Copy paper name to clipboard (don't open) |
| `:CiteroNotes` | Browse note-taking files |

### Default Keymaps

| Key | Function | Description |
|-----|----------|-------------|
| `<leader>zc` | Citation picker | Fuzzy search and insert citation key |
| `<leader>zp` | Browse papers | Open Zotero paper PDFs |
| `<leader>zn` | Browse notes | Navigate note-taking files |

### File-Type Aware Citations

The plugin automatically formats citations based on your current file type:

- **LaTeX/TeX**: `\cite{AuthorYear}`
- **Typst**: `@AuthorYear`

## Workflow Example

1. **Writing notes in Typst/LaTeX**: Press `<leader>zc` to open citation picker
2. **Fuzzy search**: Type part of the paper title or author name
3. **Insert citation**: Press Enter to insert the formatted citation key
4. **Access papers**: Use `<leader>zp` to browse and open PDF papers
5. **Manage notes**: Use `<leader>zn` to navigate your note-taking files
