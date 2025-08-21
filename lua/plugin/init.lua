local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugin"
local files = vim.fn.split(vim.fn.globpath(plugin_dir, "*.lua"), "\n")
for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t:r")
    if filename ~= "init" then
        require("plugin." .. filename)
    end
end
