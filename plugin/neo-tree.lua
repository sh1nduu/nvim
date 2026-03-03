local status, neo_tree = pcall(require, "neo-tree")
if (not status) then return end

neo_tree.setup({
  window = {
    width = 30,
  },
})
vim.keymap.set("n", "<Leader>ft", ":Neotree filesystem reveal<Enter>", { silent = true, noremap = true })

vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "NONE", ctermbg = "NONE" })
