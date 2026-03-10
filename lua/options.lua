local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  backup = false,
  cmdheight = 1,
  title = true,
  completeopt = { "menuone", "noselect" },
  hlsearch = true,
  ignorecase = true,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  swapfile = false,
  termguicolors = true,
  writebackup = false,
  backupskip = { "/tmp/*", "/private/tmp/*" },
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  -- cursorline = true,
  number = true,
  relativenumber = false,
  scrolloff = 8,
  wrap = true,
  breakindent = true,
  background = "dark",
  mouse = "a",
  guifont = "Hack"
}

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Disable unused providers to speed up startup
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

