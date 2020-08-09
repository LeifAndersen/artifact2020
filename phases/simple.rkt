#lang editor/lang

(require (for-syntax racket/base
                     racket/class
                     pict)
         (for-editor pict
                     racket/gui/base))

(begin-for-interactive-syntax
  (module+ test
    (require editor/test)))

;; Normally its better to extend widget$ instead of base$.
(define-interactive-syntax simple$ base$
  (super-new)
  (define-state picture (blank)
    #:init #t)
  
  (define/augment (draw ctx)
    (send ctx draw-bitmap (pict->bitmap picture) 0 0))
  
  (define/augment (get-extent)
    (values (pict-width picture) (pict-height picture)))
  
  (define/augment (on-event event)
    (cond [(is-a? event mouse-event%)
           (displayln "Mouse Event")]))
  
  (define-elaborator this
    #`#,(send (pict->bitmap (send this get-picture)) get-argb-pixels)))

(begin-for-interactive-syntax
  (module+ test
    (test-window
     (new simple$ [picture (circle 50)]))))
