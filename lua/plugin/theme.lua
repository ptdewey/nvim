return {
    {
        "ptdewey/darkearth-nvim",
        -- dir = "~/projects/darkearth-nvim",
        priority = 1000,
    },

    {
        "ptdewey/monalisa-nvim",
        -- dir = "~/projects/monalisa-nvim/",
        priority = 1000,
    },

    -- {
    --     "ptdewey/witchesbrew.nvim",
    --     priority = 1000,
    -- },

    -- { "ficcdaf/ashen.nvim", priority = 1000 },

    -- {
    --     "slugbyte/lackluster.nvim",
    --     priority = 1000,
    -- },

    -- {
    --     "sho-87/kanagawa-paper.nvim",
    --     priority = 1000,
    --     config = function()
    --         require("kanagawa-paper").setup({
    --             undercurl = false,
    --             commentStyle = { italic = false },
    --             functionStyle = { italic = false },
    --             keywordStyle = { italic = false },
    --         })
    --     end,
    -- },

    -- for designing colorschemes
    {
        "rktjmp/lush.nvim",
        cmd = "Lushify",
    },

    -- for building with lush
    {
        "rktjmp/shipwright.nvim",
        cmd = "Shipwright",
    },
}
