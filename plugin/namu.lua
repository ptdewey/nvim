local pack = require("config.pack")

pack.add("https://github.com/bassamsdata/namu.nvim", {
    cmd = "Namu",
    after = function()
        require("namu").setup({ namu_symbols = { enable = true, options = {} } })
    end,
})

vim.keymap.set("n", "<leader>sd", "<cmd>Namu symbols<CR>", { desc = "document symbols" })
vim.keymap.set("n", "<leader>sw", "<cmd>Namu workspace<CR>", { desc = "workspace symbols" })
vim.keymap.set("n", "<leader>so", "<cmd>Namu watchtower<CR>", { desc = "open symbols" })
