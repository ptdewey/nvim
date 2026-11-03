local pack = require("config.pack")

pack.add("https://github.com/MagicDuck/grug-far.nvim", {
    on_require = "grug-far",
    cmd = { "GrugFar", "GrugFarWithin" },
    after = function()
        require("grug-far").setup({})
    end,
})

vim.keymap.set("n", "<leader>gf", "<cmd>GrugFar<CR>", { desc = "grug-far" })
vim.keymap.set("n", "<leader>gw", "<cmd>GrugFarWithin<CR>", { desc = "grug-far within" })
