local options = {
    tabstop = 2,
    shiftwidth = 2,
    commentstring = "// %s",
}

for k, v in pairs(options) do
    vim.opt_local[k] = v
end

local function open_pdf()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath:match("%.typ$") then
        local pdf_path = filepath:gsub("%.typ$", ".pdf")
        vim.system({ "zathura", pdf_path })
    end
end

vim.keymap.set("n", "<leader>co", open_pdf, { desc = "Open PDF Preview" })
vim.api.nvim_create_user_command("OpenPdf", open_pdf, {})
