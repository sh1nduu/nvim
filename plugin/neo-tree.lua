local status, neo_tree = pcall(require, "neo-tree")
if (not status) then return end

-- neo_tree.setup()
vim.keymap.set("n", "<Leader>ft", ":NeoTreeShowToggle<Enter>", { silent = true, noremap = true })
