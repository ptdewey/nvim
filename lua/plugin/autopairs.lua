vim.pack.add({
    { src = "https://github.com/windwp/nvim-autopairs" },
})

-- TODO: load on InsertEnter
require("profiler").require("nvim-autopairs")
