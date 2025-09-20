(let [plugin-dir (.. (vim.fn.stdpath :config) :/fnl/plugins)
      files (vim.fn.split (vim.fn.globpath plugin-dir :*.fnl) "\n")]
  (each [_ file (ipairs files)]
    (let [filename (vim.fn.fnamemodify file ":t:r")]
      (when (not= filename :init)
        (require (.. :plugins. filename))))))
