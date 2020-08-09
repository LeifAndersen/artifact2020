#lang editor/lang

(require racket/serialize
         (for-syntax racket/base
                     pict
                     racket/draw
                     racket/serialize
                     racket/class)
         (for-editor racket/gui/base
                     racket/port
                     racket/path
                     racket/list
                     pict))

(begin-for-interactive-syntax
  (module+ test
    (require rackunit)))

(define-interactive-syntax image-data$ widget$ 
  (super-new)
  (init [(ip picture) #f])
  (define-state display-width #f
    #:getter #t
    #:setter #t)
  (define-state display-height #f
    #:getter #t
    #:setter #t)
  (define-state distort? #f
    #:setter #t)
  (define-state resize? #f
    #:setter #t)
  (define-state background? #f
    #:setter #t)
  (define-state picture #f
    #:elaborator (λ ()
                   (cond [(pict? picture) picture]
                         [(is-a? picture bitmap%)
                          (bitmap picture)]
                         [(bytes? picture)
                          (bitmap (make-object bitmap% (open-input-bytes picture)))]
                         [else #f]))
    #:getter (λ ()
               (define p
                 (cond
                   [(pict? picture) picture]
                   [(is-a? picture bitmap%)
                    (bitmap picture)]
                   [else #f]))
               (cond [resize?
                      (scale-to-fit p display-width display-height
                                    #:mode (if distort? 'distort 'preserve))]
                     [else p]))
    #:setter (λ (new)
               (set! picture new))
    #:serialize (λ (new)
                  (cond
                    [(pict? new) new]
                    [(is-a? new bitmap%)
                     (call-with-output-bytes
                       (λ (out)
                         (send new save-file out 'png 100)))]))
    #:deserialize (λ (new)
                    (cond [(pict? new)
                             new]
                          [(bytes? new)
                           (define bit (make-object bitmap% (open-input-bytes new)))
                             bit]
                          [else (error 'picture "Could not deserialize ~a" new)])))
  (define/augment (get-extent)
    (when picture
      (define new-width
        (cond [(number? display-width) display-width]
              [(pict? picture)
               (pict-width picture)]
              [(is-a? picture bitmap%)
               (send picture get-width)]))
      (define new-height
        (cond [(number? display-height) display-height]
              [(pict? picture)
               (pict-height picture)]
              [(is-a? picture bitmap%)
               (send picture get-height)]))
      (values new-width new-height)))
  (define/augment (draw dc)
    (define p
      (let* ([_ (get-picture)])
        (if (and display-width display-height)
            (scale-to-fit _ display-width display-height #:mode 'distort)
            _)))
    (define bit (pict->bitmap p))
    (send dc draw-bitmap bit 0 0)
    (void))
  (cond [ip (set-picture! ip)]
        [(not picture) (set-picture! (text "Set Image"))]))

(define-interactive-syntax image-selector$ dialog$
  (inherit show
           set-result!)
  (super-new)
  (new label$ [parent this]
       [text "Select Image"])
  (define image-name (new field$ [parent this]))
  (define w-text (send (new labeled-option$ [parent this]
                            [option (λ (par) (new field$ [parent par]))]
                            [label "Width"])
                       get-option))
  (define h-text (send (new labeled-option$ [parent this]
                            [option (λ (par) (new field$ [parent par]))]
                            [label "Height"])
                       get-option))
  (define back? (send (new labeled-option$ [parent this]
                          [option (λ (par) (new toggle$ [parent par]))]
                          [label "Background?"])
                     get-option))
  (define resize? (send (new labeled-option$ [parent this]
                             [option (λ (par) (new toggle$ [parent par]))]
                             [label "Resize?"])
                        get-option))
  (define distort? (send (new labeled-option$ [parent this]
                              [option (λ (par) (new toggle$ [parent par]))]
                              [label "Distort?"])
                         get-option))
  (define confirm-row (new horizontal-block$ [parent this]))
  (new button$ [parent confirm-row]
       [label (new label$ [text "Cancel"])]
       [callback (λ (button event)
                   (show #f))])
  (new button$ [parent confirm-row]
       [label (new label$ [text "OK"])]
       [callback (λ (b event)
                   (set-result! (list (send image-name get-text)
                                      (send w-text get-text)
                                      (send h-text get-text)
                                      (send back? get-value)
                                      (send resize? get-value)
                                      (send distort? get-value)))
                   (show #f))]))

(define-interactive-syntax labeled-option$ horizontal-block$
  (init-field option
              [label ""])
  (super-new)
  (new label$ [parent this]
       [text label])
  (define opt (option this))
  (define/public (get-option)
    opt))

(define-interactive-syntax image$ button$
  #:interfaces (receiver<$>)
  (inherit set-label! get-path)
  (define-state data (new image-data$)
    #:getter (λ () (send data get-picture))
    #:setter (λ (new)
               (send data set-picture! new)
               (set-label! data))
    #:deserialize (λ (new)
                    (set-label! new)
                    new)
    #:elaborator-default (new image-data$)
    #:elaborator (λ () (send data get-picture)))
  (define-elaborator this
    #`(deserialize '#,(serialize (send this get-data))))
  (define/public (on-receive sender message)
    (cond
      [(and (is-a? message control-event%)
            (eq? (send message get-event-type) 'button))
       (define f (new dialog%
                      [label "Image Selector"]))
       (define dialog (new image-selector$ [frame f]))
       (send dialog show #t)
       (define here (get-path))
       (define res (send dialog get-result))
       (when res
         (define free-path (first res))
         (define maybe-width (string->number (second res)))
         (define maybe-height (string->number (third res)))
         (define background? (fourth res))
         (define resize? (fifth res))
         (define distort? (sixth res))
         (define rooted-path
           (cond
             [(complete-path? free-path) free-path]
             [(not here) (build-path (current-directory) free-path)]
             [else (build-path (path-only here) free-path)]))
         (define maybe-data
           (and (not (or (equal? rooted-path #f) (equal? rooted-path "")))
                (make-object bitmap% rooted-path)))
         (when maybe-data
           (set-data! maybe-data)
           (send data set-display-width! maybe-width)
           (send data set-display-height! maybe-height)
           (send data set-resize?! resize?)
           (send data set-distort?! distort?)
           (send data set-background?! background?)))
       (void)]))
  (super-new [label data]
             [callback this]))

(begin-for-interactive-syntax
  (module+ test
    (new image$)))
