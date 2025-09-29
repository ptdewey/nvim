vim.pack.add({
    {
        -- src = "https://github.com/zbirenbaum/copilot.lua",
        src = "file:///Users/patrick.dewey/projects/copilot.lua",
        data = {
            cmd = "Copilot",
            after = function()
                require("profiler").require_and_setup("copilot", {
                    panel = { enabled = false },
                    suggestion = {
                        enabled = false,
                        -- enabled = true,
                        -- auto_trigger = true,
                        -- keymap = {
                        --     accept = "<M-h>",
                        --     -- accept_line = "<M-l>",
                        --     next = "<M-n>",
                        --     prev = "<M-p>",
                        --     dismiss = "<C-/>",
                        -- },
                    },
                    filetypes = { markdown = true, typst = true, help = true },
                    server_opts_overrides = {
                        init_options = {
                            editorInfo = { name = "GNU Emacs", version = "30.1" },
                        },
                        -- settings = { telemetry = { telemetryLevel = "off" } },
                    },
                })
            end,
        },
    },
}, require("pack").opts)

vim.keymap.set("n", "<leader>ce", "<cmd>Copilot enable<CR>", { desc = "[C]opilot [E]nable" })
vim.keymap.set("n", "<leader>cd", "<cmd>Copilot disable<CR>", { desc = "[C]opilot [D]isable" })
