local status, lspconfig = pcall(require, "nvim-lspconfig")
if (not status) then return end

lspconfig.setup()
