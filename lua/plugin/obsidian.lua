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
            -- default_tags = { "" },
            -- template = nil,
        },

        completion = {
            nvim_cmp = false,
            blink = true,
            min_chars = 2,
        },

        new_notes_location = "notes_subdir",

        picker = { name = "fzf-lua" },

        ui = {
            enable = false,
            -- bullets = { char = "-", hl_group = "Keyword" },
        },
    })
end

vim.api.nvim_create_user_command("Obsidian", function()
    setup()
    vim.cmd("Obsidian")
end, {})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown" },
    group = group,
    callback = setup,
})
