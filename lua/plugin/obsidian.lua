vim.pack.add({
    { src = "https://github.com/obsidian-nvim/obsidian.nvim" },
})

local loaded = false

local function setup_obsidian()
    if loaded then
        return
    end
    loaded = true
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
    setup_obsidian()
    vim.cmd("Obsidian")
end, {})

local group = vim.api.nvim_create_augroup("Obsidian", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*.md",
    group = "Obsidian",
    callback = function()
        setup_obsidian()
        vim.api.nvim_del_augroup_by_id(group)
    end,
})
