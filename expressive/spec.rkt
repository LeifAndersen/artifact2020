#lang editor/lang

(require bitsyntax
         (for-syntax racket/class
                     racket/base))

(define-interactive-syntax item$ label$
  (super-new)
  (define-state min-width 0
    #:init #t)
  (define/augment (get-extent)
    (values min-width 0)))

(define-interactive-syntax spec$ vertical-block$
  (super-new)
  (define-state word-size 32
    #:deserialize (λ (des)
                    (set! word-size des)
                    (refresh-view)
                    des))
  (define-state items '()
    #:elaborator #t
    #:deserialize (λ (des)
                    (set! items des)
                    (refresh-view)
                    des))
  (define pixels-per-bit 30)
  (define (refresh-view)
    (send this clear)
    ;; Word size row
    (define word-size-row (new horizontal-block$ [parent this]))
    (new label$ [parent word-size-row]
         [text "Word Size:"])
    (new field$ [parent word-size-row]
         [text (number->string word-size)]
         [callback (λ (f e)
                     (set! word-size
                           (max 1 (or (string->number (send f get-text)) 1)))
                     (refresh-view))])
    ;; Lay out Items
    (for/fold ([bits 0]
               [row (new horizontal-block$ [parent this])])
              ([item (in-list items)])
      (define name (car item))
      (define new-bits (cdr item))
      (define total-bits (+ new-bits bits))
      (new item$ [parent row]
           [text name]
           [min-width (* new-bits pixels-per-bit)])
      (if (total-bits . >= . word-size)
          (values (modulo total-bits word-size)
                  (new horizontal-block$ [parent this]))
          (values total-bits
                  row)))
    ;; New Item Row
    (define new-row (new horizontal-block$ [parent this]))
    (new label$ [parent new-row]
         [text "Item Name:"])
    (define item-name (new field$ [parent new-row]))
    (new label$ [parent new-row]
         [text "Bit Count:"])
    (define bit-count (new field$ [parent new-row]))
    (new button$ [parent new-row]
         [label "+"]
         [callback (λ (b e)
                     (set! items (append items (list (cons (send item-name get-text)
                                                           (max 1 (or (string->number (send bit-count get-text)) 1))))))
                     (refresh-view))]))
  (refresh-view)
  (define-elaborator this
    #:with (item ...) (map (compose string->symbol car) (send this get-items))
    #:with (bit-width ...) (map cdr (send this get-items))
    #`(λ (bs)
        (bit-string-case
         bs
         ([(item :: binary bits 'bit-width) ...
          (rest :: binary)]
         (list item ...))))))

(begin-for-interactive-syntax
  (module+ test
    (require editor/test)
    (test-window (new spec$))))
