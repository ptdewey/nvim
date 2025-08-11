return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

    {
        "windwp/nvim-ts-autotag",
        ft = {
            "markdown",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "html",
            "vue",
            "svelte",
        },
        config = function()
            require("nvim-ts-autotag").setup({})
        end,
    },
}
