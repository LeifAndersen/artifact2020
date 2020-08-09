#lang editor racket

(require "spec.rkt")

(define parse-header
  #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"spec.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q spec$)
  c
  (c (mpi (c submod c (? . 0) q deserializer) ? . 1) q spec$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q spec$:elaborate)))((4)
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
     (c (u . "source-port") . 16)
     c
     (c (u . "destination-port") . 16)
     c
     (c (u . "sequence-number") . 32)
     c
     (c (u . "acknowledgement-number") . 32)
     c
     (c (u . "data-offset") . 4)
     c
     (c (u . "reserved") . 6)
     c
     (c (u . "urg") . 1)
     c
     (c (u . "ack") . 1)
     c
     (c (u . "psh") . 1)
     c
     (c (u . "rst") . 1)
     c
     (c (u . "syn") . 1)
     c
     (c (u . "fin") . 1)
     c
     (c (u . "window") . 16)
     c
     (c (u . "checksum") . 16)
     c
     (c (u . "urgent-pointer") . 16)))))))


(module+ test
  (define pattern
    (bytes-append
     #"\x00\x00\x03\x04\x00\x06\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00"
     #"\x45\x00\x00\x37\x21\x2d\x40\x00\x40\x06\x1b\x92\x7f\x00\x00\x01"
     #"\x7f\x00\x00\x01\xbf\x3e\x23\x82\xc6\xfe\xe6\xeb\xbe\xb9\x01\x07"
     #"\x80\x18\x02\x00\xfe\x2b\x00\x00\x01\x01\x08\x0a\x10\xde\xd5\xe7"
     #"\x10\xde\xd5\xe7\x48\x69\x0a"))

  (parse-header pattern))
