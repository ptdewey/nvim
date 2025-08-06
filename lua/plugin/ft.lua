---@diagnostic disable: missing-fields
return {
    {
        "fredrikaverpil/godoc.nvim",
        version = "*",
        dependencies = {
            "ibhagwan/fzf-lua",
            "nvim-treesitter/nvim-treesitter",
        },
        build = "go install github.com/lotusirous/gostdsym/stdsym@latest",
        cmd = { "GoDoc" },
        config = function()
            require("godoc").setup({
                window = { type = "vsplit" },
                picker = { type = "fzf_lua" },
            })
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

    -- jupyter notebooks
    -- {
    --     "GCBallesteros/jupytext.nvim",
    --     -- doesn't seem to work with any kind of lazy loading
    --     -- ft = { "jupyter", "python" },
    --     config = function()
    --         require("jupytext").setup({})
    --     end,
    -- },
}
