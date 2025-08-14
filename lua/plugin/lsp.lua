return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "saghen/blink.cmp" },

        -- TODO: custom lazy loading of plugins
        opts = {
            servers = {
                lua_ls = vim.lsp.config["lua_ls"],
                gopls = vim.lsp.config["gopls"],
                ts_ls = vim.lsp.config["ts_ls"],
                ruff = vim.lsp.config["ruff"],
                pyright = vim.lsp.config["pyright"],
                tinymist = vim.lsp.config["tinymist"],
                harper_ls = vim.lsp.config["harper_ls"],
                rust_analyzer = vim.lsp.config["rust_analyzer"],
                svelte = {},
                nil_ls = {},
                just = {},
                fennel_ls = {}, --vim.lsp.config["fennel_ls"],
            },
        },

        config = function(_, opts)
            -- Avoid loading mason
            -- TODO: load if directory does not exist
            vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

            for server, config in pairs(opts.servers) do
                config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
                require("lspconfig")[server].setup(config)
            end
        end,
    },

    {
        "williamboman/mason.nvim",
        cmd = { "Mason" },
        lazy = true,
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require("mason").setup({})
        end,
    },

    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                "lazy.nvim",
            },
        },
    },

    {
        -- floating signature help
        "ray-x/lsp_signature.nvim",
        event = "LspAttach",
        config = function()
            require("lsp_signature").setup({
                doc_lines = 0,
                hi_parameter = "IncSearch",
                -- hint_inline = function() return true end,
                hint_prefix = "",
                handler_opts = { border = "rounded" },
            })
        end,
    },
}
