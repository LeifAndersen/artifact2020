#lang editor racket

(require "tsuro.rkt")

(define DEGREES (list 0 1 2 3))

(define board (new tsuro-game%
                   [tiles '()]
                   [players '()]))

(define (all-possible-configurations/text t)
  (for/list ([d DEGREES])
    (send board addTile (send t rotate d))))

(define (all-possible-configurations t)
  (for/list ([d DEGREES])
    #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"tsuro.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q tsuro-board$)
  c
  (c
   (mpi (c submod c (? . 0) q deserializer) ? . 1)
   q
   tsuro-board$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q tsuro-board$:elaborate)))((4)
 1
 (((submod (relative up #"tsuro.rkt") deserializer)
   .
   tsuro-board$:deserialize))
 0
 ()
 ()
 (0
  0
  (v!
   (v! #f base$ (h - (equal)))
   tsuro-board$
   (h
    -
    (equal)
    (width . 4)
    (height . 4)
    (board
     c
     (q #f #f (7 3 4 1 2 6 5 0) #f)
     c
     (q #f #f #f #f)
     c
     (q #f #f #f #f)
     c
     (c (c text c (u . "(send t rotate d)")) q #f #f (4 2 1 7 0 6 5 3)))
    (players q (2 0 0) (0 3 7) (3 3 4))))))))

(module+ test
  (for/list ([board (all-possible-configurations (new tsuro-tile% [connections '(1 0 3 2 7 6 5 4)]))])
    (send board get-tiles)))
