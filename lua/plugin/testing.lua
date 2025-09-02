vim.pack.add({
    { src = "https://github.com/andythigpen/nvim-coverage" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/vim-test/vim-test" },
})

local p = require("profiler")

-- TODO: lazy load
local coverage_loaded = false
vim.api.nvim_create_user_command("Coverage", function()
    if not coverage_loaded then
        p.require_and_setup("coverage", {
            auto_reload = true,
            commands = true,
            lang = {
                go = {
                    coverage_file = "cover.out",
                },
            },
        })
    end
    vim.cmd("Coverage")
end, {})

-- vim-test config
vim.g["test#strategy"] = "neovim"
vim.g["test#go#gotest#options"] = "-cover -coverprofile=cover.out"
vim.g["test#custom_transformations"] = {
    cover = function(cmd)
        if string.match(cmd, "go test") then
            return cmd .. " && go tool cover -func=cover.out"
        end
        return cmd
    end,
}
vim.g["test#transformation"] = "cover"

vim.keymap.set("n", "<leader>tn", "<cmd>TestNearest<CR>", { desc = "test nearest", silent = true })
vim.keymap.set("n", "<leader>tr", "<cmd>TestFile<CR>", { desc = "test file", silent = true })
vim.keymap.set("n", "<leader>ta", "<cmd>TestSuite<CR>", { desc = "test suite", silent = true })

-- TODO: figure out this stuff and replacements
-- return {
--     {
--         "nvim-neotest/neotest",
--         cmd = { "Neotest" },
--         keys = {
--             { "<leader>tr", desc = "[T]est [R]un" },
--             { "<leader>ts", desc = "[T]est [S]etup" },
--             { "<leader>th", desc = "[T]est [H]ere" },
--             { "<leader>ta", desc = "[T]est [A]ll" },
--             { "<leader>tc", desc = "[T]oggle [C]overage" },
--         },
--         dependencies = {
--             "nvim-lua/plenary.nvim",
--             "nvim-treesitter/nvim-treesitter",
--             "nvim-neotest/nvim-nio",
--             "antoinemadec/FixCursorHold.nvim",
--             {
--                 "fredrikaverpil/neotest-golang",
--                 dependencies = {
--                     "andythigpen/nvim-coverage",
--                 },
--             },
--         },
--
--         config = function()
--             ---@diagnostic disable-next-line: missing-fields
--             require("neotest").setup({
--                 ---@diagnostic disable-next-line: missing-fields
--                 summary = {
--                     open = "botright vsplit | vertical resize 35",
--                 },
--                 adapters = {
--                     require("neotest-golang")({
--                         runner = "go",
--                         go_test_args = {
--                             -- "-v",
--                             "-race",
--                             "-count=1",
--                             "-coverpkg=./...",
--                             "-coverprofile=" .. vim.fn.getcwd() .. "/cover.out",
--                         },
--                     }),
--                 },
--             })
--
--             -- FIX: find way to automatically show coverage when switching files
--             -- - Maybe have local "loaded" var and use autocmd to apply on switching buffers?
--
--             local setup_tests = function()
--                 local win = vim.api.nvim_get_current_win()
--                 -- require("coverage").load(true)
--                 vim.cmd("Coverage")
--                 require("neotest").summary.toggle()
--                 vim.api.nvim_set_current_win(win)
--             end
--
--             vim.api.nvim_create_user_command("TestsSetup", function()
--                 setup_tests()
--             end, {
--                 desc = "Open the testing summary and start show coverage",
--             })
--             vim.api.nvim_create_user_command("TestsRunFile", function()
--                 require("neotest").run.run(vim.fn.expand("%"))
--             end, {
--                 desc = "Run all tests in the current file with neotest",
--             })
--
--             vim.keymap.set("n", "<leader>th", function()
--                 require("neotest").run.run()
--             end, { desc = "[T]est [H]ere" })
--             -- TODO: make this run alternate file tests as well (i.e. in foo.go run foo_test.go, otherwise do nothing)
--             vim.keymap.set("n", "<leader>tr", function()
--                 require("neotest").run.run(vim.fn.expand("%"))
--                 -- run_file_tests()
--             end, { desc = "[T]est [R]un", silent = true })
--             vim.keymap.set("n", "<leader>ta", function()
--                 require("neotest").run.run({ suite = true })
--             end, { desc = "[T]est [A]ll" })
--             vim.keymap.set(
--                 "n",
--                 "<leader>ts",
--                 setup_tests,
--                 { desc = "[T]ests [S]etup", silent = true }
--             )
--             vim.keymap.set("n", "<leader>tc", function()
--                 require("coverage").toggle()
--             end, { desc = "[T]oggle [C]overage" })
--         end,
--     },
-- }
