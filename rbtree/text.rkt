#lang racket

(require racket/struct
         "rbtree.rkt")

; Rotate Left              
;    x              y      
;   / \            / \     
;  A   y    -->   x   C    
;     / \        / \       
;    B   C      A   B      
(define/match (rotate-left t)
  [((struct* tree
             ([value value] [left left] [color color]
                            [right
                             (struct* tree
                                      ([value r-value]
                                       [left r-left]
                                       [right r-right]
                                       [color r-color]))])))
   (mk-tree #:left (mk-tree #:value value
                            #:left left
                            #:right r-left
                            #:color color)
            #:right r-right #:value r-value #:color r-color)])

