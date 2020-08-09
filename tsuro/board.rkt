#lang editor racket

(require "tsuro.rkt"
         rackunit)

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
     q
     (#f #f (7 3 4 1 2 6 5 0) #f)
     (#f #f #f #f)
     (#f #f #f #f)
     ((4 5 7 6 0 1 3 2) #f #f (4 2 1 7 0 6 5 3)))
    (players q (2 0 0) (0 3 7) (3 3 4))))))


;; Warning, check only passes due to dummy equal-to method in tsuro-game% class!!!
(check-equal? (send #editor((4)
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
     q
     (#f #f (7 3 4 1 2 6 5 0) #f)
     (#f #f #f #f)
     (#f #f #f #f)
     ((4 5 7 6 0 1 3 2) #f #f (4 2 1 7 0 6 5 3)))
    (players q (2 0 0) (0 3 7) (3 3 4)))))) addTile #editor((4)
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
  (c (? . 1) q tsuro-tile$)
  c
  (c (mpi (c submod c (? . 0) q deserializer) ? . 1) q tsuro-tile$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q tsuro-tile$:elaborate)))((4)
 1
 (((submod (relative up #"tsuro.rkt") deserializer) . tsuro-tile$:deserialize))
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
    horizontal-block$
    (? . 0))
   tsuro-tile$
   (h
    -
    (equal)
    (pairs
     h
     -
     (equal)
     ("F" u . "B")
     ("G" u . "A")
     ("D" u . "C")
     ("E" u . "H")
     ("B" u . "F")
     ("C" u . "D")
     ("A" u . "G")
     ("H" u . "E")))))) 'player0) #editor((4)
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
     q
     (#f (6 5 3 2 7 1 0 4) (7 3 4 1 2 6 5 0) #f)
     (#f #f #f #f)
     (#f #f #f #f)
     ((4 5 7 6 0 1 3 2) #f #f (4 2 1 7 0 6 5 3)))
    (players q (2 0 0) (0 3 7) (3 3 4)))))))

(check-equal?
 (send
  (new tsuro-game%
       [tiles (hash '(2 0) '(H D E B C G F A)
                    '(0 3) '(E F H G A B D C)
                    '(3 3) '(E C B H A G F D))]
       [players (hash 'player1 '(2 0 0)
                      'player2 '(0 3 7)
                      'player3 '(3 3 4))])
  addTile '(6 5 3 2 7 1 0 4) 'player0)
 (new tsuro-game%
      [tiles (hash '(2 0) '(H D E B C G F A)
                   '(0 3) '(E F H G A B D C)
                   '(3 3) '(E C B H A G F D)
                   '(1 0) '(G F D C H B A E))]
      [players (hash 'player1 '(2 0 0)
                     'player2 '(0 3 7)
                     'player3 '(3 3 4))]))
