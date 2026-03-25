;; TODO: rename back to sprig.fnl once finished the port.
;; Make sure to update .sprig.lua to build this file in the nvim dir

(local M {})
(local config-dir (vim.fn.stdpath :config))
(local cache-dir (.. (vim.fn.stdpath :cache) :/sprig))
(local config-cache {})
(local fennel-path :/deps/fennel-1.6.1.lua)

(fn find-config [fnl-path]
  (let [dir (vim.fn.fnamemodify fnl-path :h)
        cached (. config-cache dir)]
    ;; FIX: this doesn't match the lua behavior
    (if cached {:config cached.config :root cached.root}
        {:config nil :root nil})))

(fn is-ignored [fnl-path cfg root]
  (if (and cfg cfg.ignore)
      (let [rel (fnl-path:sub (+ (length root) 2))]
        (accumulate [found false _ pattern (ipairs cfg.ignore) &until found]
          (if (rel:match pattern) true false)))
      false))

(fn fnl-to-lua-path [fnl-path cfg root]
  (if (and cfg cfg.paths)
      (let [rel (fnl-path:sub (+ (length root) 2))]
        (each [pattern replacement (pairs cfg.paths)]
          (let [mapped (rel:gsub pattern replacement)]
            (when (not= mapped rel) (.. root "/" mapped)))))
      (.. cache-dir "/" (: (: (fnl-path:sub (+ (length root) 2)) :gsub :^fnl/
                              :lua/) :gsub "%.fnl$"
                           :.lua))))

(fn is-macro-file [fnl-path cfg root]
  (if (and cfg cfg.macros)
      (let [rel (fnl-path:sub (+ (length root) 2))]
        (accumulate [found false _ pattern (ipairs cfg.macros) &until found]
          (if (rel:match pattern) true false)))
      false))

(fn get-fennel []
  (if M._fennel
      M._fennel
      (let [chunk (loadfile (.. config-dir fennel-path))
            saved-arg arg
            saved-print print
            fennel (require :fennel)
            macro-path (.. config-dir "/fnl/?.fnl;" config-dir :/fnl/?/init.fnl)]
        (set arg [:--version])
        (set print (fn []))
        (pcall chunk)
        (set arg saved-arg)
        (set print saved-print)
        (set fennel.macro-path (.. macro-path ";" (or fennel.macro-path "")))
        (set M._fennel fennel)
        fennel)))

(fn M.compile [fnl-path]
  (let [fnl-path (vim.fn.resolve fnl-path)
        c (find-config fnl-path)]
    (when (and c.root (is-ignored fnl-path c.cfg c.root)
               (is-macro-file fnl-path c.cfg c.root))
      (let [f (io.open fnl-path :r)]
        (if (not f)
            (vim.notify (.. "sprig: cannot read" fnl-path vim.log.levels.ERROR))
            (let [source (f:read :*a)
                  fennel (get-fennel)
                  compiler-opts (and c.cfg (or c.cfg.compiler {}))
                  compile-opts {:filename fnl-path
                                :compilerEnv (or compiler-opts.compilerEnv _G)
                                :allowGlobals (not= compiler-opts.allowGlobals
                                                    false)
                                :correlate (or compiler-opts.correlate false)}]
              (f:close)))
        ;; TODO: finish writing this function
        M))))

M
