(import-macros {: pack! : setup!} :macros)

(let [opts {:options {:icons_enabled true
                      :theme :auto
                      :component_separators "|"
                      :section_separators ""
                      :disabled_filetypes {:statusline [:undotree :diff]}}
            :sections {:lualine_b []
                       :lualine_c [{1 :filename :path 5 :padding 1}]
                       :lualine_x [:diagnostics :diff]
                       :lualine_y [:branch]}}]
  (pack! "https://github.com/ptdewey/lualine.nvim"
         {:event :UIEnter :after (setup! :lualine opts)}))
