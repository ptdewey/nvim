local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.sn
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local go_auto_import = require("go_auto_import")

-- Map Go types to their zero-value text nodes
local numeric_types = {
    int = true,
    int8 = true,
    int16 = true,
    int32 = true,
    int64 = true,
    uint = true,
    uint8 = true,
    uint16 = true,
    uint32 = true,
    uint64 = true,
    uintptr = true,
    float32 = true,
    float64 = true,
    complex64 = true,
    complex128 = true,
    byte = true,
    rune = true,
}

local function zero_value(text)
    if text == "bool" then
        return t("false")
    end
    if text == "string" then
        return t('""')
    end
    if text == "error" then
        return t("nil")
    end
    if text == "interface{}" or text == "any" then
        return t("nil")
    end
    if numeric_types[text] then
        return t("0")
    end
    if
        text:match("^%*")
        or text:match("^%[%]")
        or text:match("^map%[")
        or text:match("chan")
        or text:match("^func%(")
    then
        return t("nil")
    end
    if text:match("^%[%d+%]") then
        return t(text .. "{}")
    end
    -- Named/qualified types (e.g. MyStruct, testStr, pkg.Type)
    if text:match("^[%a_][%w_]*$") or text:match("^[%a_][%w_]*%.[%a_][%w_]*$") then
        return t(text .. "{}")
    end
    return t(text)
end

local function_node_types = {
    function_declaration = true,
    method_declaration = true,
    func_literal = true,
}

local function find_enclosing_function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    local parser = vim.treesitter.get_parser(0, "go")
    if not parser then
        return nil, row, col
    end

    local root = parser:parse()[1]:root()
    local cursor_node = root:named_descendant_for_range(row, col, row, col)

    local fn_node = cursor_node
    while fn_node and not function_node_types[fn_node:type()] do
        fn_node = fn_node:parent()
    end
    return fn_node, row, col
end

local result_query

local function get_return_types(fn_node)
    if not result_query then
        result_query = vim.treesitter.query.parse(
            "go",
            [[
	[
		(method_declaration result: (_) @id)
		(function_declaration result: (_) @id)
		(func_literal result: (_) @id)
	]
]]
        )
    end
    for _, node in result_query:iter_captures(fn_node, 0) do
        if node:type() == "parameter_list" then
            local results = {}
            for idx = 0, node:named_child_count() - 1 do
                local param = node:named_child(idx)
                local type_node = param:field("type")[1]
                local type_text = vim.treesitter.get_node_text(type_node, 0)
                local name_node = param:field("name")[1]
                local name = name_node and vim.treesitter.get_node_text(name_node, 0) or nil
                table.insert(results, { type_text = type_text, name = name })
            end
            return results
        end
        return { { type_text = vim.treesitter.get_node_text(node, 0), name = nil } }
    end
    return {}
end

local function go_result_type()
    local fn_node = find_enclosing_function()
    if not fn_node then
        return { t("") }
    end

    local ret_types = get_return_types(fn_node)
    if #ret_types == 0 then
        return { t("") }
    end

    local result = {}
    for idx, rt in ipairs(ret_types) do
        -- In the err snippet context, return the error variable, not nil
        if rt.type_text == "error" then
            table.insert(result, t("err"))
        else
            table.insert(result, zero_value(rt.type_text))
        end
        if idx ~= #ret_types then
            table.insert(result, t(", "))
        end
    end
    return result
end

local go_ret_vals = function(args)
    return sn(nil, go_result_type())
end

local function collect_in_scope_vars(fn_node, cursor_row)
    local vars = {}

    -- Collect function parameters
    local params = fn_node:field("parameters")
    if params and params[1] then
        for idx = 0, params[1]:named_child_count() - 1 do
            local param = params[1]:named_child(idx)
            local type_node = param:field("type")[1]
            if type_node then
                local type_text = vim.treesitter.get_node_text(type_node, 0)
                -- Variadic: ...T -> []T
                if param:type() == "variadic_parameter_declaration" then
                    type_text = "[]" .. type_text
                end
                local name_nodes = param:field("name")
                for _, name_node in ipairs(name_nodes) do
                    table.insert(vars, {
                        name = vim.treesitter.get_node_text(name_node, 0),
                        type_text = type_text,
                        row = param:start(),
                    })
                end
            end
        end
    end

    -- Collect method receiver
    if fn_node:type() == "method_declaration" then
        local receiver = fn_node:field("receiver")
        if receiver and receiver[1] then
            local param = receiver[1]:named_child(0)
            if param then
                local name_node = param:field("name")[1]
                local type_node = param:field("type")[1]
                if name_node and type_node then
                    table.insert(vars, {
                        name = vim.treesitter.get_node_text(name_node, 0),
                        type_text = vim.treesitter.get_node_text(type_node, 0),
                        row = param:start(),
                    })
                end
            end
        end
    end

    -- Walk function body for var_spec and short_var_declaration
    local body = fn_node:field("body")[1]
    if not body then
        return vars
    end

    local function walk(node)
        if not node then
            return
        end
        -- Skip nested function literals
        if function_node_types[node:type()] and node ~= fn_node then
            return
        end

        local ntype = node:type()

        if ntype == "var_spec" then
            local type_node = node:field("type")[1]
            if type_node then
                local type_text = vim.treesitter.get_node_text(type_node, 0)
                local name_nodes = node:field("name")
                for _, name_node in ipairs(name_nodes) do
                    local row = node:start()
                    if row < cursor_row then
                        table.insert(vars, {
                            name = vim.treesitter.get_node_text(name_node, 0),
                            type_text = type_text,
                            row = row,
                        })
                    end
                end
            end
        elseif ntype == "short_var_declaration" then
            local left = node:field("left")[1]
            local right = node:field("right")[1]
            if left and right then
                -- Collect LHS names
                local names = {}
                for j = 0, left:named_child_count() - 1 do
                    table.insert(names, left:named_child(j))
                end

                -- Collect RHS expressions
                local rhs_exprs = {}
                for j = 0, right:named_child_count() - 1 do
                    table.insert(rhs_exprs, right:named_child(j))
                end

                for j, name_node in ipairs(names) do
                    local name = vim.treesitter.get_node_text(name_node, 0)
                    if name ~= "_" then
                        local row = node:start()
                        if row < cursor_row then
                            local inferred_type = nil

                            -- Heuristic: variable named "err" -> error
                            if name == "err" then
                                inferred_type = "error"
                            end

                            -- Heuristic: RHS is a string literal
                            if not inferred_type and rhs_exprs[j] then
                                local rhs_type = rhs_exprs[j]:type()
                                if
                                    rhs_type == "interpreted_string_literal"
                                    or rhs_type == "raw_string_literal"
                                then
                                    inferred_type = "string"
                                end
                            end

                            -- Heuristic: RHS is composite_literal or unary_expression(&composite_literal)
                            if not inferred_type and rhs_exprs[j] then
                                local rhs = rhs_exprs[j]
                                if rhs:type() == "composite_literal" then
                                    local ct = rhs:field("type")[1]
                                    if ct then
                                        inferred_type = vim.treesitter.get_node_text(ct, 0)
                                    end
                                elseif rhs:type() == "unary_expression" then
                                    local operand = rhs:field("operand")[1]
                                    if operand and operand:type() == "composite_literal" then
                                        local ct = operand:field("type")[1]
                                        if ct then
                                            inferred_type = "*"
                                                .. vim.treesitter.get_node_text(ct, 0)
                                        end
                                    end
                                end
                            end

                            if inferred_type then
                                table.insert(
                                    vars,
                                    { name = name, type_text = inferred_type, row = row }
                                )
                            end
                        end
                    end
                end
            end
        end

        for j = 0, node:child_count() - 1 do
            walk(node:child(j))
        end
    end

    walk(body)
    return vars
end

local function go_smart_return()
    local fn_node, cursor_row = find_enclosing_function()
    if not fn_node then
        return { t("") }
    end

    local ret_types = get_return_types(fn_node)
    if #ret_types == 0 then
        return { t("") }
    end

    local in_scope = collect_in_scope_vars(fn_node, cursor_row)

    local nodes = {}
    local node_idx = 1
    for idx, rt in ipairs(ret_types) do
        -- Collect candidates for this return position
        local candidates = {}
        local seen = {}

        -- Named return variable is the top choice
        if rt.name then
            seen[rt.name] = true
            table.insert(candidates, rt.name)
        end

        -- Find in-scope variables matching this type (most recently declared first)
        local matching = {}
        for _, v in ipairs(in_scope) do
            if v.type_text == rt.type_text and not seen[v.name] then
                table.insert(matching, v)
            end
        end
        table.sort(matching, function(a, b)
            return a.row > b.row
        end)
        for _, v in ipairs(matching) do
            if not seen[v.name] then
                seen[v.name] = true
                table.insert(candidates, v.name)
            end
        end

        -- Zero value as fallback
        local zv_str = table.concat(zero_value(rt.type_text).static_text)

        if not seen[zv_str] then
            table.insert(candidates, zv_str)
        end

        if #candidates > 1 then
            local choice_nodes = {}
            for _, cand in ipairs(candidates) do
                table.insert(choice_nodes, t(cand))
            end
            table.insert(nodes, c(node_idx, choice_nodes))
        elseif #candidates == 1 then
            table.insert(nodes, i(node_idx, candidates[1]))
        else
            table.insert(nodes, i(node_idx))
        end
        node_idx = node_idx + 1

        if idx ~= #ret_types then
            table.insert(nodes, t(", "))
        end
    end

    return nodes
end

local go_ret_vals_smart = function()
    local fn_node = find_enclosing_function()
    if not fn_node then
        return sn(nil, { t("") })
    end
    local ret_types = get_return_types(fn_node)
    if #ret_types == 0 then
        return sn(nil, { t("") })
    end
    return sn(nil, go_smart_return())
end

-- Snippets
ls.add_snippets("go", {
    s(
        "func",
        fmt("func {}({}) {}{{\n\t{}\n}}", {
            c(1, {
                sn(nil, { i(1) }),
                sn(nil, { t("("), i(1), t(") "), i(2) }),
            }),
            i(2),
            i(3),
            i(4),
        })
    ),
    s("print", fmt('fmt.Println("{}")', { i(1) })),
    s(
        "typ",
        fmt("type {} {} {{\n\t{}\n}}{}", {
            i(1),
            c(2, { t("struct"), t("interface") }),
            i(3),
            i(0),
        })
    ),
    s(
        "err",
        fmt("if {} != nil {{\n\treturn {}\n}}\n{}", {
            i(1, "err"),
            d(2, go_ret_vals, { 1 }),
            i(0),
        })
    ),
    s("lerr", fmt("log.Println(err){}", { i(0) })),
    s("ret", {
        t("return "),
        d(1, go_ret_vals_smart, {}),
    }),
})

-- Auto-import autosnippets
local valid_contexts = {
    block = true,
    statement_list = true,
    expression_statement = true,
    return_statement = true,
    if_statement = true,
    for_statement = true,
    switch_statement = true,
    select_statement = true,
    defer_statement = true,
    go_statement = true,
    assignment_statement = true,
    short_var_declaration = true,
    var_declaration = true,
    const_declaration = true,
    var_spec = true,
    const_spec = true,
    parameter_declaration = true,
    parameter_list = true,
    variadic_parameter_declaration = true,
    field_declaration = true,
    field_declaration_list = true,
    type_declaration = true,
    type_spec = true,
    call_expression = true,
    argument_list = true,
    composite_literal = true,
    keyed_element = true,
    literal_element = true,
    literal_value = true,
    unary_expression = true,
    binary_expression = true,
    index_expression = true,
    slice_expression = true,
    type_assertion = true,
    type_conversion_expression = true,
    method_elem = true,
    method_spec_list = true,
}

local invalid_contexts = {
    import_declaration = true,
    import_spec = true,
    import_spec_list = true,
    comment = true,
    interpreted_string_literal = true,
    raw_string_literal = true,
    rune_literal = true,
    selector_expression = true,
}

local function should_auto_import(line_to_cursor, matched_trigger, captures)
    if not captures or not captures[1] then
        return false
    end

    -- Don't trigger after another dot (e.g., log.Print)
    local match_start = #line_to_cursor - #matched_trigger
    if match_start > 0 and line_to_cursor:sub(match_start, match_start) == "." then
        return false
    end

    if not go_auto_import.get_import_path(captures[1]) then
        return false
    end

    -- Tree-sitter context check
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= "go" then
        return false
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, math.max(0, cursor[2] - 1)

    local parser = vim.treesitter.get_parser(bufnr, "go")
    if not parser then
        return false
    end

    local tree = parser:parse()[1]
    if not tree then
        return false
    end

    local node = tree:root():named_descendant_for_range(row, col, row, col)
    local found_valid = false
    while node do
        local nt = node:type()
        if invalid_contexts[nt] then
            return false
        end
        if valid_contexts[nt] then
            found_valid = true
        end
        node = node:parent()
    end
    return found_valid
end

ls.add_snippets("go", {
    s({
        trig = "([%a_][%w_]*)%.",
        trigEngine = "pattern",
        snippetType = "autosnippet",
        wordTrig = true,
        hidden = true,
        condition = should_auto_import,
    }, {
        f(function(_, snip)
            local alias = snip.captures[1]
            local import_path = go_auto_import.get_import_path(alias)
            if import_path then
                local bufnr = vim.api.nvim_get_current_buf()
                vim.schedule(function()
                    go_auto_import.add_import(bufnr, import_path, alias)
                end)
            end
            return alias .. "."
        end),
        i(0),
    }),
}, { type = "autosnippets" })
