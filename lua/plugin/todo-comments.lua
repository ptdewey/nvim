vim.pack.add({ "https://github.com/folke/todo-comments.nvim" })

-- TODO: replace plugin with vanilla hl groups

require("profiler").require_and_setup("todo-comments", {
    signs = false,
    keywords = {
        DOC = { alt = { "DOCS" } },
        REFACTOR = { color = "warning" },
        CHANGE = { color = "warning" },
    },
})

-- navigation
vim.keymap.set("n", "]t", function()
    require("todo-comments").jump_next()
    vim.cmd("normal! zz")
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
    require("todo-comments").jump_prev()
    vim.cmd("normal! zz")
end, { desc = "Previous todo comment" })
