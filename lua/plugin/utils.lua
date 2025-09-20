vim.pack.add({
    { src = "https://codeberg.org/pdewey/deez-nvim" },
})

vim.keymap.set("n", "<leader>gb", function()
    require("profiler").require("deez.gitbrowse").open()
end, { desc = "Open current Git repository in browser" })

vim.api.nvim_create_user_command("GitBrowse", function()
    require("profiler").require("deez.gitbrowse").open()
end, { desc = "Open current Git repository in browser" })

vim.keymap.set("n", "<leader>tf", function()
    require("profiler").require("deez.altfile").open()
end, { desc = "Open alternate file" })

vim.api.nvim_create_user_command("RenameFile", function(opts)
    require("profiler").require("deez.rename").rename_file(opts.args)
end, { nargs = "?" })
