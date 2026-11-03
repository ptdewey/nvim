local pack = require("config.pack")

pack.add({
    {
        src = "https://github.com/ptdewey/jj.nvim",
        cmd = { "J", "Jdiff", "Jbrowse" },
        on_require = "jj",
        after = function()
            require("jj").setup({ cmd = { keymaps = { log = {} } } })
        end,
    },
    { src = "https://github.com/ptdewey/jj-diffconflicts", cmd = "JJDiffConflicts" },
})

-- TODO: use the api instead of commands, clean up require call
vim.keymap.set("n", "<leader>jd", "<cmd>Jdiff<CR>", { desc = "jj diff" })
vim.keymap.set("n", "<leader>jr", "<cmd>JJDiffConflicts", { desc = "jj resolve" })
vim.keymap.set("n", "<leader>ja", function()
    require("jj.annotate").virtual()
end, { desc = "jj blame" })
vim.keymap.set("n", "<leader>l", function()
    require("jj.annotate").line()
end, { desc = "blame line" })
vim.keymap.set("n", "<leader>jb", "<cmd>Jbrowse<CR>", { desc = "browse current branch" })
vim.keymap.set("n", "<leader>jm", "<cmd>Jbrowse trunk()<CR>", { desc = "browse default branch" })
