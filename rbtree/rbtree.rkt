#lang racket/base

(provide mk-tree mk-empty-tree
         (struct-out tree))
(require racket/match
         racket/struct)

(module+ test
  (require rackunit
           racket/port
           racket/pretty))

(struct tree (color
              value
              left
              right)
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (λ (obj) 'tree)
      (λ (obj) (list (cons 'value (tree-value obj))
                     (cons 'color (tree-color obj))
                     (cons 'left (tree-left obj))
                     (cons 'right (tree-right obj))))))]
  #:methods gen:equal+hash
  [(define (equal-proc this other rec) (and (rec (tree-color this) (tree-color other))
                                            (rec (tree-value this) (tree-value other))
                                            (rec (tree-left this)  (tree-left other))
                                            (rec (tree-right this) (tree-right other))))
   (define (hash-proc this rec) (rec (tree-value this)))
   (define (hash2-proc this rec) (rec (tree-value this)))])
(define (mk-empty-tree)
  (tree 'black #f #f #f))
(define (mk-tree #:color [color 'red]
                 #:value [value #f]
                 #:left [left (mk-empty-tree)]
                 #:right [right (mk-empty-tree)])
  (tree color value left right))

(define/match (tree-count t)
  [((struct* tree ([left #f] [right #f])))
   0]
  [((struct* tree ([left left] [right right])))
   (+ 1 (tree-count left) (tree-count right))])

(define/match (tree-max-depth t)
  [((struct* tree ([left #f] [right #f])))
   0]
  [((struct* tree ([left left] [right right])))
   (add1 (max (tree-max-depth left) (tree-max-depth right)))])

(module+ test
  (define (valid-tree? t)
    (define-values (good? count?)
      (let loop ([t t]
                 [par-color 'red])
        (match t
          [(struct* tree ([left #f] [right #f])) (values #t 0)]
          [(struct* tree ([left left]
                          [right right]
                          [color color]))
           (define-values (l-good l-red) (loop left color))
           (define-values (r-good r-red) (loop right color))
           (values
            (and (or (equal? color 'black)
                     (equal? par-color 'black))
                 l-good
                 r-good
                 (= l-red r-red))
            (if (equal? color 'black)
                (add1 l-red)
                l-red))])))
    good?)
  
  (check-equal? (mk-tree) (mk-tree))
  (check-equal? (mk-empty-tree) (mk-empty-tree))
  (check-pred integer? (equal-hash-code (mk-empty-tree)))
  (check-pred integer? (equal-secondary-hash-code (mk-empty-tree)))
  (check-equal? (tree-count (mk-tree)) 1)
  (parameterize ([current-output-port (open-output-nowhere)])
    (pretty-write (mk-empty-tree))))

(define (node<? a b)
  (< (equal-hash-code (tree-value a)) (equal-hash-code (tree-value b))))

(module+ test
  (check-false (node<? (mk-empty-tree) (mk-empty-tree)))
  (check-true (node<? (mk-tree #:value 2) (mk-tree #:value 3)))
  (check-false (node<? (mk-tree #:value 3) (mk-tree #:value 2))))

(define/match (tree-empty? t)
  [((struct* tree ([left #f]
                   [right #f])))
   #t]
  [(_) #f])

(module+ test
  (check-false (tree-empty? (mk-tree)))
  (check-true (tree-empty? (mk-empty-tree))))

(define (to-black t)
  (struct-copy tree t [color 'black]))

(module+ test
  (check-equal? (tree-color (to-black (mk-tree))) 'black))

(define/match (rotate-left t)
  [((struct* tree ([value value]
                   [left left]
                   [color color]
                   [right (struct* tree ([value r-value]
                                         [left r-left]
                                         [right r-right]
                                         [color r-color]))])))
   (mk-tree #:left (mk-tree #:value value
                            #:left left
                            #:right r-left
                            #:color color)
            #:right r-right
            #:value r-value
            #:color r-color)])

(define/match (rotate-right t)
  [((struct* tree ([color color]
                   [value value]
                   [right right]
                   [left (struct* tree ([color l-color]
                                        [value l-value]
                                        [left l-left]
                                        [right l-right]))])))
   (mk-tree #:right (mk-tree #:left l-right
                             #:value value
                             #:right right
                             #:color color)
            #:left l-left
            #:value l-value
            #:color l-color)])

(module+ test
  (let ()
    (define t (mk-tree #:left (mk-tree #:value 'A)
                       #:right (mk-tree #:value 'B)))
    (check-equal? (rotate-right (rotate-left t)) t)))

(define/match (recolor t)
  [((struct* tree ([left left] [right right])))
   (struct-copy tree t
                [color 'red]
                [left (to-black left)]
                [right (to-black right)])])

(module+ test
  (let ()
    (define t (mk-tree #:color 'black
                       #:left (mk-tree)
                       #:right (mk-tree)))
    (define t* (recolor t))
    (check-equal? (tree-color t*) 'red)
    (check-equal? (tree-color (tree-left t*)) 'black)
    (check-equal? (tree-color (tree-right t*)) 'black)))

(define/match (balance t)
  [((struct* tree ([color 'red])))
   t]
  [((struct* tree ([left (struct* tree ([color 'red]))]
                   [right (struct* tree ([color 'red]))])))
   (recolor t)]
  [((struct* tree ([left (struct* tree ([color 'red]
                                        [left (struct* tree ([color 'red]))]))])))
   (recolor (rotate-right t))]
  [((struct* tree ([left (and left
                              (struct* tree ([color 'red]
                                             [right (struct* tree ([color 'red]))])))])))
   (recolor (rotate-right (struct-copy tree t [left (rotate-left left)])))]
  [((struct* tree ([right (struct* tree ([color 'red]
                                        [right (struct* tree ([color 'red]))]))])))
   (recolor (rotate-left t))]
  [((struct* tree ([right (and right
                               (struct* tree ([color 'red]
                                              [left (struct* tree ([color 'red]))])))])))
   (recolor (rotate-left (struct-copy tree t [right (rotate-right right)])))]
  [(_) t])

(define (insert t val)
  (define node (mk-tree #:value val))
  (to-black
   (let loop ([t t]
              [node node])
     (cond [(tree-empty? t)
            node]
           [(node<? t node)
            (balance
             (struct-copy tree t
                          [right (balance (loop (tree-right t) node))]))]
           [else
            (balance
             (struct-copy tree t
                          [left (balance (loop (tree-left t) node))]))]))))

(module+ test
  (let* ([_ (mk-empty-tree)]
         [_ (insert _ 1)]
         [_ (insert _ 2)]
         [_ (insert _ 3)])
    (check-equal? (tree-count _) 3)
    (check-equal? (tree-max-depth _) 2)
    (check-pred valid-tree? _)))

(module+ test
  (let* ([_ (mk-empty-tree)]
         [_ (insert _ 3)]
         [_ (insert _ 1)]
         [_ (insert _ 8)]
         [_ (insert _ 5)]
         [_ (insert _ 2)]
         [_ (insert _ 4)]
         [_ (insert _ 9)])
    (check-equal? (tree-count _) 7)
    (check-equal? (tree-max-depth _) 4)))
