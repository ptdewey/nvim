; extends

; Conceal and add nice icons to headers
(atx_heading
  (atx_h1_marker) @markup.heading.1
  (#set! conceal "◉"))

(atx_heading
  (atx_h2_marker) @markup.heading.2
  (#set! conceal "◎"))

(atx_heading
  (atx_h3_marker) @markup.heading.3
  (#set! conceal "○"))

(atx_heading
  (atx_h4_marker) @markup.heading.4
  (#set! conceal "✺"))

(atx_heading
  (atx_h5_marker) @markup.heading.5
  (#set! conceal "▶"))

(atx_heading
  (atx_h6_marker) @markup.heading.6
  (#set! conceal "▶"))

; Conceal and set a nice icon for bullets
(list_item
  (list_marker_minus) @comment
  (#set! conceal "•"))

(list_item
  (list_marker_star) @comment
  (#set! conceal "•"))
