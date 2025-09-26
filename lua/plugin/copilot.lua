vim.pack.add({
    -- "https://github.com/zbirenbaum/copilot.lua",
    "file:///Users/patrick.dewey/projects/copilot.lua",
})

local flag = false

local function setup()
    flag = true
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
                editorInfo = {
                    name = "GNU Emacs",
                    version = "30.1",
                    -- name = "neovim",
                    -- version = "",
                },
            },
            -- settings = { telemetry = { telemetryLevel = "off" } },
        },
    })
end

vim.keymap.set("n", "<leader>ce", function()
    if not flag then
        setup()
    end
    vim.cmd("Copilot enable")
end, { desc = "[C]opilot [E]nable" })

vim.keymap.set("n", "<leader>cd", "<cmd>Copilot disable<CR>", { desc = "[C]opilot [D]isable" })
