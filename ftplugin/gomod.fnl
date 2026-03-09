(set vim.b.mininotify_disable true)

(->> {:buffer 0 :callback #(vim.schedule _G.MiniNotify.refresh)}
     (vim.api.nvim_create_autocmd :BufLeave))
