local status, lualine = pcall(require, "lualine")
if (not status) then return end

lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'solarized_dark',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    disabled_filetypes = {},
    globalstatus = false,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
    } },
    lualine_x = {
      { 'diagnostics', sources = { "nvim_diagnostic" }, symbols = { error = 'E ', warn = 'W ', info = 'I ',
        hint = 'H ' } },
      'encoding',
      'filetype'
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
}
