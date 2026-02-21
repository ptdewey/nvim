(let [ls (require :luasnip)
      {: s : insert_node : text_node : choice_node : sn} ls
      fmt (. (require :luasnip.extras.fmt) :fmt)
      i insert_node
      t text_node
      c choice_node]
  [(s :func (fmt "func {}({}) {}{{\n\t{}\n}}"
                 [(c 1
                     [(sn nil [(i 1)]) (sn nil [(t "(") (i 1) (t ") ") (i 2)])])
                  (i 2)
                  (i 3)
                  (i 4)]))
   (s :typ
      (fmt "type {} {} {{\n\t{}\n}}{}"
           [(i 1) (c 2 [(t :struct) (t :interface)]) (i 3) (i 0)]))
   (s :print (fmt "fmt.Println(\"{}\")" [(i 1)]))
   (s :lerr (fmt "log.Println(err){}" [(i 0)]))])
