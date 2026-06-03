; extends

(use
  "<-" @operator)

(let
  "=" @operator)

(let_assert
  "=" @operator)

((function_call
  function: (identifier) @function)
  (#set! priority 110))
