---@diagnostic disable: missing-fields
return {
    {
        "ibhagwan/fzf-lua",
        config = function()
            -- local fzf = require("fzf-lua")
            -- require("profiler").require_and_setup("fzf-lua", function()
            local fzf = require("fzf-lua")
            fzf.setup({
                winopts = {
                    height = 0.85,
                    width = 0.85,
                    preview = {
                        default = "builtin",
                        -- default = "bat_native", -- faster
                        vertical = "down:40%",
                        layout = "vertical",
                    },
                },
                fzf_opts = {
                    ["--no-info"] = "",
                    ["--info"] = "hidden",
                    ["--header"] = " ",
                    -- ["--ansi"] = false,
                    -- ["--layout"] = "default",
                    ["--layout"] = "reverse-list",
                },
                files = {
                    git_icons = false,
                    file_icons = true,
                    formatter = "path.filename_first",
                },
                grep = { formatter = "path.filename_first" },
                file_ignore_patterns = { "%.pdf$" },
            })

            fzf.register_ui_select(function(_, items)
                local min_h, max_h = 0.15, 0.70
                local h = (#items + 4) / vim.o.lines
                if h < min_h then
                    h = min_h
                elseif h > max_h then
                    h = max_h
                end
                return { winopts = { height = h, width = 0.40, row = 0.40 } }
            end)

            vim.keymap.set("n", "<leader>sg", function()
                fzf.grep_project({ fzf_opts = { ["--nth"] = "2.." } })
            end, { desc = "[S]earch [G]rep" })

            vim.keymap.set("n", "<leader>sb", function()
                fzf.grep_curbuf({
                    winopts = {
                        height = 0.6,
                        width = 0.5,
                        preview = {
                            hidden = true,
                        },
                    },
                })
            end, { desc = "[S]earch [B]uffer" })

            vim.keymap.set("n", "<leader>sh", function()
                fzf.help_tags({
                    winopts = {
                        preview = {
                            horizontal = "right:65%",
                            layout = "horizontal",
                        },
                    },
                    -- actions = {
                    --     ["default"] = fzf.actions.buf_edit,
                    -- },
                })
            end, { desc = "[S]earch [H]elp tags" })

            vim.keymap.set("n", "<leader>f", function()
                fzf.files({
                    winopts = {
                        preview = {
                            horizontal = "right:65%",
                            layout = "horizontal",
                        },
                    },
                })
            end, { desc = "[S]earch [F]iles" })

            vim.keymap.set("n", "<leader>d", function()
                fzf.diagnostics_workspace({
                    severity_limit = vim.diagnostic.severity.INFO,
                })
            end, { desc = "Search [D]iagnostics" })

            vim.keymap.set("n", "<leader>b", function()
                fzf.buffers()
            end, { desc = "Browse Buffers" })

            vim.keymap.set("n", "<leader>tt", function()
                fzf.grep_project({
                    search = [[\b(TODO|PERF|NOTE|FIX|DOC|REFACTOR|BUG):]],
                    no_esc = true,
                    winopts = { preview = { vertical = "down:35%", layout = "vertical" } },
                })
            end, { desc = "Search [T]odo", noremap = true })

            vim.keymap.set("n", "<leader>ca", function()
                fzf.lsp_code_actions({
                    winopts = { preview = { vertical = "down:60%", layout = "vertical" } },
                })
            end, { desc = "[C]ode [A]ction preview" })

            vim.keymap.set("n", "<leader>nf", function()
                fzf.files({ cwd = "~/notes" })
            end, { desc = "Search [N]ote [F]iles" })

            vim.keymap.set("n", "<leader>ng", function()
                fzf.grep_project({ cwd = "~/notes", hidden = false })
            end, { desc = "[G]rep [N]otes" })

            vim.keymap.set("n", "grr", function()
                fzf.lsp_references({
                    ignore_current_line = true,
                    includeDeclaration = false,
                    winopts = {
                        default = nil,
                        preview = {
                            vertical = "down:60%",
                            layout = "vertical",
                        },
                    },
                })
            end, { noremap = true, desc = "[G]oto [R]eferences" })

            vim.keymap.set("n", "gd", function()
                fzf.lsp_definitions()
                vim.cmd("normal! zz")
            end, { noremap = true, desc = "[G]oto [D]efinition" })

            vim.keymap.set("n", "<leader>gs", function()
                fzf.git_status()
            end, { noremap = true, desc = "[G]it [S]tatus" })

            vim.keymap.set("n", "<leader>ci", function()
                fzf.lsp_incoming_calls()
            end, { noremap = true, desc = "[C]alls [I]ncoming" })

            vim.keymap.set("n", "<leader>co", function()
                fzf.lsp_outgoing_calls()
            end, { noremap = true, desc = "[C]alls [O]utgoing" })

            vim.keymap.set("n", "<leader>sr", function()
                fzf.lsp_references()
            end, { noremap = true, desc = "[S]earch [R]eferences" })

            vim.keymap.set(
                "n",
                "<leader>hh",
                fzf.highlights,
                { noremap = true, desc = "Search [H]ighlights" }
            )
            -- end)
        end,
    },

    {
        "bassamsdata/namu.nvim",
        cmd = { "Namu" },
        keys = {
            { "<leader>sd", desc = "[S]earch [S]ymbols" },
            { "<leader>sw", desc = "[S]ymbols [W]orkspace" },
            { "<leader>so", desc = "[S]earch [O]pen symbols" },
        },
        config = function()
            require("timer").require_and_setup("namu", {
                namu_symbols = { enable = true, options = {} },
                namu_ctags = { enable = true, options = {} },
            })

            vim.keymap.set("n", "<leader>sd", "<cmd>Namu symbols<cr>", {
                desc = "[S]earch [S]ymbols",
                silent = true,
            })

            vim.keymap.set("n", "<leader>sw", "<cmd>Namu workspace<cr>", {
                desc = "[S]ymbols [W]orkspace",
                silent = true,
            })

            vim.keymap.set("n", "<leader>so", "<cmd>Namu watchtower<cr>", {
                desc = "[S]earch [O]pen symbols",
                silent = true,
            })
        end,
    },
}
