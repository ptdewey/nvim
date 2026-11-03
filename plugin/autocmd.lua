-- Fix netrw navigation for split keyboards with numpad +/- keys.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.cmd("nnoremap <buffer> <kminus> <Plug>NetrwBrowseUpDir")
        vim.cmd("nnoremap <buffer> <kplus> <Plug>NetrwLocalBrowseCheck")
    end,
})

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    pattern = "*",
    callback = function()
        vim.hl.hl_op()
    end,
})

-- TODO: could this be an ftplugin?
vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.o.number = false
        vim.o.relativenumber = false
        vim.o.spell = false
    end,
})

local trim_group = vim.api.nvim_create_augroup("TrimTrailingWhitespace", { clear = true })
vim.api.nvim_create_user_command("EnableTrimWhitespace", function()
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = trim_group,
        pattern = "*",
        callback = function()
            vim.cmd("silent! %s/\\s\\+$//e")
        end,
    })
    print("Trim trailing whitespace enabled")
end, {})
vim.api.nvim_create_user_command("DisableTrimWhitespace", function()
    vim.api.nvim_clear_autocmds({ group = trim_group })
    print("Trim trailing whitespace disabled")
end, {})
