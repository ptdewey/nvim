{:filetypes [:go :gomod :gosum :gowork :gotmpl]
 :cmd [:gopls]
 :settings {:gopls {:hints {:rangeVariableTypes true
                            :parameterNames true
                            :constantValues true
                            :assignVariableTypes true
                            :compositeLiteralFields true
                            :compositeLiteralTypes true
                            :functionTypeParameters true}
                    :semanticTokens false}}}
