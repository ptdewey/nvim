(import-macros {: pack! : require! : setup!} :macros)

(macro mini-spec [mod opts ...]
  (let [h [...]
        handlers {}]
    (for [i 1 (length h) 2]
      (when (< i (length h))
        (tset handlers (. h i) (. h (+ i 1)))))
    `(vim.tbl_extend :force
                     {:name (.. :mini. ,mod)
                      :load (setup! (.. :mini. ,mod) ,opts)}
                     ,handlers)))

; (macro mini-spec [mod opts ...]
;   (let [handlers [...]
;         extra-table {}]
;     (for [i 1 (length handlers) 2]
;       (when (< i (length handlers))
;         (tset extra-table (. handlers i) (. handlers (+ i 1)))))
;     `(vim.tbl_extend :force
;                      {:name (.. :mini. ,mod)
;                       :load (fn []
;                               (setup! (.. :mini. ,mod) ,opts))}
;                      ,extra-table)))

(let [specs [(mini-spec :ai {} :event [:BufReadPost :BufNewFile])
             (mini-spec :jump {} :keys [:t :f :T :F])]]
  ((. (require :lze) :load) [specs]))
