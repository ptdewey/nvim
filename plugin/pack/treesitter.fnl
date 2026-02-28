(import-macros {: pack! : raw-setup! : autocmd! : when-not : when-ok} :macros)

(pack! "https://github.com/nvim-treesitter/nvim-treesitter" {:version :main})

(raw-setup! :nvim-treesitter {:install_dir (.. (vim.fn.stdpath :data) :/site)})

(let [cb (fn [event]
           (let [ignored-fts [:lua
                              :vimdoc
                              :mininotify
                              :ministarter
                              :fzf
                              :fzf-lua
                              :Pathfinder
                              :blink-cmp-menu
                              :blink-cmp-documentation
                              :kulala_http
                              :jjdescription
                              :mason
                              :mason_backdrop]]
             (when (vim.tbl_contains ignored-fts event.match)
               (lua :return)))
           (when-ok [nvim-treesitter :nvim-treesitter]
                    (let [ft (. vim.bo event.buf :ft)
                          lang (vim.treesitter.language.get_lang ft)]
                      (: (nvim-treesitter.install [lang]) :await
                         (fn [err]
                           (when err
                             (vim.notify (.. "Treesitter install error for ft: "
                                             ft " err: " err))
                             (lua :return))
                           (pcall vim.treesitter.start event.buf)
                           (set vim.bo.indentexpr
                                "v:lua.require'nvim-treesitter'.indentexpr()")
                           (set vim.wo.foldexpr
                                "v:lua.vim.treesitter.foldexpr()"))))))]
  (autocmd! :FileType {:callback cb}))

(macro parser! [tbl name info]
  `(tset ,tbl ,name {:install_info ,info}))

(let [cb #(let [p (require :nvim-treesitter.parsers)
                adocRev :fc36cdfc2577c5c64fcb1b1e00c910d572713586
                adocUrl "https://github.com/cathaysia/tree-sitter-asciidoc"]
            (parser! p :asciidoc
                     {:url adocUrl
                      :revision adocRev
                      :location :tree-sitter-asciidoc
                      :queries :tree-sitter-asciidoc/queries})
            (parser! p :asciidoc_inline
                     {:url adocUrl
                      :revision adocRev
                      :location :tree-sitter-asciidoc_inline
                      :queries :tree-sitter-asciidoc_inline/queries})
            (parser! p :d2 {:url "https://github.com/ravsii/tree-sitter-d2"
                            :revision :ffb66ce4c801a1e37ed145ebd5eca1ea8865e00f
                            :queries :queries})
            (parser! p :norg
                     {:url "https://github.com/ptdewey/tree-sitter-norg"
                      :revision :e2c403175f94f2c7658ba03fdebb2c064621708f})
            (parser! p :norg_meta
                     {:url "https://github.com/nvim-neorg/tree-sitter-norg-meta"
                      :revision :6f0510cc516a3af3396a682fbd6655486c2c9d2d}))]
  (autocmd! :User {:pattern :TSUpdate :callback cb}))
