# Neovim config with Lua

## Requirements

- Neovim 0.11 or higher
- Node.js (LTS)
- Rust (Stable)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/cli/README.md)
- gcc, g++, libstdc++, libsqlite3-dev

## Plugin Manager

[packer.nvim](https://github.com/wbthomason/packer.nvim) (auto-installed on first launch)

## Plugins

| Category | Plugin |
|---|---|
| Colorscheme | nightfox.nvim |
| Statusline | lualine.nvim |
| Fuzzy Finder | telescope.nvim, telescope-file-browser, telescope-frecency |
| Syntax | nvim-treesitter |
| LSP | mason.nvim, mason-lspconfig.nvim, nvim-lspconfig, lspsaga.nvim, fidget.nvim |
| Completion | nvim-cmp, vim-vsnip, cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline |
| Rust | rust-tools.nvim |
| File Tree | neo-tree.nvim |
| Sidebar | sidebar.nvim |
| Git | neogit, diffview.nvim |
| Editing | Comment.nvim, nvim-autopairs, nvim-ts-autotag |
| Cursor Move | quick-scope, hop.nvim |
| Test | nvim-test |
| UI | alpha-nvim, nvim-transparent |
| Markdown | markdown-preview.nvim |

## Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── base.lua          # Base settings
│   ├── options.lua       # Vim options
│   ├── keymaps.lua       # Global keymaps
│   ├── command.lua       # User commands
│   ├── autocmd.lua       # Autocommands
│   ├── plugins.lua       # Plugin definitions (packer)
│   └── colorscheme.lua   # Colorscheme settings
├── plugin/               # Plugin configs (auto-loaded)
│   ├── mason-lspconfig.lua
│   ├── lspconfig.lua
│   ├── telescope.lua
│   ├── nvim-cmp.lua
│   ├── lualine.lua
│   ├── neo-tree.lua
│   ├── sidebar.lua
│   ├── treesitter.lua
│   ├── nvim-test.lua
│   └── vim-vsnip.lua
└── cheatsheet.md         # Keybindings cheatsheet
```

## Setup

```sh
git clone <this-repo> ~/.config/nvim
nvim +PackerSync
```
