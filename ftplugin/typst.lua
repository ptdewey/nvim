vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.commentstring = "// %s"

local function open_pdf()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath:match("%.typ$") then
        local pdf_path = filepath:gsub("%.typ$", ".pdf")
        vim.system({ "zathura", pdf_path })
    end
end

vim.keymap.set("n", "<leader>co", open_pdf, { desc = "Open PDF Preview" })
vim.api.nvim_create_user_command("OpenPdf", open_pdf, {})
