(import-macros {: pack! : raw-setup! : autocmd! : when-not : when-ok} :macros)

(pack! "https://github.com/nvim-treesitter/nvim-treesitter" {:version :main})

;; nvim-treesitter can't be lazy loaded
(raw-setup! :nvim-treesitter {:install_dir (.. (vim.fn.stdpath :data) :/site)})

(local ensure-installed [:go
                         :bash
                         :markdown
                         :markdown_inline
                         :fennel
                         :query
                         :json
                         :yaml
                         :sql
                         :html
                         :toml
                         :http])

(let [cb (fn [event]
           (let [ft (. vim.bo event.buf :ft)
                 lang (vim.treesitter.language.get_lang ft)]
             (when (pcall vim.treesitter.language.add lang)
               (pcall vim.treesitter.start event.buf)
               (set vim.bo.indentexpr
                    "v:lua.require'nvim-treesitter'.indentexpr()")
               (set vim.wo.foldexpr "v:lua.vim.treesitter.foldexpr()"))))]
  (autocmd! :FileType {:callback cb}))

(autocmd! :PackChanged
          {:callback (fn [ev]
                       (let [{: name} ev.data.spec
                             kind ev.data.kind]
                         (when (and (= name :nvim-treesitter)
                                    (or (= kind :install) (= kind :update)))
                           (when (not ev.data.active)
                             (vim.cmd "packadd nvim-treesitter"))
                           (when-ok [nvim-treesitter :nvim-treesitter]
                                    (: (nvim-treesitter.install ensure-installed)
                                       :await)))))})

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
            (parser! p :snapshot
                     {:url "https://github.com/ptdewey/shutter"
                      :revision :3262e8451414b62a03e81bd2677dd299488db6f2
                      :location :editor/tree-sitter-snapshot
                      :queries :tree-sitter-snapshot/queries}))]
  (autocmd! :User {:pattern :TSUpdate :callback cb}))
