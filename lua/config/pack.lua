local M = {}

local function load(plugin)
    local spec = plugin.spec.data or {}
    spec.name = plugin.spec.name
    require("lze").load(spec)
end

-- Accept a URL with options, or a list of flat plugin declarations.
function M.add(plugins, opts)
    if type(plugins) == "string" then
        plugins = { vim.tbl_extend("force", opts or {}, { src = plugins }) }
    end

    local specs = {}
    for _, plugin in ipairs(plugins) do
        local spec = { src = plugin.src, name = plugin.name, version = plugin.version }
        local data = {}
        -- Keep vim.pack fields separate from lze's loading configuration.
        for key, value in pairs(plugin) do
            if key ~= "src" and key ~= "name" and key ~= "version" then
                data[key] = value
            end
        end
        if next(data) then
            spec.data = data
        end
        specs[#specs + 1] = spec
    end
    vim.pack.add(specs, { load = load, confirm = false })
end

return M
