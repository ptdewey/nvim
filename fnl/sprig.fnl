;; TODO: rename back to sprig.fnl once finished the port.
;; Make sure to update .sprig.lua to build this file in the nvim dir
(local vim _G.vim)

(local M {})
(local config-dir (vim.fn.stdpath :config))
(local cache-dir (.. (vim.fn.stdpath :cache) :/sprig))
(local config-cache {})
(local fennel-path :/deps/fennel-1.6.1.lua)

(fn find-config [fnl-path]
  (let [dir (vim.fn.fnamemodify fnl-path ":h")
        cached (. config-cache dir)]
    (if (= cached false) (values nil nil) (not= cached nil)
        (values cached.config cached.root)
        (let [found (vim.fn.findfile :.sprig.lua (.. dir ";"))]
          (if (= found "")
              (do
                (tset config-cache dir false)
                (values nil nil))
              (let [config-path (vim.fn.fnamemodify found ":p")
                    root (vim.fn.fnamemodify config-path ":h")
                    (ok cfg) (pcall dofile config-path)
                    cfg (if (and ok (= (type cfg) :table)) cfg {})]
                (tset config-cache dir {:config cfg : root})
                (values cfg root)))))))

(fn is-ignored [fnl-path cfg root]
  (if (and cfg cfg.ignore)
      (let [rel (fnl-path:sub (+ (length root) 2))]
        (accumulate [found false _ pattern (ipairs cfg.ignore) &until found]
          (or found (not= nil (rel:match pattern)))))
      false))

(fn is-macro-file [fnl-path cfg root]
  (if (and cfg cfg.macros)
      (let [rel (fnl-path:sub (+ (length root) 2))]
        (accumulate [found false _ pattern (ipairs cfg.macros) &until found]
          (or found (not= nil (rel:match pattern)))))
      false))

(fn fnl-to-lua-path [fnl-path cfg root]
  (let [rel (fnl-path:sub (+ (length root) 2))]
    (or (when (and cfg cfg.paths)
          (var result nil)
          (each [pattern replacement (pairs cfg.paths) &until result]
            (let [mapped (rel:gsub pattern replacement)]
              (when (not= mapped rel)
                (set result (.. root "/" mapped)))))
          result)
        (let [remapped (-> rel
                           (: :gsub :^fnl/ :lua/)
                           (: :gsub "%.fnl$" :.lua))]
          (.. cache-dir "/" remapped)))))

(fn get-fennel []
  (if M._fennel
      M._fennel
      (let [chunk (loadfile (.. config-dir fennel-path))
            saved-arg arg
            saved-print print]
        (set arg [:--version])
        (set print (fn []))
        (pcall chunk)
        (set arg saved-arg)
        (set print saved-print)
        (let [fennel (require :fennel)
              macro-path (.. config-dir "/fnl/?.fnl;" config-dir
                             :/fnl/?/init.fnl)]
          (set fennel.macro-path (.. macro-path ";" (or fennel.macro-path "")))
          (set M._fennel fennel)
          fennel))))

(fn M.compile [fnl-path]
  (let [fnl-path (vim.fn.resolve fnl-path)
        (cfg root) (find-config fnl-path)]
    (when (and root (not (is-ignored fnl-path cfg root))
               (not (is-macro-file fnl-path cfg root)))
      (let [f (io.open fnl-path :r)]
        (if (not f)
            (vim.notify (.. "sprig: cannot read " fnl-path)
                        vim.log.levels.ERROR)
            (let [source (f:read :*a)]
              (f:close)
              (let [fennel (get-fennel)
                    compiler-opts (or (and cfg cfg.compiler) {})
                    compile-opts {:filename fnl-path
                                  :compilerEnv (or compiler-opts.compilerEnv _G)
                                  :allowGlobals (not= compiler-opts.allowGlobals
                                                      false)
                                  :correlate (or compiler-opts.correlate false)}
                    saved-macro-path (when (not= root config-dir)
                                       fennel.macro-path)]
                (when (not= root config-dir)
                  (set fennel.macro-path
                       (.. root "/fnl/?.fnl;" root "/fnl/?/init.fnl;"
                           fennel.macro-path)))
                (let [(ok result) (pcall fennel.compileString source
                                         compile-opts)]
                  (when saved-macro-path
                    (set fennel.macro-path saved-macro-path))
                  (if (not ok)
                      (vim.notify (.. "sprig: " (tostring result))
                                  vim.log.levels.ERROR)
                      (let [lua-path (fnl-to-lua-path fnl-path cfg root)]
                        (vim.fn.mkdir (vim.fn.fnamemodify lua-path ":h") :p)
                        (let [out (io.open lua-path :w)]
                          (if (not out)
                              (vim.notify (.. "sprig: cannot write " lua-path)
                                          vim.log.levels.ERROR)
                              (do
                                (out:write result)
                                (out:close))))))))))))))

(fn M.clean []
  (let [lua-files (vim.fn.globpath cache-dir :**/*.lua false true)]
    (var removed 0)
    (each [_ lua-path (ipairs lua-files)]
      (let [rel (-> (lua-path:sub (+ (length cache-dir) 2))
                    (: :gsub :^lua/ :fnl/)
                    (: :gsub "%.lua$" :.fnl))
            fnl-path (.. config-dir "/" rel)]
        (when (= (vim.fn.filereadable fnl-path) 0)
          (os.remove lua-path)
          (set removed (+ removed 1)))))
    (when (> removed 0)
      (vim.notify (.. "sprig: removed " removed " orphaned files")))))

(fn M.compile_all [?root]
  (let [root (or ?root config-dir)
        files (vim.fn.globpath root :**/*.fnl false true)]
    (var count 0)
    (each [_ fnl-path (ipairs files)]
      (M.compile fnl-path)
      (set count (+ count 1)))
    (M.clean)
    (vim.notify (.. "sprig: compiled " count " files"))))

(fn M.setup []
  (let [existing (vim.fn.globpath cache-dir :**/*.lua false true)]
    (when (= (length existing) 0)
      (M.compile_all)
      (set package.path
           (.. cache-dir "/lua/?.lua;" cache-dir "/lua/?/init.lua;"
               package.path))
      (vim.loader.reset)))
  (let [group (vim.api.nvim_create_augroup :sprig {:clear true})]
    (vim.api.nvim_create_autocmd :BufWritePost
                                 {:pattern :*.fnl
                                  : group
                                  :callback (fn [ev] (M.compile ev.match))})
    (vim.api.nvim_create_user_command :SprigCompileAll (fn [] (M.compile_all))
                                      {:desc "Compile all .fnl files to .lua"})
    (vim.api.nvim_create_user_command :SprigClean
                                      (fn []
                                        (vim.fn.delete cache-dir :rf)
                                        (vim.notify (.. "sprig: cleared "
                                                        cache-dir)))
                                      {:desc "Remove all compiled .lua files from the sprig cache"})))

M
