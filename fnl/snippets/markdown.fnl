(let [ls (require :luasnip)
      p (. (require :luasnip.util.parser) :parse_snippet)]
  [(p :link "[${1}](${2})${0}")
   (p :image "![${1}](${2})${0}")
   (p :comment "<!-- ${1} -->${0}")
   (p "<--" "<!-- ${1} -->${0}")])
