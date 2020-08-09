#lang editor racket

(require "spec.rkt")

#editor((4)
 0
 ()
 2
 ((mpi (c submod c (p* up #"spec.rkt") q editor) . #f) "..")
 ()
 (c
  (c (? . 0) q spec$)
  c
  (c (mpi (c submod c (? . 1) q deserializer) ? . 0) q spec$:deserialize)
  c
  (c (mpi (c submod c (? . 1)) ? . 0) q spec$:elaborate)))((4)
 1
 (((submod (relative up #"spec.rkt") deserializer) . spec$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
     list-block$$
     (h - (equal) (focus . #f)))
    vertical-block$
    (? . 0))
   spec$
   (h
    -
    (equal)
    (word-size . 32)
    (items
     c
     (c (u . "1") . 32)
     c
     (c (u . "2") . 32)
     c
     (c (u . "3") . 32)
     c
     (c (u . "4") . 32))))))
