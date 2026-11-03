local pack = require("config.pack")

pack.add("https://github.com/folke/todo-comments.nvim", {
    event = { "BufReadPost", "BufNewFile" },
    after = function()
        require("todo-comments").setup({
            signs = false,
            keywords = {
                DOC = { alt = { "DOCS" } },
                REFACTOR = { color = "warning" },
                CHANGE = { color = "warning" },
                REVIEW = { color = "hint" },
                DEBUG = { color = "warning" },
            },
        })
    end,
})
