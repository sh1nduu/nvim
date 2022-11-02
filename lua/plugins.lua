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
    config = function()
    end,
  }
  use "nvim-telescope/telescope-file-browser.nvim"

  -- Treesitter
	use { "nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" } }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
