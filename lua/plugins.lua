-- Automatically install and set up packer.nvim
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Colorscheme
  use "EdenEast/nightfox.nvim"

  -- Statusline
  use "nvim-lualine/lualine.nvim"

  -- Reusable lua functions library
  use "nvim-lua/plenary.nvim"

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} },
  }
  use "nvim-telescope/telescope-file-browser.nvim"
  use {
    "nvim-telescope/telescope-frecency.nvim",
    requires = {"kkharji/sqlite.lua"}
  }

  -- Treesitter
	use { "nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" } }

  -- LSP & Completion
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/vim-vsnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
  }
  use {
    'simrat39/rust-tools.nvim',
    requires = { 'mfussenegger/nvim-dap' },
  }
  use { 'j-hui/fidget.nvim', config = function() require'fidget'.setup() end }
  use { 'kkharji/lspsaga.nvim' }

  -- Sidebar
  use "sidebar-nvim/sidebar.nvim"

  -- Startup window
  use {
    'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function ()
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
  }

  -- Cursor move support
  use {
    'unblevable/quick-scope',
    config = function ()
      vim.cmd("let g:qs_enable=1", false)
      vim.cmd("let g:qs_max_chars=80", false)
      vim.cmd("let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']", false)
      vim.cmd("let g:qs_lazy_highlight = 1", false)
      vim.cmd("nmap <Leader>h <plug>(QuickScopeToggle)", false)
    end
  }
  use {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      vim.keymap.set('n', '<Leader>hw', ":HopWord<Enter>" ,{ silent = true, noremap = true })
    end
  }

  -- File tree
  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function ()
      -- This option must be set on this time
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
    end
  }

  -- Comment feature
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }

  -- autopair
  use {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  }

  -- autotag
  use {
    "windwp/nvim-ts-autotag",
    config = function ()
      require('nvim-treesitter.configs').setup {
        autotag = {
          enable = true,
        }
      }
    end
  }

  -- Test
  use "klen/nvim-test"

  -- Git
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

  -- Transparent background
  use {
    'xiyaowong/nvim-transparent',
    config = function ()
      require('transparent').setup({
        enable = true,
        extra_groups = {
          'all',
        },
      })
     end,
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
