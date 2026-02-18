;; fennel-ls: macro-file

(fn map [mode key action opts]
  `(vim.keymap.set ,mode ,key ,action ,opts))

(fn nmap [key action opts]
  `(vim.keymap.set :n ,key ,action ,opts))

(fn vmap [key action opts]
  `(vim.keymap.set :x ,key ,action ,opts))

(fn imap [key action opts]
  `(vim.keymap.set :i ,key ,action ,opts))

(fn tmap [key action opts]
  `(vim.keymap.set :t ,key ,action ,opts))

(lambda del-map! [mode key]
  `(vim.keymap.del ,mode ,key))

(lambda normal! [arg]
  `(vim.cmd (.. :normal! ,arg)))

(lambda o [key value]
  `(set (. vim.o ,key) ,value))

(lambda g [key value]
  `(set (. vim.g ,key) ,value))

(lambda user-cmd! [name command opts]
  `(vim.api.nvim_create_user_command ,name ,command ,opts))

(lambda autocmd! [event opts]
  `(vim.api.nvim_create_autocmd ,event ,opts))

(fn load! []
  `(fn [p#]
     (let [spec# (or p#.spec.data {})]
       (set spec#.name p#.spec.name)
       ((. (require :profiler) :wrap_triggers) spec#)
       ((. (require :lze) :load) spec#))))

(fn spec! [src opts]
  "Build a vim.pack spec from a URL and an options table"
  (let [spec-keys {:name true :version true}
        spec {: src}
        data {}]
    (when opts
      (each [k v (pairs opts)]
        (if (. spec-keys k)
            (tset spec k v)
            (tset data k v))))
    (when (next data)
      (set spec.data data))
    spec))

(fn pack! [first opts]
  (if (sequence? first)
      ;; Sequence syntax: (pack! [(spec! ...) (spec! ...)] opts?)
      `(vim.pack.add ,first (or ,opts {:load ,(load!) :confirm false}))
      ;; Table syntax: (pack! "url" {:cmd :Foo :after ...})
      `(vim.pack.add [,(spec! first opts)] {:load ,(load!) :confirm false})))

(fn require! [mod]
  `((. (require :profiler) :require) ,mod))

(fn raw-setup! [mod opts]
  `((. (require :profiler) :require_and_setup) ,mod ,opts))

(fn setup! [mod opts ...]
  (let [body [...]]
    (if (> (length body) 0)
        (let [result `(fn []
                        ((. (require :profiler) :require_and_setup) ,mod ,opts))]
          (each [_ form (ipairs body)]
            (table.insert result form))
          result)
        `#((. (require :profiler) :require_and_setup) ,mod ,opts))))

{: map
 : nmap
 : vmap
 : imap
 : tmap
 : del-map!
 : normal!
 : o
 : g
 : user-cmd!
 : spec!
 : pack!
 : autocmd!
 : load!
 : raw-setup!
 : setup!
 : require!}
