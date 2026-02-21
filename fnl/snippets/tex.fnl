(let [p (. (require :luasnip.util.parser) :parse_snippet)]
  [(p :beg "\\begin{${1}}\n\t${0}\n\\end{${1}}")
   (p :sec "\\section{${1}}\n${0}")
   (p :sub "\\subsection{${1}}\n${0}")
   (p :frac "\\frac{${1:numerator}}{${2:denominator}}${0}")
   (p :sum "\\sum_{${1:lower}}^{${2:upper}} ${3:expression}")
   (p :list "\\begin{itemize}\n\t\\item ${1}\n\\end{itemize}\n${0}")
   (p :bf "\\textbf{${1}}${0}")
   (p :it "\\textit{${1}}${0}")])
