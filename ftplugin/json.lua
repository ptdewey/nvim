vim.bo.tabstop = 2
vim.bo.shiftwidth = 2

-- TODO: maybe only launch if files are in a `lexicons` dir
vim.lsp.start({
    name = "lexicon-ls",
    cmd = { vim.fn.expand("$HOME/projects/lexls/lexls") },
    root_dir = vim.fs.dirname(vim.fs.find({ "lexicons", ".git" }, { upward = true })[1]),
})
