local p = require("profiler")

-- NOTE: this should be the default
-- vim.o.packpath = vim.fs.joinpath(vim.fn.stdpath("data"), "site")

vim.o.packpath = vim.fs.joinpath(vim.fn.stdpath("data"), "site")
vim.pack.add({
    { src = "https://github.com/vague2k/vague.nvim" },
    { src = "https://github.com/ptdewey/pendulum-nvim", version = "v2" },
})

-- p.require_and_setup("vague", {
--     bold = false,
--     italic = false,
--     on_highlights = function(highlights, colors)
--         highlights["IblIndent"] = { fg = "#27272a" }
--         highlights["DiagnosticHint"] = highlights["Comment"]
--         highlights["DiagnosticVirtualTextHint"] = highlights["DiagnosticHint"]
--     end,
-- })
-- p.colorscheme("vague")
p.colorscheme("darkearth")
-- p.colorscheme("monalisa")

vim.api.nvim_create_user_command("PackDel", function(args)
    vim.pack.del(args.fargs)
end, { nargs = "+", complete = "packadd" })

vim.api.nvim_create_user_command("PackUpdate", function(args)
    vim.pack.update(args.fargs)
end, { nargs = "*", complete = "packadd" })

require("profiler").require_and_setup(
    "pendulum",
    -- require("pendulum").setup({
    {
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
        lsp_binary = vim.fn.expand("$HOME/projects/pendulum-nvim/pendulum-server"),
    }
)
