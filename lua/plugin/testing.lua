local p = require("profiler")

vim.pack.add({
    {
        src = "https://github.com/ptdewey/nvim-coverage",
        data = {
            cmd = "Coverage",
            after = function()
                p.require_and_setup("coverage", {
                    auto_reload = true,
                    commands = true,
                    lang = {
                        go = {
                            coverage_file = "cover.out",
                        },
                    },
                })
            end,
        },
    },
    { src = "https://github.com/vim-test/vim-test" },
}, require("pack").opts)

-- TODO: lazy load

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

vim.keymap.set("n", "<leader>rt", "<cmd>TestNearest<CR>", { desc = "test nearest", silent = true })
vim.keymap.set("n", "<leader>rf", "<cmd>TestFile<CR>", { desc = "test file", silent = true })
vim.keymap.set("n", "<leader>ra", "<cmd>TestSuite<CR>", { desc = "test suite", silent = true })
