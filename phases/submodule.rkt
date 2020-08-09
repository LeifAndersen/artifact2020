#lang racket

(module+ test
  (require rackunit))

;; inc : [Box Integer] -> Void 
;; increment the content of the given box by 1 

(module+ test
  (let ([x (box 0)])
    (check-equal? (unbox x) 0)
    (inc x)
    (check-equal? (unbox x) 1)))

(define (inc counter)
  (set-box! counter (add1 (unbox counter))))
