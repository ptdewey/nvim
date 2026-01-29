local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.sn
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

-- Auto-import module
local go_auto_import = require("go_auto_import")

local transforms = {
    bool = function(_, _)
        return t("false")
    end,

    string = function(_, _)
        return t([[""]])
    end,

    error = function(_, _)
        return t("err")
    end,

    -- All numeric types return 0
    [function(text)
        local numeric_types = {
            "int",
            "int8",
            "int16",
            "int32",
            "int64",
            "uint",
            "uint8",
            "uint16",
            "uint32",
            "uint64",
            "uintptr",
            "float32",
            "float64",
            "complex64",
            "complex128",
            "byte",
            "rune",
        }
        for _, t in ipairs(numeric_types) do
            if text == t then
                return true
            end
        end
        return false
    end] = function(_, _)
        return t("0")
    end,

    -- Pointer types (e.g., *MyStruct, *int, etc.)
    [function(text)
        return string.match(text, "^%*")
    end] = function(_, _)
        return t("nil")
    end,

    -- Slice types (e.g., []int, []MyStruct)
    [function(text)
        return string.match(text, "^%[%]")
    end] = function(_, _)
        return t("nil")
    end,

    -- Map types (e.g., map[string]int)
    [function(text)
        return string.match(text, "^map%[")
    end] = function(_, _)
        return t("nil")
    end,

    -- Channel types (e.g., chan int, <-chan int, chan<- int)
    [function(text)
        return string.match(text, "chan")
            or string.match(text, "^<%-chan")
            or string.match(text, "chan<%-")
    end] = function(_, _)
        return t("nil")
    end,

    -- Array types (e.g., [5]int)
    [function(text)
        return string.match(text, "^%[%d+%]")
    end] = function(text, _)
        return t(text .. "{}")
    end,

    -- Interface types (interface{} or any)
    [function(text)
        return text == "interface{}" or text == "any"
    end] = function(_, _)
        return t("nil")
    end,

    -- Function types (func(...) ...)
    [function(text)
        return string.match(text, "^func%(")
    end] = function(_, _)
        return t("nil")
    end,

    -- Named struct types (e.g., MyStruct, http.Response, pkg.Type) - must be capitalized and not a built-in type
    [function(text)
        -- Check if it's a capitalized identifier or qualified name (pkg.Type) that doesn't match any of the above patterns
        local first_char = string.sub(text, 1, 1)
        local is_qualified = string.match(text, "^[%a_][%w_]*%.[%a_][%w_]*$") -- pkg.Type pattern
        local is_simple = string.match(text, "^[%a_][%w_]*$") -- Simple identifier

        return (string.upper(first_char) == first_char and is_simple)
            or is_qualified
                and not string.match(text, "^%*")
                and not string.match(text, "^%[")
                and not string.match(text, "^map%[")
                and not string.match(text, "chan")
                and not string.match(text, "^func%(")
                and text ~= "interface{}"
                and text ~= "any"
    end] = function(text, _)
        return t(text .. "{}")
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

-- Generic handler for single types - extracts text and transforms it
local function handle_single_type(node, info)
    local text = vim.treesitter.get_node_text(node, 0)
    return { transform(text, info) }
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

    -- All single type handlers use the same logic
    type_identifier = handle_single_type,
    pointer_type = handle_single_type,
    qualified_type = handle_single_type,
    slice_type = handle_single_type,
    map_type = handle_single_type,
    array_type = handle_single_type,
    channel_type = handle_single_type,
    function_type = handle_single_type,
    interface_type = handle_single_type,
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
    s(
        "func",
        fmt("func {}({}) {}{{\n\t{}\n}}", {
            c(1, {
                sn(nil, {
                    i(1),
                }),
                sn(nil, {
                    t("("),
                    i(1),
                    t(") "),
                    i(2),
                }),
            }),
            i(2),
            i(3),
            i(4),
        })
    ),

    s("print", fmt('fmt.Println("{}")', { i(1) })),

    s(
        "typ",
        fmt(
            "type {} {} {{\n\t{}\n}}{}",
            { i(1), c(2, { t("struct"), t("interface") }), i(3), i(0) }
        )
    ),

    -- TODO: autopopulate return? might need additional work to smartly grab variable if one matches the return type, otherwise add one
    -- - repeat an entry for each return type in function signature.
    -- s("return", fmt("return {}{}"), { d(1, go_ret_vals), i(0) }),

    s(
        "err",
        fmt("if {} != nil {{\n\treturn {}\n}}\n{}", { i(1, "err"), d(2, go_ret_vals, { 1 }), i(0) })
    ),

    s("lerr", fmt("log.Println(err){}", { i(0) })),
})

-- =============================================================================
-- Auto-import Autosnippets
-- =============================================================================
-- These snippets trigger automatically when you type "alias." and will:
-- 1. Auto-import the package if not already imported
-- 2. Keep the "alias." text so you can continue typing the function/method
--
-- The import path is resolved by:
-- 1. First checking the codebase for existing imports with that alias
-- 2. Falling back to standard library packages
-- When conflicts exist, the most frequently used import in the codebase wins.
--
-- IMPORTANT: Only triggers in valid contexts:
-- - Inside function/method bodies
-- - Variable declarations (var x = pkg.Func())
-- - Short variable declarations (x := pkg.Func())
-- - Function parameters
-- - Struct field types
-- - Type declarations
-- Does NOT trigger:
-- - After another dot (e.g., log.Print won't trigger on Print)
-- - In import statements
-- - In comments
-- - In string literals
-- =============================================================================

-- Valid parent node types where auto-import should trigger
local valid_auto_import_contexts = {
    -- Inside function bodies
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

    -- Variable/const declarations
    var_declaration = true,
    const_declaration = true,
    var_spec = true,
    const_spec = true,

    -- Function parameters and return types
    parameter_declaration = true,
    parameter_list = true,
    variadic_parameter_declaration = true,

    -- Struct fields
    field_declaration = true,
    field_declaration_list = true,

    -- Type declarations
    type_declaration = true,
    type_spec = true,

    -- Expressions (for nested calls like foo(pkg.Bar()))
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

    -- Interface method declarations
    method_elem = true,
    method_spec_list = true,
}

-- Contexts where we should NOT trigger (even if parent is valid)
local invalid_auto_import_contexts = {
    import_declaration = true,
    import_spec = true,
    import_spec_list = true,
    comment = true,
    interpreted_string_literal = true,
    raw_string_literal = true,
    rune_literal = true,
    -- Already a selector expression (pkg.Something) - don't trigger again
    selector_expression = true,
}

-- Check if we're in a valid context for auto-import using tree-sitter
local function is_valid_auto_import_context()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Check filetype
    if vim.bo[bufnr].filetype ~= "go" then
        return false
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    -- Adjust column to be before the dot we just typed
    if col > 0 then
        col = col - 1
    end

    local parser = vim.treesitter.get_parser(bufnr, "go")
    if not parser then
        return false
    end

    local tree = parser:parse()[1]
    if not tree then
        return false
    end

    local root = tree:root()
    local node = root:named_descendant_for_range(row, col, row, col)

    if not node then
        return false
    end

    -- Walk up the tree to check context
    local current = node
    local found_valid = false

    while current do
        local node_type = current:type()

        -- Check for invalid contexts first (these take priority)
        if invalid_auto_import_contexts[node_type] then
            return false
        end

        -- Check for valid contexts
        if valid_auto_import_contexts[node_type] then
            found_valid = true
        end

        current = current:parent()
    end

    return found_valid
end

-- Check if the character before the alias is a dot (to avoid log.Print triggering)
local function has_preceding_dot(line_to_cursor, matched_trigger)
    -- Find where the match starts
    local match_start = #line_to_cursor - #matched_trigger

    -- Check if there's a dot before the match
    if match_start > 0 then
        local char_before = line_to_cursor:sub(match_start, match_start)
        if char_before == "." then
            return true
        end
    end

    return false
end

-- Combined condition check for auto-import snippets
local function should_auto_import(line_to_cursor, matched_trigger, captures)
    -- Must have a valid capture
    if not captures or not captures[1] then
        return false
    end

    local alias = captures[1]

    -- Don't trigger if there's a dot before (e.g., log.Print)
    if has_preceding_dot(line_to_cursor, matched_trigger) then
        return false
    end

    -- Must be a known package alias
    local import_path = go_auto_import.get_import_path(alias)
    if not import_path then
        return false
    end

    -- Must be in a valid context (tree-sitter check)
    if not is_valid_auto_import_context() then
        return false
    end

    return true
end

-- =============================================================================
-- Dynamic auto-import snippet using pattern trigger
-- =============================================================================
-- Matches any identifier followed by a dot, then checks:
-- 1. Not preceded by another dot
-- 2. Is a known package alias
-- 3. Is in a valid code context (not in imports, comments, strings, etc.)
-- =============================================================================

ls.add_snippets("go", {
    s({
        trig = "([%a_][%w_]*)%.",
        trigEngine = "pattern",
        snippetType = "autosnippet",
        wordTrig = true,
        desc = "Dynamic auto-import for any package",
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
