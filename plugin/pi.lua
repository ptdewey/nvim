local pack = require("config.pack")

pack.add("https://github.com/ptdewey/pi-nvim.git", {
    after = function()
        require("pi-nvim").setup({})
    end,
    cmd = { "Pi", "PiOpen", "PiSendFile", "PiSendBuffer", "PiPing", "PiSessions" },
})

vim.keymap.set({ "n", "x" }, "<leader>ap", "<cmd>Pi<CR>", { desc = "prompt pi" })
