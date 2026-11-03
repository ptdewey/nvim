-- Disable default plugins.
for _, name in ipairs({
    "zipPlugin",
    "zip",
    "tarPlugin",
    "tar",
    "gzip",
    "tohtml",
    "man",
    "rplugin",
    "tutor_mode_plugin",
}) do
    vim.g["loaded_" .. name] = 1
end

-- Lazy load builtin undotree plugin.
vim.api.nvim_create_user_command("Undotree", function()
    vim.api.nvim_del_user_command("Undotree")
    vim.cmd.packadd("nvim.undotree")
    vim.cmd("Undotree")
end, {})

-- Lazy load difftool plugin.
vim.api.nvim_create_user_command("DiffTool", function(args)
    vim.api.nvim_del_user_command("DiffTool")
    vim.cmd.packadd("nvim.difftool")
    vim.cmd("DiffTool " .. args.args)
end, { nargs = "*", complete = "file" })
