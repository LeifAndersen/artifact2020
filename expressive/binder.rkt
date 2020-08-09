#lang editor editor/lang

(provide define/vis)
(require "image.rkt"
         syntax/parse/define
         racket/hash
         (for-syntax pict
                     syntax/parse
                     racket/base
                     racket/class
                     racket/serialize
                     racket/syntax
                     racket/pretty
                     racket/set))

(begin-for-syntax
  (define elab-mode (make-parameter 'ref)))

(define-syntax-parser define-introducer
  [(_ i)
   #:with scopeless-intro (datum->syntax #f 'arbitrary)
   #:with scoped-intro ((make-syntax-introducer) #'scopeless-intro)
   #'(begin-for-syntax
       (define i
         (make-syntax-delta-introducer #'scoped-intro #'scopeless-intro)))])
(define-introducer introducer)

(define-syntax-parser define/vis
  [(_ x body)
   (define/syntax-parse x*
     (introducer (datum->syntax #'x (syntax->datum (local-expand #'x 'expression #f)))))
   #`(define x* body)])

(define-interactive-syntax binder$ image$
  (super-new)
  (define-elaborator this
    (let* ([x (send this get-data)]
           [x (pict->argb-pixels x)]
           [x (equal-hash-code x)])
      (introducer (format-id this-syntax "icon:~a" x)))))
