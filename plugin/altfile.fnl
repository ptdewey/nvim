(import-macros {: nmap} :macros)

(local config {:alternates [[:.go :_test.go]]})

(fn escape-suffix [suffix]
  (suffix:gsub "%." "%%."))

(fn find-altfile [filepath]
  (var result nil)
  (each [_ pair (ipairs config.alternates) &until result]
    (let [pattern-a (.. (escape-suffix (. pair 1)) "$")
          pattern-b (.. (escape-suffix (. pair 2)) "$")]
      (if (filepath:match pattern-b)
          (set result (filepath:gsub pattern-b (. pair 1)))
          (filepath:match pattern-a)
          (set result (filepath:gsub pattern-a (. pair 2))))))
  (when (not result)
    (print (.. "No alternate file found for '" filepath "'")))
  result)

(fn open []
  (let [altfile (find-altfile (vim.fn.expand "%:p"))]
    (when altfile
      (vim.cmd (.. "e " altfile)))))

(nmap :<leader>af open {:desc "alternate file"})
