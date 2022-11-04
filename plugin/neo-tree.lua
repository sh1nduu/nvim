local status, neo_tree = pcall(require, "neo-tree")
if (not status) then return end

-- neo_tree.setup()
vim.keymap.set("n", "<Leader>ft", ":Neotree filesystem reveal<Enter>", { silent = true, noremap = true })
