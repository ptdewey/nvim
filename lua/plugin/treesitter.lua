return {
    -- TODO: also look into treesitter-textobjects https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "main",
        lazy = false,
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(event)
                    local ignored_fts = {
                        "mininotify",
                        "ministarter",
                    }

                    if vim.tbl_contains(ignored_fts, event.match) then
                        return
                    end

                    -- make sure nvim-treesitter is loaded
                    local ok, nvim_treesitter = pcall(require, "nvim-treesitter")

                    -- no nvim-treesitter, maybe fresh install
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
        end,
    },
}
