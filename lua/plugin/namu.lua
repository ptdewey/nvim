vim.pack.add({
    { src = "https://github.com/bassamsdata/namu.nvim" },
})

-- namu
require("profiler").require_and_setup("namu", {
    namu_symbols = { enable = true, options = {} },
    namu_ctags = { enable = true, options = {} },
})

vim.keymap.set("n", "<leader>sd", "<cmd>Namu symbols<cr>", {
    desc = "[S]earch [S]ymbols",
    silent = true,
})

vim.keymap.set("n", "<leader>sw", "<cmd>Namu workspace<cr>", {
    desc = "[S]ymbols [W]orkspace",
    silent = true,
})

vim.keymap.set("n", "<leader>so", "<cmd>Namu watchtower<cr>", {
    desc = "[S]earch [O]pen symbols",
    silent = true,
})
