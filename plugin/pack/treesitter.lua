---@diagnostic disable: missing-fields
vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

require("profiler").require_and_setup("nvim-treesitter", {
    install_dir = vim.fn.stdpath("data") .. "/site",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(event)
        local ignored_fts = {
            "lua",
            "vimdoc",
            "mininotify",
            "ministarter",
            "Pathfinder",
            "blink-cmp-menu",
            "mason",
            "mason_backdrop",
        }

        if vim.tbl_contains(ignored_fts, event.match) then
            return
        end

        local ok, nvim_treesitter = pcall(require, "nvim-treesitter")

        if not ok then
            return
        end

        local ft = vim.bo[event.buf].ft
        local lang = vim.treesitter.language.get_lang(ft)
        nvim_treesitter.install({ lang }):await(function(err)
            if err then
                vim.notify("Treesitter install error for ft: " .. ft .. " err: " .. err)
                return
            end

            pcall(vim.treesitter.start, event.buf)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end)
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
        require("nvim-treesitter.parsers").asciidoc = {
            install_info = {
                url = "https://github.com/cathaysia/tree-sitter-asciidoc",
                location = "tree-sitter-asciidoc",
                revision = "fc36cdfc2577c5c64fcb1b1e00c910d572713586",
                queries = "tree-sitter-asciidoc/queries",
            },
        }
        require("nvim-treesitter.parsers").asciidoc_inline = {
            install_info = {
                url = "https://github.com/cathaysia/tree-sitter-asciidoc",
                location = "tree-sitter-asciidoc_inline",
                revision = "fc36cdfc2577c5c64fcb1b1e00c910d572713586",
                queries = "tree-sitter-asciidoc_inline/queries",
            },
        }
    end,
})
