(let [p (. (require :luasnip.util.parser) :parse_snippet)]
  [(p :usr/bin "#!/usr/bin/env bash\n\n${0}")])
