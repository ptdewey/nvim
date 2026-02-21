(import-macros {: pack! : spec! : require!} :macros)

(fn mini-hl [ctx]
  (let [(_ hl) ((. (require :mini.icons) :get) :lsp ctx.kind)]
    hl))

(let [columns [[:label] (doto [:kind_icon :kind :source_name] (tset :gap 1))]
      components {:kind_icon {:text (fn [ctx]
                                      (let [(icon) ((. (require :mini.icons)
                                                       :get) :lsp ctx.kind)]
                                        icon))
                              :highlight mini-hl}
                  :kind {:highlight mini-hl}
                  :source_name {:text #(.. "[" $.source_name "]")
                                :highlight mini-hl}}
      draw {:align_to :cursor : columns : components}
      completion {:documentation {:auto_show false}
                  :ghost_text {:enabled true}
                  :menu {: draw}}
      keymap {:preset :none
              :<C-h> [:select_and_accept]
              :<C-s> [:show :show_documentation :hide_documentation]
              :<C-e> [:hide]
              :<C-n> [:select_next :fallback_to_mappings]
              :<C-p> [:select_prev :fallback_to_mappings]}
      providers {:lsp {:score_offset 45}
                 :snippets {:score_offset 55}
                 :path {:score_offset 15}
                 :buffer {:score_offset 15}
                 :lazydev {:name :LazyDev
                           :module :lazydev.integrations.blink
                           :score_offset 46}
                 :ripgrep {:module :blink-ripgrep
                           :name :rg
                           :opts {:backend {:ripgrep {:max_filesize :400K}}}
                           :score_offset 1}
                 :copilot {:name :copilot
                           :module :blink-copilot
                           :score_offset 40
                           :async true}}
      sources {:default [:lsp :path :snippets :buffer :ripgrep :copilot]
               :per_filetype {:lua (doto [:lazydev]
                                     (tset :inherit_defaults true))}
               : providers}
      opts {: keymap
            :appearance {:nerd_font_variant :mono}
            :signature {:enabled true}
            : completion
            :snippets {:preset :luasnip}
            : sources
            :fuzzy {:implementation :prefer_rust_with_warning
                    :prebuilt_binaries {:force_version :v1.6.0}}}]
  (pack! [(spec! "https://github.com/saghen/blink.cmp"
                 {:version (vim.version.range :1.*)
                  :event :InsertEnter
                  :dep_of :obsidian.nvim
                  :after (fn []
                           (require! :blink-ripgrep)
                           ((. (require :profiler) :require_and_setup) :blink-cmp
                                                                       opts))})
          (spec! "https://github.com/mikavilpas/blink-ripgrep.nvim"
                 {:dep_of :blink.cmp})
          (spec! "https://github.com/fang2hou/blink-copilot"
                 {:dep_of :blink.cmp})]))
