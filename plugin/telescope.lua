local status, telescope = pcall(require, "telescope")
if not status then
	return
end
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
local fb = telescope.extensions.file_browser
local function telescope_buffer_dir()
	return vim.fn.expand("%:p:h")
end

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
    find_files = {
      theme = "dropdown",
    },
    live_grep = {
      theme = "dropdown",
    }
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      hijack_netrw = true,
      dir_icon = "",
      mappings = {
        ["i"] = {
          -- custom insert mode mappings
        },
        ["n"] = {
          -- custom normal mode mappings
          ["n"] = fb.actions.create,
        },
      },
    }
  }
}

telescope.load_extension "file_browser"

vim.keymap.set("n", "<Leader>ff", builtin.find_files, { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>fb", function()
  fb.file_browser {
    path = "%:p:h",
    respect_gitignore = true,
    cwd = telescope_buffer_dir(),
    layout_config = { height = 40 },
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
  }
end, { noremap = true, silent = true })
