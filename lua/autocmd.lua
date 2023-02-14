-- local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- Remove whitespace on save
autocmd("BufWritePre", {
	pattern = "*",
	command = ":%s/\\s\\+$//e",
})

-- Don't auto commenting new lines
autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

-- Start terminal with insert mode
autocmd({ "TermOpen" }, {
  pattern = { "*" },
  callback = function ()
    vim.api.nvim_exec([[startinsert]], false)
  end
})

-- Disable number lines on terminal buffers
autocmd({ "TermOpen" }, {
  pattern = { "*" },
  callback = function ()
    vim.api.nvim_exec([[:set nonumber norelativenumber]], false)
  end
})

-- Highlight
autocmd({ "ColorScheme" }, {
  pattern = { "*" },
  command = "highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline",
})
autocmd({ "ColorScheme" }, {
  pattern = { "*" },
  command = "highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline",
})

-- Show cursor line in only active pane
autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  pattern = { "*" },
  command = "setlocal cursorline",
})
autocmd({ "WinLeave" }, {
  pattern = { "*" },
  command = "setlocal nocursorline",
})

-- filetype specific
autocmd({ "Filetype" }, {
  pattern = { "make" },
  command = "setlocal noexpandtab",
})
