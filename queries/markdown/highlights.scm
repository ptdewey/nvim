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
; NOTE: done via matchadd in ftplugin/markdown.fnl because
; list_marker_minus node width varies with nesting depth (2-4 chars),
; so #offset! with fixed values can't reliably isolate just the dash
