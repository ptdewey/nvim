return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- TODO: figure out if there is a way to keep this up to date with mason install dir (i.e. append all binary names)
            local servers = {
                "lua_ls",
                "gopls",
                "ts_ls",
                "ruff",
                "pyright",
                "tinymist",
                "harper_ls",
                "rust_analyzer",
                "svelte",
                "just",
                "fennel_ls",
            }
            -- Avoid loading mason
            -- TODO: load if directory does not exist
            vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

            for _, server in ipairs(servers) do
                vim.lsp.enable(server)
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
        -- floating signature help
        "ray-x/lsp_signature.nvim",
        event = { "InsertEnter" },
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

    {
        "ptdewey/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                "lazy.nvim",
            },
        },
    },
}
