vim.pack.add({
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
})

require("profiler").require_and_setup("ibl", {
    scope = { enabled = false },
})
