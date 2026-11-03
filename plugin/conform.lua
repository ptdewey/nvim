local pack = require("config.pack")

pack.add("https://github.com/stevearc/conform.nvim", {
    event = "BufWritePre",
    after = function()
        local conform = require("conform")
        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettierd" },
                typescript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescriptreact = { "prettierd" },
                html = { "prettierd" },
                css = { "prettierd" },
                go = { "goimports", "golangci-lint" },
                templ = { "templ" },
                nix = { "nixfmt" },
                rust = { "rustfmt" },
                python = { "ruff_format" },
                typst = { "tinymist" },
                yaml = { "prettierd" },
                json = { "prettierd" },
                fennel = { "fnlfmt" },
                markdown = { "prettierd" },
                _ = {},
            },
            format_on_save = function(bufnr)
                if not vim.b[bufnr].disable_autoformat then
                    return { lsp_format = "fallback", timeout_ms = 500 }
                end
            end,
        })
        conform.format()
    end,
})

vim.api.nvim_create_user_command("ConformDisable", function()
    vim.b.disable_autoformat = true
end, { desc = "Disable autoformat-on-save" })

vim.api.nvim_create_user_command("ConformEnable", function()
    vim.b.disable_autoformat = false
end, { desc = "Re-enable autoformat-on-save" })
