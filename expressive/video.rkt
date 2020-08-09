#lang editor editor/lang

(require (for-editor data/gvector
                     racket/dict))

(begin-for-interactive-syntax
  (module+ test
    (require editor/test)))

(define-interactive-syntax video-table$ vertical-block$
  (super-new))

(define-interactive-syntax insert-editor$ dialog$
  (inherit set-result! show)
  (super-new)
  (define options (new option-bundle$))
  (new labeled-option$ [parent this]
       [label "Filename"]
       [option (λ (this)
                 (new field$ [parent this]))]
       [bundle options]
       [bundle-label 'filename]
       [bundle-finalizer (λ (opt)
                           (send opt get-text))])
  (new labeled-option$ [parent this]
       [label "Track#"]
       [option (λ (this)
                 (new field$ [parent this]))]
       [bundle options]
       [bundle-label 'track]
       [bundle-finalizer (λ (opt)
                           (string->number (send opt get-text)))])
  (new labeled-option$ [parent this]
       [label "Length"]
       [option (λ (this)
                 (new field$ [parent this]))]
       [bundle options]
       [bundle-label 'length]
       [bundle-finalizer (λ (opt)
                           (send opt get-text))])
  (define confirm-row (new horizontal-block$ [parent this]))
  (new button$ [parent confirm-row]
       [label (new label$ [text "Cancel"])]
       [callback (λ (button event)
                   (show #f))])
  (new button$ [parent confirm-row]
       [label (new label$ [text "OK"])]
       [callback (λ (b event)
                   (set-result! (send options get-options))
                   (show #f))]))

(define-interactive-syntax video-editor$ vertical-block$
  (super-new)
  (define tracks (make-gvector))
  (define table (new vertical-block$ [parent this]))
  (define control-line (new horizontal-block$ [parent this]))
  (define/public (remove-clip-interactive btn event)
    (void))
  (define/public (add-video-interactive btn event)
    (define get-vid (new insert-editor$ [title "Insert Video"]))
    (send get-vid show #t)
    (define result (send get-vid get-result))
    (define track# (dict-ref result 'track))
    (when track#
      (for ([i (in-range (- track# (gvector-count tracks)))])
        (define row (new horizontal-block$ [parent table]))
        (gvector-add! tracks (cons row (make-gvector))))
      (define track (gvector-ref tracks (sub1 track#)))
      (gvector-add! (cdr track)
                    (new button$ [parent (car track)]
                         [label (new label$ [text (or (dict-ref result 'filename) "")])]
                         [callback (list this 'remove-clip-interactive)]))))
  (new button$ [parent this]
       [label (new label$ [text "Add Clip"])]
       [callback (list this 'add-video-interactive)]))

(begin-for-interactive-syntax
  (module+ test
    (test-window
     (new video-editor$))))
