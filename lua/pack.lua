-- NOTE: this should be the default
vim.o.packpath = vim.fs.joinpath(vim.fn.stdpath("data"), "site")

-- vim.pack.del({ "pendulum-nvim" })
vim.pack.add({
    -- { src = "https://github.com/folke/tokyonight.nvim" },
    -- { src = vim.fn.expand("file:///projects/pendulum-nvim.git/v2"), name = "pendulum" },
    { src = "https://github.com/ptdewey/pendulum-nvim", branch = "v2" },
})

-- require("pendulum")

require("timer").require_and_setup("pendulum", function()
    require("pendulum").setup({
        log_file = vim.fn.expand("$HOME/.pendulum-log.csv"),
        timeout_len = 180,
        timer_len = 120,
        gen_reports = true,
        top_n = 5,
        top_hours = 10,
        time_zone = "America/New_York",
        time_format = "12h",
        report_section_excludes = {},
        report_excludes = {
            branch = { "unknown_branch" },
            directory = {},
            file = {},
            filetype = { "unknown_filetype" },
            project = { "unknown_project" },
        },
        lsp_binary = "/home/patrick/projects/pendulum-nvim.git/v2/pendulum-server",
    })
end)
