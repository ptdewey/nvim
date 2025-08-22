vim.pack.add({
    { src = "https://github.com/OXY2DEV/markview.nvim" },
})

-- TODO: figure out how to load markview before treesitter
require("profiler").require_and_setup("markview", {
    experimental = { check_rtp_message = false },
})
