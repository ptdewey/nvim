local pack = require("config.pack")

pack.add({
    {
        src = "https://github.com/ptdewey/darkearth-nvim",
        colorscheme = { "darkearth", "lightearth", "earth" },
    },
    {
        src = "https://github.com/nyoom-engineering/oxocarbon.nvim",
        colorscheme = { "oxocarbon" },
    },
    {
        src = "https://github.com/catppuccin/nvim.git",
        colorscheme = { "catppuccin", "catppuccin-mocha" },
    },
})

-- vim.cmd.colorscheme("darkearth")
-- vim.cmd.colorscheme("lightearth")
-- vim.cmd.colorscheme("catppuccin-mocha")
vim.cmd.colorscheme("oxocarbon")
