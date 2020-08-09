#lang editor editor/lang

(require editor/base
         math/matrix
         racket/class
         data/gvector
         (for-syntax racket/base
                     racket/syntax)
         (for-editor racket/gui/base
                     racket/math
                     racket/match
                     data/gvector))

(define-interactive-syntax matrix-state$ base$
  #:interfaces (receiver<$>)
  (super-new)
  (define-state width 0
    #:getter #t
    #:setter (λ (new-width)
               (set! width new-width)
               (resize-matrix)))
  (define-state height 0
    #:getter #t
    #:setter (λ (new-height)
               (set! height new-height)
               (resize-matrix)))
  (define-state values (make-gvector)
    #:getter #t)
  (define/private (resize-matrix)
    (define new-length (* width height))
    (define old-length (gvector-count values))
    (if (new-length . > . old-length)
        (for ([i (in-range (- new-length old-length))])
          (gvector-add! values 0))
        (for ([i (in-range (- old-length new-length))])
          (gvector-remove-last! values))))
  (define/public (set-cell! row col val)
    (gvector-set! values (+ (* row width) col) val))
  (define/public (on-receive sender event)
    (cond
      [(is-a? event control-event%)
       (when (eq? (send event get-event-type) 'text-field)
         (set-cell! (send sender get-row)
                    (send sender get-col)
                    (string->number (send sender get-text))))])))

(define-interactive-syntax cell$ field$
  (init [(ir row) 0]
        [(ic col) 0])
  (define-state row ir
    #:getter #t
    #:persistence #f)
  (define-state col ic
    #:getter #t
    #:persistence #f)
  (super-new))

(define-interactive-syntax matrix-body$ vertical-block$
  (inherit count
           remove-child
           in-children
           get-parent)
  (super-new)
  (define/public (fill-cells cells width)
    (for ([row (in-children)]
          [i (in-naturals)])
      (for ([cell (send row in-children)]
            [j (in-naturals)])
        (send cell set-text!
              (number->string (gvector-ref cells (+ (* i width) j)))))))
  ;; Change the dimentions of the matrix to the new width/height.
  (define/public (change-dimensions width height)
    (define height-diff (abs (- height (count))))
    ;; First grow rows
    (cond
      [(height . < . (count))
       (for ([_ (in-range height-diff)])
         (remove-child))]
      [(height . > . (count))
       (for ([_ (in-range height-diff)])
         (new horizontal-block$ [parent this]))])
    ;; Then collumns in thos rows
    (for ([row (in-children)]
          [row-index (in-naturals)])
      (define existing-width (send row count))
      (define width-diff (abs (- width existing-width)))
      (cond
        [(width . < . existing-width)
         (for ([_ (in-range width-diff)])
           (send row remove-child))]
        [(width . > . existing-width)
         (for ([_ (in-range width-diff)]
               [col-index (in-naturals existing-width)])
           (new cell$ [parent row]
                [row row-index]
                [col col-index]
                [text "0"]
                [callback (send this get-parent)]))]))))

(define-interactive-syntax matrix$ (signaler$$ vertical-block$)
  #:interfaces (receiver<$>)
  (super-new)
  (define-state state (new matrix-state$)
    #:getter #t)
  (define-elaborator this
    #'(let ()
        (define state (send this get-state))
        (vector->matrix (send state get-height)
                        (send state get-width)
                        (gvector->vector (send state get-values)))))
  (define/public (on-receive sender message)
    (send state on-receive sender message))
  (define w-row (new horizontal-block$ [parent this]))
  (define h-row (new horizontal-block$ [parent this]))
  (new label$ [parent w-row] [text "Width: "])
  (define/public (w-str-callback this event)
    (define w (string->number (send this get-text)))
    (when (and w (natural? w))
      (send state set-width! w)
      (send the-matrix change-dimensions
            (send state get-width)
            (send state get-height))))
  (define w-str (new field$ [parent w-row]
                     [text (number->string (send state get-width))]
                     [callback (list this 'w-str-callback)]))
  (new label$ [parent h-row] [text "Height: "])
  (define/public (h-str-callback this event)
    (define h (string->number (send this get-text)))
    (when (and h (natural? h))
      (send state set-height! h)
      (send the-matrix change-dimensions
            (send state get-width)
            (send state get-height))))
  (define h-str (new field$ [parent h-row]
                     [text (number->string (send state get-height))]
                     [callback (list this 'h-str-callback)]))
  (define the-matrix (new matrix-body$ [parent this])))

(begin-for-interactive-syntax
  (module+ test
    (require editor/test)
    (test-window (new matrix$))))

