vim.pack.add({
    { src = "https://github.com/obsidian-nvim/obsidian.nvim" },
})

local group = vim.api.nvim_create_augroup("ObsidianSetup", {})

local function setup()
    vim.api.nvim_del_user_command("Obsidian")
    vim.api.nvim_del_augroup_by_id(group)
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
end

vim.api.nvim_create_user_command("Obsidian", function(args)
    setup()
    vim.cmd("Obsidian " .. args.args)
end, { nargs = "?" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown" },
    group = group,
    callback = setup,
})

vim.keymap.set("n", "<leader>nd", "<cmd>Obsidian today<CR>", { desc = "daily note" })
vim.keymap.set("n", "<leader>no", "<cmd>Obsidian<CR>", { desc = "obsidian" })
vim.keymap.set("n", "<leader>nt", "<cmd>Obsidian tomorrow<CR>", { desc = "daily tomorrow" })
vim.keymap.set("n", "<leader>nl", "<cmd>Obsidian links<CR>", { desc = "note links" })
vim.keymap.set("n", "<leader>nb", "<cmd>Obsidian backlinks<CR>", { desc = "note backlinks" })
-- TODO: new from template
