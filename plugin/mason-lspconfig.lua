local status, config = pcall(require, "mason-lspconfig")
if (not status) then return end

config.setup()

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, opts)
vim.keymap.set('n', 'go', '<cmd>Lspsaga show_line_diagnostics<Enter>', opts)
vim.keymap.set('n', 'gj', '<cmd>Lspsaga diagnostic_jump_next<Enter>', opts)
vim.keymap.set('n', 'gk', '<cmd>Lspsaga diagnostic_jump_prev<Enter>', opts)
vim.keymap.set('n', 'gx', '<cmd>Lspsaga code_action<Enter>', opts)
vim.keymap.set('n', '<Leader>rn', '<cmd>Lspsaga rename<Enter>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gf', function ()
    vim.lsp.buf.format { async = true }
  end, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<Leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
  -- vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<Leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
local lspconfig = require('lspconfig')
local lsp_opts = {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = require('cmp_nvim_lsp').default_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )
}

config.setup_handlers {
  function(server_name)
    lspconfig[server_name].setup(lsp_opts)
  end,
  ["rust_analyzer"] = function ()
    local has_rust_tools, rust_tools = pcall(require, "rust-tools")
    if has_rust_tools then
      rust_tools.setup({ server = lsp_opts })
    else
      lspconfig.rust_analyzer.setup({})
    end
  end,
  ["sumneko_lua"] = function()
    lspconfig.sumneko_lua.setup({
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })
  end,
}
