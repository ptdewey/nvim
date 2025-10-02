-- TODO: maybe try this: https://github.com/zk-org/zk-nvim and https://github.com/zk-org/zk?tab=readme-ov-file
-- - video: https://www.youtube.com/watch?v=UzhZb7e4l4Y
vim.pack.add({
    {
        src = "https://github.com/obsidian-nvim/obsidian.nvim",
        data = {
            cmd = "Obsidian",
            ft = "markdown",
            after = function()
                require("profiler").require_and_setup("obsidian", {
                    legacy_commands = false,
                    workspaces = { { name = "notes", path = "~/notes" } },
                    notes_subdir = "notes",
                    daily_notes = {
                        folder = "notes/daily",
                        -- daily_format = "",
                        -- alias_format = "",
                        default_tags = { "daily" },
                        -- template = nil,
                    },
                    completion = {
                        nvim_cmp = false,
                        blink = true,
                        min_chars = 2,
                    },
                    -- TODO: figure out how to route new non-specified location notes into inbox?
                    new_notes_location = "notes_subdir",
                    picker = { name = "fzf-lua" },
                    ui = { enable = false },
                    templates = {
                        folder = "templates",
                        -- TODO: don't use blueprinter templates?
                    },
                })
            end,
        },
    },
}, require("pack").opts)

vim.keymap.set("n", "<leader>nd", "<cmd>Obsidian dailies<CR>", { desc = "daily notes" })
vim.keymap.set("n", "<leader>no", "<cmd>Obsidian<CR>", { desc = "obsidian" })
vim.keymap.set("n", "<leader>nt", "<cmd>Obsidian today<CR>", { desc = "daily note" })
vim.keymap.set("n", "<leader>nl", "<cmd>Obsidian links<CR>", { desc = "links" })
vim.keymap.set("n", "<leader>nb", "<cmd>Obsidian backlinks<CR>", { desc = "backlinks" })
-- TODO: new from template
