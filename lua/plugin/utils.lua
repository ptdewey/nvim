vim.pack.add({
    { src = "https://codeberg.org/pdewey/deez-nvim" },
}, { confirm = false })

vim.keymap.set("n", "<leader>gbb", function()
    require("profiler").require("deez.gitbrowse").open()
end, { desc = "browse current branch" })

vim.keymap.set("n", "<leader>gbd", function()
    require("profiler").require("deez.gitbrowse").open({ branch = "default" })
end, { desc = "browse default branch" })

vim.api.nvim_create_user_command("GitBrowse", function()
    require("profiler").require("deez.gitbrowse").open()
end, { desc = "browse current branch" })

vim.keymap.set("n", "<leader>af", function()
    require("profiler").require("deez.altfile").open()
end, { desc = "Open alternate file" })

-- require("profiler").require_and_setup("deez.indent-scope", {})
