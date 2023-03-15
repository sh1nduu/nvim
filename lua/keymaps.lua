local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Switch to normal mode in termianl
keymap("t", "<Esc>", [[<C-\><C-n>]], term_opts)
-- Open terminal
keymap("n", "<Leader>t", ":MyTerm<Enter>", opts)
-- Open settings
keymap("n", "<Leader>v", ":e $MYVIMRC<Enter>", opts)
-- Reload settings
keymap("n", "<Leader>r", ":source $MYVIMRC<Enter>", opts)
-- Quit highlitght mode
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Enter>", opts)
-- Move cursor on a soft-wrapped lines
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)
