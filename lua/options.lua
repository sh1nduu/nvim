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
  relativenumber = true,
  wrap = false,
  background = "dark",
  mouse = "",
  guifont = "Hack"
}

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

