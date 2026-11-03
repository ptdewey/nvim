local pack = require("config.pack")

pack.add("https://github.com/obsidian-nvim/obsidian.nvim", {
    cmd = "Obsidian",
    ft = "markdown",
    after = function()
        require("obsidian").setup({
            legacy_commands = false,
            workspaces = {
                { name = "notes", path = "~/notes" },
                { name = "working-notes", path = "~/workspace/working-notes" },
            },
            notes_subdir = "notes",
            daily_notes = { folder = "notes/daily", default_tags = { "fleeting" } },
            new_notes_location = "notes_subdir",
            picker = { name = "fzf-lua" },
            ui = { enable = false },
            templates = { folder = "templates" },
        })
    end,
})

vim.keymap.set("n", "<leader>nd", "<cmd>Obsidian dailies<CR>", { desc = "obsidian dailies" })
vim.keymap.set("n", "<leader>no", "<cmd>Obsidian<CR>", { desc = "obsidian" })
vim.keymap.set("n", "<leader>nt", "<cmd>Obsidian today<CR>", { desc = "daily note" })
vim.keymap.set("n", "<leader>nb", "<cmd>Obsidian backlinks<CR>", { desc = "backlinks" })
