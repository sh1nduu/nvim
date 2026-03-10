-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme (load immediately)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Statusline (load immediately for UI)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup {
        options = {
          icons_enabled = true,
          theme = 'solarized_dark',
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
          disabled_filetypes = {},
          globalstatus = false,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = { {
            'filename',
            file_status = true,
            path = 1,
          } },
          lualine_x = {
            { 'diagnostics', sources = { "nvim_diagnostic" }, symbols = { error = 'E ', warn = 'W ', info = 'I ', hint = 'H ' } },
            'encoding',
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      }
    end,
  },

  -- Telescope (lazy load on keymap/command)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<Leader>ff", desc = "Find files" },
      { "<Leader>fg", desc = "Live grep" },
      { "<Leader>fb", desc = "File browser" },
      { "<Leader>fr", desc = "Frecency" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      { "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")

      telescope.setup {
        defaults = {
          mappings = {
            n = {
              ["q"] = actions.close,
              ["<Esc><Esc>"] = actions.close,
            },
          },
          file_ignore_pattern = { "node_modules", ".git" },
        },
        pickers = {
          find_files = { theme = "dropdown" },
          live_grep = { theme = "dropdown" },
        },
        extensions = {
          file_browser = {
            theme = "dropdown",
            hijack_netrw = true,
            dir_icon = "",
            mappings = {
              ["n"] = {
                ["n"] = require("telescope").extensions.file_browser.actions.create,
              },
            },
          },
          frecency = {
            ignore_patterns = { "*.git/*", "*/tmp/*" },
          },
        },
      }

      telescope.load_extension("file_browser")
      telescope.load_extension("frecency")

      local opts = { noremap = true, silent = true }
      local function telescope_buffer_dir()
        return vim.fn.expand("%:p:h")
      end

      vim.keymap.set("n", "<Leader>ff", builtin.find_files, opts)
      vim.keymap.set("n", "<Leader>fg", builtin.live_grep, opts)
      vim.keymap.set("n", "<Leader>fb", function()
        telescope.extensions.file_browser.file_browser {
          path = "%:p:h",
          respect_gitignore = true,
          cwd = telescope_buffer_dir(),
          layout_config = { height = 40 },
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
        }
      end, opts)
      vim.keymap.set("n", "<Leader>fr", function()
        telescope.extensions.frecency.frecency()
      end, opts)
    end,
  },

  -- Treesitter (load on BufRead for syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "css", "go", "html", "javascript", "json", "lua",
        "markdown", "markdown_inline", "rust", "sql", "toml",
        "tsx", "typescript",
      },
    },
  },

  -- Mason (lazy, only when explicitly needed)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    cmd = "Mason",
    dependencies = { "williamboman/mason.nvim" },
    config = function() require("mason-lspconfig").setup() end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, opts)
      vim.keymap.set('n', 'go', '<cmd>Lspsaga show_line_diagnostics<Enter>', opts)
      vim.keymap.set('n', 'gj', '<cmd>Lspsaga diagnostic_jump_next<Enter>', opts)
      vim.keymap.set('n', 'gk', '<cmd>Lspsaga diagnostic_jump_prev<Enter>', opts)
      vim.keymap.set('n', 'gx', '<cmd>Lspsaga code_action<Enter>', opts)
      vim.keymap.set('n', '<Leader>rn', '<cmd>Lspsaga rename<Enter>', opts)

      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gf', function() vim.lsp.buf.format { async = true } end, bufopts)
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
        vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<Leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
      end
    end,
  },

  -- Completion (load on InsertEnter)
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vsnip" },
          { name = "buffer" },
          { name = "path" },
        }, {
          { name = 'buffer' },
        }),
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-l>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
        }),
        experimental = {
          ghost_text = true,
        },
      }
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'buffer' } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "path" }, { name = "cmdline" } },
      })
    end,
  },

  -- Rust tools
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = { "mfussenegger/nvim-dap" },
  },

  -- LSP progress indicator
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function() require("fidget").setup() end,
  },

  -- Lspsaga
  {
    "kkharji/lspsaga.nvim",
    event = "LspAttach",
  },

  -- Sidebar
  {
    "sidebar-nvim/sidebar.nvim",
    keys = { { "<Leader>s", desc = "Toggle sidebar" } },
    config = function()
      local sidebar = require("sidebar-nvim")
      sidebar.setup {
        disable_default_keybindings = 0,
        open = false,
        side = "left",
        initial_width = 35,
        hide_statusline = false,
        update_interval = 1000,
        sections = { "git", "files", "diagnostics", "buffers", "containers" },
        section_separator = { "-----" },
        section_title_separator = {},
        git = { icon = "" },
        containers = { icon = "", attach_shell = "/bin/sh", show_all = true, interval = 5000 },
        datetime = { icon = "", format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
        todos = { icon = "", ignored_paths = { "~" } },
        buffers = { icon = "", ignored_buffers = {}, sorting = "id", show_numbers = true, ignore_not_loaded = false, ignore_terminal = true },
        files = { icon = "", show_hidden = false, ignored_paths = { "%.git$" } },
      }
      vim.keymap.set("n", "<Leader>s", sidebar.toggle, { silent = true, noremap = true })
    end,
  },

  -- Startup window
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").config)
    end,
  },

  -- Cursor move: quick-scope
  {
    "unblevable/quick-scope",
    keys = { "f", "F", "t", "T" },
    init = function()
      vim.g.qs_enable = 1
      vim.g.qs_max_chars = 80
      vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
      vim.g.qs_lazy_highlight = 1
    end,
    config = function()
      vim.keymap.set('n', '<Leader>h', '<plug>(QuickScopeToggle)')
    end,
  },

  -- Cursor move: hop
  {
    "phaazon/hop.nvim",
    branch = "v2",
    keys = { { "<Leader>hw", desc = "Hop word" } },
    config = function()
      require("hop").setup { keys = 'etovxqpdygfblzhckisuran' }
      vim.keymap.set('n', '<Leader>hw', ":HopWord<Enter>", { silent = true, noremap = true })
    end,
  },

  -- File tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    keys = { { "<Leader>ft", desc = "File tree" } },
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
    end,
    config = function()
      require("neo-tree").setup({ window = { width = 30 } })
      vim.keymap.set("n", "<Leader>ft", ":Neotree filesystem reveal<Enter>", { silent = true, noremap = true })
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "NONE", ctermbg = "NONE" })
    end,
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require("Comment").setup() end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function() require("nvim-autopairs").setup() end,
  },

  -- Autotag
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
  },

  -- Test
  {
    "klen/nvim-test",
    keys = {
      { "<Leader>tf", desc = "Test file" },
      { "<Leader>tt", desc = "Test nearest" },
      { "<Leader>ts", desc = "Test suite" },
      { "<Leader>tl", desc = "Test last" },
    },
    config = function()
      local test = require("nvim-test")
      test.setup { termOpts = { direction = "horizontal", height = 20 } }
      local opts = { silent = true, noremap = true }
      vim.keymap.set("n", "<Leader>tf", function() test.run("file") end, opts)
      vim.keymap.set("n", "<Leader>tt", function() test.run("nearest") end, opts)
      vim.keymap.set("n", "<Leader>ts", function() test.run("suite") end, opts)
      vim.keymap.set("n", "<Leader>tl", function() test.run("last") end, opts)
    end,
  },

  -- Git
  {
    "TimUntersberger/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Transparent background
  {
    "xiyaowong/nvim-transparent",
    lazy = false,
    config = function()
      require("transparent").setup({
        enable = true,
        extra_groups = { 'all', 'NeoTreeNormal', 'NeoTreeNormalNC', 'NeoTreeEndOfBuffer' },
      })
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- Render markdown inline
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "kyazdani42/nvim-web-devicons" },
    config = function() require("render-markdown").setup({}) end,
  },
}, {
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
