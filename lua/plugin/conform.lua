vim.pack.add({
    "https://github.com/stevearc/conform.nvim",
})

local group = vim.api.nvim_create_augroup("ConformSetup", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function()
        require("profiler").require_and_setup("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettierd" },
                typescript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescriptreact = { "prettierd" },
                html = { "prettierd" },
                css = { "prettierd" },
                svelte = { "svelte" },
                go = { "gofmt", "goimports" },
                rust = { "rustfmt" },
                python = { "ruff" },
                typst = { "tinymist" },
                yaml = { "prettierd" },
                json = { "prettierd" },
                fennel = { "fnlfmt" },
                markdown = { "prettierd" },
                -- ["_"] = { "trim_whitespace" },
                ["_"] = {},
            },

            format_on_save = function(bufnr)
                if not vim.b[bufnr].disable_autoformat then
                    return { lsp_format = "fallback", timeout_ms = 500 }
                end
            end,
        })
        require("conform").format()
        vim.api.nvim_del_augroup_by_id(group)
    end,
})

vim.api.nvim_create_user_command("ConformDisable", function(args)
    vim.b.disable_autoformat = true
end, { desc = "Disable autoformat-on-save" })

vim.api.nvim_create_user_command("ConformEnable", function()
    vim.b.disable_autoformat = false
end, { desc = "Re-enable autoformat-on-save" })
