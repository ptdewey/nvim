local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("go", {
    s(
        "func",
        fmt("func {}({}) {}{{\n\t{}\n}}", {
            c(1, {
                ls.sn(nil, { i(1) }),
                ls.sn(nil, { t("("), i(1), t(") "), i(2) }),
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
    s("lerr", fmt("log.Println(err){}", { i(0) })),
})
