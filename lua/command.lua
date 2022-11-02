local create_user_command = vim.api.nvim_create_user_command

-- Open terminal at bottom of window
create_user_command("MyTerm", function (opts)
  vim.api.nvim_exec("split | wincmd j | resize 20 | terminal", false)
end, {})
