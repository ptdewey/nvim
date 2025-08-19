return {
    {
        "ptdewey/lualine.nvim",
        config = function()
            require("profiler").require_and_setup("lualine", {
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    component_separators = "|",
                    section_separators = "",
                    disabled_filetypes = {
                        statusline = {
                            "undotree",
                            "diff",
                        },
                    },
                },
                sections = {
                    lualine_b = {},
                    lualine_c = {
                        { "filename", path = 5, padding = 1 },
                    },
                    lualine_x = { "diagnostics", "diff" },
                    lualine_y = { "branch" },
                },
            })
        end,
    },
}
