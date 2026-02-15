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
        return t("err")
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

local function handle_result_node(node)
    local node_type = node:type()
    if node_type == "parameter_list" then
        local result = {}
        local count = node:named_child_count()
        for idx = 0, count - 1 do
            local type_node = node:named_child(idx):field("type")[1]
            table.insert(result, zero_value(vim.treesitter.get_node_text(type_node, 0)))
            if idx ~= count - 1 then
                table.insert(result, t({ ", " }))
            end
        end
        return result
    end
    return { zero_value(vim.treesitter.get_node_text(node, 0)) }
end

local function_node_types = {
    function_declaration = true,
    method_declaration = true,
    func_literal = true,
}

local function go_result_type()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    local parser = vim.treesitter.get_parser(0, "go")
    if not parser then
        return { t("") }
    end

    local root = parser:parse()[1]:root()
    local cursor_node = root:named_descendant_for_range(row, col, row, col)

    -- Find enclosing function
    local fn_node = cursor_node
    while fn_node and not function_node_types[fn_node:type()] do
        fn_node = fn_node:parent()
    end
    if not fn_node then
        return { t("") }
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

    for _, node in query:iter_captures(fn_node, 0) do
        return handle_result_node(node)
    end

    return { t("") }
end

local go_ret_vals = function(args)
    return sn(nil, go_result_type())
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
