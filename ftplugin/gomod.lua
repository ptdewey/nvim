vim.b.mininotify_disable = true

vim.api.nvim_create_autocmd("BufLeave", {
    buffer = 0,
    callback = function()
        vim.schedule(_G.MiniNotify.refresh)
    end,
})
