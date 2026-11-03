local pack = require("config.pack")

pack.add("https://github.com/windwp/nvim-autopairs", {
    event = "InsertEnter",
    after = function()
        require("nvim-autopairs").setup({})
    end,
})
