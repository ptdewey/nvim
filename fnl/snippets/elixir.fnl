(let [p (. (require :luasnip.util.parser) :parse_snippet)]
  [(p :mod "%__MODULE__{${1}}${0}")])
