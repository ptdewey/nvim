(import-macros {: load!} :macros)

;; TODO: Rename to "Pact" add some wrappers to the commonly used functions.
;; - Possibly move plugins to a "register" pattern where loader is only called after all plugins are registered.
;; - Register pattern would allow fairly easy mass updating of plugins?

{:opts {:load (load!) :confirm false}}
