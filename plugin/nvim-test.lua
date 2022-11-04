local status, test = pcall(require, "nvim-test")
if (not status) then return end

test.setup {
  termOpts = {
    direction = "horizontal",
    height = 20,
  },
}

local opts = { silent = true, noremap = true }

vim.keymap.set("n", "<Leader>tf", function ()
  test.run("file")
end, opts)
vim.keymap.set("n", "<Leader>tt", function ()
  test.run("nearest")
end, opts)
vim.keymap.set("n", "<Leader>ts", function ()
  test.run("suite")
end, opts)
vim.keymap.set("n", "<Leader>tl", function ()
  test.run("last")
end, opts)

