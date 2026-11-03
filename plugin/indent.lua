local pack = require("config.pack")

pack.add("https://github.com/saghen/blink.indent", {
    event = { "BufReadPost", "BufNewFile", "BufEnter" },
    after = function()
        require("blink.indent").setup({
            blocked = { filetypes = { "text", "markdown" } },
            static = { char = "▏" },
            scope = { enabled = false },
        })
    end,
})
