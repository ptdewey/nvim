local pack = require("config.pack")

pack.add("https://github.com/ptdewey/curl.nvim", {
    version = "main",
    cmd = { "CurlRun", "CurlCancel" },
    keys = { "<leader>rs" },
    after = function()
        require("curl").setup({})
    end,
})

vim.keymap.set("n", "<leader>rs", "<cmd>CurlRun<CR>", { desc = "run curl request" })
