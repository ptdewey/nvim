local pack = require("config.pack")

local function kind_highlight(ctx)
    local _, highlight = require("mini.icons").get("lsp", ctx.kind)
    return highlight
end

local opts = {
    keymap = {
        preset = "none",
        ["<C-h>"] = { "select_and_accept" },
        ["<C-s>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
    },
    appearance = { nerd_font_variant = "mono" },
    signature = { enabled = true },
    completion = {
        documentation = { auto_show = false },
        ghost_text = { enabled = true },
        menu = {
            draw = {
                align_to = "cursor",
                columns = { { "label" }, { "kind_icon", "kind", "source_name", gap = 1 } },
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local icon = require("mini.icons").get("lsp", ctx.kind)
                            return icon
                        end,
                        highlight = kind_highlight,
                    },
                    kind = { highlight = kind_highlight },
                    source_name = {
                        text = function(ctx)
                            return "[" .. ctx.source_name .. "]"
                        end,
                        highlight = kind_highlight,
                    },
                },
            },
        },
    },
    cmdline = { enabled = false },
    snippets = { preset = "default" },
    sources = {
        default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
        providers = {
            lsp = { score_offset = 45 },
            snippets = { score_offset = 55 },
            path = { score_offset = 15 },
            buffer = { score_offset = 15 },
            ripgrep = {
                module = "blink-ripgrep",
                name = "rg",
                opts = { backend = { ripgrep = { max_filesize = "400K" } } },
                score_offset = 1,
            },
        },
    },
    fuzzy = {
        implementation = "prefer_rust_with_warning",
        prebuilt_binaries = { force_version = "v1.6.0" },
    },
}

pack.add({
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("1.*"),
        event = "InsertEnter",
        dep_of = "obsidian.nvim",
        after = function()
            require("blink-ripgrep")
            require("blink.cmp").setup(opts)
        end,
    },
    { src = "https://github.com/mikavilpas/blink-ripgrep.nvim", dep_of = "blink.cmp" },
})
