local status, sidebar = pcall(require, "sidebar-nvim")
if not status then
  return
end

sidebar.setup {
  disable_default_keybindings = 0,
  bindings = nil,
  open = true,
  side = "left",
  initial_width = 35,
  hide_statusline = false,
  update_interval = 1000,
  sections = {
    "git",
    "files",
    "diagnostics",
    "buffers",
    "containers",
  },
  section_separator = {"-----"},
  section_title_separator = {},
  git = {
    icon = "",
  },
  containers = {
    icon = "",
    attach_shell = "/bin/sh",
    show_all = true,
    interval = 5000,
  },
  datetime = {
    icon = "",
    format = "%a %b %d, %H:%M",
    clocks = { { name = "local" } }
  },
  todos = {
    icon = "",
    ignored_paths = { "~" }
  },
  buffers = {
    icon = "",
    ignored_buffers = {}, -- ignore buffers by regex
    sorting = "id", -- alternatively set it to "name" to sort by buffer name instead of buf id
    show_numbers = true, -- whether to also show the buffer numbers
    ignore_not_loaded = false, -- whether to ignore not loaded buffers
    ignore_terminal = true, -- whether to show terminal buffers in the list
  },
  files = {
    icon = "",
    show_hidden = false,
    ignored_paths = {"%.git$"}
  },
}

vim.keymap.set("n", "<Leader>s", sidebar.toggle, { silent = true, noremap = true })
