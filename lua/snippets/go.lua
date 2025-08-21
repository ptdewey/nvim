local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.sn
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

local transforms = {
    int = function(_, _)
        return t("0")
    end,

    bool = function(_, _)
        return t("false")
    end,

    string = function(_, _)
        return t([[""]])
    end,

    error = function(_, _)
        return t("err")
    end,

    -- Types with a "*" mean they are pointers, so return nil
    [function(text)
        return not string.find(text, "*", 1, true)
            and string.upper(string.sub(text, 1, 1)) == string.sub(text, 1, 1)
    end] = function(_, _)
        return t("nil")
    end,

    -- Struct types, non-pointer case
    -- TODO: improve handling here
    [function(text)
        return string.find(text, "*", 1, true)
    end] = function(_, _)
        return t("nil")
    end,
}

local transform = function(text, info)
    local condition_matches = function(condition, ...)
        if type(condition) == "string" then
            return condition == text
        else
            return condition(...)
        end
    end

    for condition, result in pairs(transforms) do
        if condition_matches(condition, text, info) then
            return result(text, info)
        end
    end

    return t(text)
end

local handlers = {
    parameter_list = function(node, info)
        local result = {}

        local count = node:named_child_count()
        for idx = 0, count - 1 do
            local matching_node = node:named_child(idx)
            local type_node = matching_node:field("type")[1]
            table.insert(result, transform(vim.treesitter.get_node_text(type_node, 0), info))
            if idx ~= count - 1 then
                table.insert(result, t({ ", " }))
            end
        end

        return result
    end,

    type_identifier = function(node, info)
        local text = vim.treesitter.get_node_text(node, 0)
        return { transform(text, info) }
    end,
}

local function_node_types = {
    function_declaration = true,
    method_declaration = true,
    func_literal = true,
}

-- Helper function to get current node at cursor
local function get_node_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2] -- Convert to 0-based indexing

    local parser = vim.treesitter.get_parser(0, "go")
    if not parser then
        return
    end
    local tree = parser:parse()[1]
    local root = tree:root()

    return root:named_descendant_for_range(row, col, row, col)
end

-- Helper function to find enclosing function node
local function find_enclosing_function(node)
    local current = node
    while current do
        if function_node_types[current:type()] then
            return current
        end
        current = current:parent()
    end
    return nil
end

local function go_result_type(info)
    local cursor_node = get_node_at_cursor()
    local function_node = find_enclosing_function(cursor_node)

    if not function_node then
        print("Not inside of a function")
        return t("")
    end

    local query = vim.treesitter.query.parse(
        "go",
        [[
            [
                (method_declaration result: (_) @id)
                (function_declaration result: (_) @id)
                (func_literal result: (_) @id)
            ]
        ]]
    )

    for _, node in query:iter_captures(function_node, 0) do
        if handlers[node:type()] then
            return handlers[node:type()](node, info)
        end
    end

    -- no return type case
    return { t("") }
end

local go_ret_vals = function(args)
    return sn(
        nil,
        go_result_type({
            index = 0,
            err_name = args[1][1],
        })
    )
end

-- Go snippets
ls.add_snippets("go", {
    -- function
    s("func", fmt("func {}({}) {}{{\n\t{}\n}}", { i(1), i(2), i(3), i(4) })),

    -- print statement
    s("print", fmt('fmt.Println("{}")', { i(1) })),

    -- struct typedef
    s("typ", fmt("type {} struct {{\n\t{}\n}}{}", { i(1), i(2), i(0) })),

    -- append
    s("app", fmt("{} = append({}, {}){}", { i(1), rep(1), i(2), i(0) })),

    -- error check
    s(
        "err",
        fmt("if {} != nil {{\n\treturn {}\n}}\n{}", { i(1, "err"), d(2, go_ret_vals, { 1 }), i(0) })
    ),

    s("lerr", fmt("log.Println(err){}", { i(0) })),

    s(
        "efi",
        fmta(
            [[
                <val>, <err> := <f>(<args>)
                if <err_same> != nil {
                    return <result>
                }
                <finish>
            ]],
            {
                val = i(1),
                err = i(2, "err"),
                f = i(3),
                args = i(4),
                err_same = rep(2),
                result = d(5, go_ret_vals, { 2 }),
                finish = i(0),
            }
        )
    ),
})
