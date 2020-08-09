#lang editor at-exp racket

(require "forms.rkt")

(define assignment1 (list #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"forms.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q student-form$)
  c
  (c
   (mpi (c submod c (? . 0) q deserializer) ? . 1)
   q
   student-form$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q student-form$:elaborate)))((4)
 1
 (((submod (relative up #"forms.rkt") deserializer)
   .
   student-form$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      list-block$$
      (h - (equal) (focus . #f)))
     vertical-block$
     (? . 0))
    table-base$
    (h
     -
     (equal)
     (table
      h
      -
      (equal)
      ("Student ID:" u . "1234")
      ("Comments" u . "Missing Problem 2.")
      ("Student Name:" u . "Bob Smith")
      ("Grade:" u . "B+"))))
   student-form$
   (? . 0)))) #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"forms.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q student-form$)
  c
  (c
   (mpi (c submod c (? . 0) q deserializer) ? . 1)
   q
   student-form$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q student-form$:elaborate)))((4)
 1
 (((submod (relative up #"forms.rkt") deserializer)
   .
   student-form$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      list-block$$
      (h - (equal) (focus . #f)))
     vertical-block$
     (? . 0))
    table-base$
    (h
     -
     (equal)
     (table
      h
      -
      (equal)
      ("Student ID:" u . "01337")
      ("Comments" u . "Turned in late.")
      ("Student Name:" u . "Matt Fredrick")
      ("Grade:" u . "C"))))
   student-form$
   (? . 0))))))

#editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"forms.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q grader-form$)
  c
  (c
   (mpi (c submod c (? . 0) q deserializer) ? . 1)
   q
   grader-form$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q grader-form$:elaborate)))((4)
 1
 (((submod (relative up #"forms.rkt") deserializer)
   .
   grader-form$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      list-block$$
      (h - (equal) (focus . #f)))
     vertical-block$
     (? . 0))
    table-base$
    (h
     -
     (equal)
     (table
      h
      -
      (equal)
      ("Grader Email:" u . "")
      ("Student 2:" u . "Matt Fredrick")
      ("Student 1:" u . "Bob Smith")
      ("Grader Name:" u . "Jane Allison")
      ("Grader ID:" u . "31415"))))
   grader-form$
   (? . 0))))

(define (send-email address message)
  (void))

;; [Listof GradeForm] -> Void
(define (send-grades assignment-grades)
  (for ((student (in-list assignment-grades)))
    (send-email
     (dict-ref student "Student Email")
     (compose-message student))))

;; GradeForm -> [Listof String]
(define (compose-message student)
  @list{Hello @(dict-ref student "Student Name"),
              your grade on assignment 1 is:
              @(dict-ref student "Grade")
              Comments:
              @(dict-ref student "Comments")})
