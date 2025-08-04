return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost" },

        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "+" },
                    change = { text = "~" },
                    delete = { text = "-" },
                    topdelete = { text = "-" },
                    changedelete = { text = "~" },
                    untracked = { "/" },
                },
                signs_staged = {
                    add = { text = "+" },
                    change = { text = "~" },
                    delete = { text = "-" },
                    topdelete = { text = "-" },
                    changedelete = { text = "~" },
                    untracked = { "/" },
                },
                signs_staged_enable = true,
            })
        end,
    },
}
