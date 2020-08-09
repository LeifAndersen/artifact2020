#lang racket

(require (for-syntax racket))

(define-syntax (m x)
  (define a #'42)
  (define b x)
  (f a b))

(begin-for-syntax
  (define (f x y)
    (define a x)
    (define b y)
    (define z #'84)
    (k a b c))
  (define-syntax (k x)
    (g))
  (begin-for-syntax
    (define (g)
      #'#'168)))

(m)
