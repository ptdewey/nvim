; extends: markdown
; extends: jsx
((jsx_element) @injection.content
  (#set! injection.language "markdown"))

((jsx_expression) @injection.content
  (#set! injection.language "javascript"))
