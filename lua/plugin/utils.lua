vim.pack.add({
    { src = "https://codeberg.org/pdewey/deez-nvim" },
})

local p = require("profiler")

-- TODO: lazy loading? (refactor the plugin)
p.require("deez.wordcount")
p.require("deez.rename")

vim.keymap.set("n", "<leader>gb", function()
    p.require("deez.gitbrowse").open()
end, { desc = "Open current Git repository in browser" })

vim.keymap.set("n", "<leader>tf", function()
    p.require("deez.altfile").open()
end, { desc = "Open alternate file" })

vim.api.nvim_create_user_command("GitBrowse", function()
    p.require("deez.gitbrowse").open()
end, { desc = "Open current Git repository in browser" })
