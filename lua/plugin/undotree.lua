vim.pack.add({ "https://github.com/mbbill/undotree" })

vim.keymap.set("n", "<leader>ut", ":UndotreeToggle<CR>", { desc = "[U]ndoTree [T]oggle" })
