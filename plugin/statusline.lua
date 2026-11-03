-- Set to false if nerd font is missing/broken.
-- Icon reference: https://www.nerdfonts.com/cheat-sheet
local icons_enabled = true

vim.api.nvim_set_hl(0, "StlNormal", { link = "ModeMsg", default = true })
vim.api.nvim_set_hl(0, "StlInsert", { link = "special", default = true })
vim.api.nvim_set_hl(0, "StlVisual", { link = "Visual", default = true })
vim.api.nvim_set_hl(0, "StlReplace", { link = "Number", default = true })
vim.api.nvim_set_hl(0, "StlCommand", { link = "Keyword", default = true })

local function get_hl_bg(group)
    return vim.api.nvim_get_hl(0, { name = group, link = false }).bg
end

local function current_mode_info()
    local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
    local modes = {
        n = { "NORMAL", "StlNormal" },
        i = { "INSERT", "StlInsert" },
        wv = { "VISUAL", "StlVisual" },
        V = { "V-LINE", "StlVisual" },
        ["\022"] = { "V-BLOCK", "StlVisual" },
        R = { "REPLACE", "StlReplace" },
        c = { "COMMAND", "StlCommand" },
        t = { "TERMINAL", "StlInsert" },
        s = { "SELECT", "StlVisual" },
        S = { "S-LINE", "StlVisual" },
    }
    return modes[mode] or modes.n
end

local function mode_component()
    local info = current_mode_info()
    local highlight = info[2]
    vim.api.nvim_set_hl(
        0,
        "StlModeSep",
        { fg = get_hl_bg(highlight), bg = get_hl_bg("StatusLine") }
    )
    return string.format("%%#%s# %s %%#StlModeSep#", highlight, info[1])
end

local buf_display_cache = {}

local function refresh_display_cache()
    local buffers = vim.fn.getbufinfo({ buflisted = 1 })
    for key in pairs(buf_display_cache) do
        buf_display_cache[key] = nil
    end
    for _, buf in ipairs(buffers) do
        local name = vim.fn.fnamemodify(buf.name, ":t")
        if name ~= "" then
            local duplicate = false
            for _, other in ipairs(buffers) do
                if other.name ~= buf.name and vim.fn.fnamemodify(other.name, ":t") == name then
                    duplicate = true
                    break
                end
            end
            buf_display_cache[buf.bufnr] = duplicate
                    and (vim.fn.fnamemodify(buf.name, ":h:t") .. "/" .. name)
                or name
        end
    end
end

refresh_display_cache()
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufFilePost" }, {
    callback = refresh_display_cache,
})

local function filename_component()
    local display = buf_display_cache[vim.api.nvim_get_current_buf()]
    return "%#StlFile# " .. (display or "[No Name]") .. " %m%r"
end

local function location()
    local highlight = current_mode_info()[2]
    vim.api.nvim_set_hl(0, "StlPosSep", { fg = get_hl_bg(highlight), bg = get_hl_bg("StatusLine") })
    return "%#StlPosSep#%#" .. highlight .. "# %l:%c "
end

-- TODO: maybe define style sets, fill/outline, set those with condition?
local diagnostic_icons = icons_enabled
        and { error = " ", warn = "󰀪 ", info = "󰋽 ", hint = " " }
    or { error = "E:", warn = "W:", info = "I:", hint = "H:" }

local function diagnostic_part(parts, severity, highlight, icon)
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity] })
    if count > 0 then
        table.insert(parts, "%#" .. highlight .. "#" .. diagnostic_icons[icon] .. count)
    end
end

local function diagnostics_component()
    local parts = {}
    diagnostic_part(parts, "ERROR", "DiagnosticError", "error")
    diagnostic_part(parts, "WARN", "DiagnosticWarn", "warn")
    diagnostic_part(parts, "INFO", "DiagnosticInfo", "info")
    diagnostic_part(parts, "HINT", "DiagnosticHint", "hint")
    return #parts > 0 and ("%#StlDiag#" .. table.concat(parts, " ") .. " ") or ""
end

local function diff_part(parts, summary, field, highlight, prefix)
    if summary and (summary[field] or 0) > 0 then
        table.insert(parts, "%#" .. highlight .. "#" .. prefix .. summary[field])
    end
end

local function diff_component()
    if not _G.MiniDiff then
        return ""
    end
    local data = _G.MiniDiff.get_buf_data(0)
    if not data then
        return ""
    end
    local parts = {}
    diff_part(parts, data.summary, "add", "Added", "+")
    diff_part(parts, data.summary, "change", "Changed", "~")
    diff_part(parts, data.summary, "delete", "Removed", "-")
    return #parts > 0 and ("%#StlDiff# " .. table.concat(parts, " ") .. " ") or ""
end

local jj_info = ""

local function update_jj_info()
    vim.system({
        "jj",
        "log",
        "-r",
        "@",
        "--no-graph",
        "--ignore-working-copy",
        "-T",
        'if(bookmarks, bookmarks.join(", "), change_id.short(8))',
    }, { text = true }, function(result)
        jj_info = result.code == 0 and vim.trim(result.stdout) or ""
    end)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
    callback = update_jj_info,
})

local function jj_component()
    return jj_info ~= "" and ("%#StlJJ# " .. jj_info .. " ") or ""
end

function _G.Statusline()
    return table.concat({
        mode_component(),
        filename_component(),
        "%#StlFill#%=", -- Filler component
        diagnostics_component(),
        diff_component(),
        jj_component(),
        location(),
    })
end

vim.o.statusline = "%!v:lua.Statusline()"
