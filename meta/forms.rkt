#lang editor editor/lang

(require "implementation.rkt")

#editor((4)
 0
 ()
 2
 ((mpi (c submod c (p* up #"implementation.rkt") q editor) . #f) "..")
 ()
 (c
  (c (? . 0) q form-builder$)
  c
  (c
   (mpi (c submod c (? . 1) q deserializer) ? . 0)
   q
   form-builder$:deserialize)
  c
  (c (mpi (c submod c (? . 1)) ? . 0) q form-builder$:elaborate)))((4)
 1
 (((submod (relative up #"implementation.rkt") deserializer)
   .
   form-builder$:deserialize))
 2
 ((h - (equal)) "")
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
   form-builder$
   (h
    -
    (equal)
    (fields
     c
     (c (u . "Student Name:") c (? . 1))
     c
     (c (u . "Student ID:") c (? . 1))
     c
     (c (u . "Grade:") c (? . 1))
     c
     (c (u . "Comments") c (? . 1)))
    (name u . "student-form$")))))

#editor((4)
 0
 ()
 2
 ((mpi (c submod c (p* up #"implementation.rkt") q editor) . #f) "..")
 ()
 (c
  (c (? . 0) q form-builder$)
  c
  (c
   (mpi (c submod c (? . 1) q deserializer) ? . 0)
   q
   form-builder$:deserialize)
  c
  (c (mpi (c submod c (? . 1)) ? . 0) q form-builder$:elaborate)))((4)
 1
 (((submod (relative up #"implementation.rkt") deserializer)
   .
   form-builder$:deserialize))
 2
 ((h - (equal)) "")
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
   form-builder$
   (h
    -
    (equal)
    (fields
     c
     (c (u . "Grader Name:") c (? . 1))
     c
     (c (u . "Grader ID:") c (? . 1))
     c
     (c (u . "Grader Email:") c (? . 1))
     c
     (c (u . "Student 1:") c (? . 1))
     c
     (c (u . "Student 2:") c (? . 1)))
    (name u . "grader-form$")))))