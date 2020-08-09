#lang racket/base

(require (for-syntax racket/base
                     syntax/parse
                     racket/syntax
                     racket/class
                     racket/string
                     racket/list
                     racket/port
                     syntax/location)
         syntax/parse/define
         editor/base
         db
         sql
         (for-editor racket/list
                     racket/dict
                     racket/port
                     racket/string))

(begin-for-interactive-syntax
  (module+ test
    (require editor/test)))

(begin-for-syntax
  (define (sanatize name)
    (gensym)))

(unless (sqlite3-available?)
  (error "Please Install SQLite3"))
(define db (sqlite3-connect #:database 'memory))


(define-interactive-syntax form-builder$ vertical-block$
  (inherit add-child
           remove-child)
  (super-new)
  (define-state name ""
    #:setter (λ (v)
               (set! name v)
               (refresh-view))
    #:elaborator #t
    #:elaborator-default "")
  (define-state fields '()
    #:elaborator #t
    #:elaborator-default '()
    #:deserialize (λ (des)
                    (refresh-view des)
                    des))
  (define/public (add-field! text [contract ""])
    (set! fields (append fields (list (list text contract))))
    (refresh-view)
    this)
  (define/public (remove-field! text)
    (set! fields (remove text fields (λ (a b) (equal? text (first b)))))
    (refresh-view)
    this)
  (define (refresh-view [f* #f])
    (send this clear)
    (define top-row (new horizontal-block$ [parent this]))
    (new label$ [parent top-row]
         [text "define-form:"])
    (new field$ [parent top-row]
         [text name]
         [callback (λ (f e)
                     (set! name (send f get-text)))])
    (new blank$ [parent this]
         [height 2])
    (define items-row (new horizontal-block$ [parent this]))
    (define labels-col (new vertical-block$ [parent items-row]))
    (new blank$ [parent items-row]
         [width 70])
    (define contracts-col (new vertical-block$ [parent items-row]))
    (new blank$ [parent items-row]
         [width 70])
    (define remove-col (new vertical-block$ [parent items-row]))
    (for ([f (in-list (or f* fields))]
          [index (in-naturals)])
      (define text (first f))
      (define contract (second f))
      (new label$ [parent labels-col]
           [top-margin 2]
           [bottom-margin 2]
           [text text])
      (new label$ [parent contracts-col]
           [top-margin 2]
           [bottom-margin 2]
           [text contract])
      (new button$ [parent remove-col]
           [label
            (let ()
              (define hb (new horizontal-block$
                              [left-margin 0]
                              [right-margin 0]
                              [top-margin 0]
                              [bottom-margin 0]))
              (send hb set-background "white" 'transparent)
              (send (new blank$ [parent hb] [width 5])
                    set-background "white" 'transparent)
              (new label$ [parent hb] [text "-"])
              (send (new blank$ [parent hb] [width 5])
                    set-background "white" 'transparent)
              hb)]
           [callback (λ _
                       (remove-field! text))]))
    (new blank$ [parent this]
         [height 2])
    (define new-row
      (new horizontal-block$ [parent this]))
    (new label$ [parent new-row]
         [text "Field:"])
    (define new-text (new small-table-field$ [parent new-row]))
    (new label$ {parent new-row}
         [text "Type:"])
    (define new-contract (new small-table-field$ [parent new-row]))
    (new button$ [parent new-row]
         [label "+"]
         [callback (λ _
                     (add-field! (send new-text get-text)
                                 (send new-contract get-text)))]))
  (refresh-view)
  (define-elaborator this
    #:with name/sql (format-id this-syntax "~a"
                               (sanatize (send this get-name)))
    #:with name$ (format-id this-syntax "~a" (send this get-name))
    #:with fields (map first (send this get-fields))
    #:with (cnts ...) (for/list ([i (in-list (send this get-fields))])
                        (define con (second i))
                        (with-input-from-string (if (string=? con "")
                                                    "(λ _ #t)"
                                                    con)
                          read))
    #:with (fields/sql ...) (map (compose sanatize first) (send this get-fields))
    #`(begin
        (query-exec db (create-table name/sql #:columns [fields/sql text] ...))
        (require (for-editor (prefix-in : racket/class)))
        (begin-for-interactive-syntax
          (define table-base$
            (dynamic-require (from-editor #,(quote-module-path)) 'table-base$)))
        (define-interactive-syntax name$ table-base$
          (:super-new [keys 'fields]
                      [contracts (list cnts ...)]
                      [name 'name$])
          (define-elaborator this
            #`'#,(send this get-table))))))

(define-interactive-syntax small-table-field$ field$
  (super-new)
  (define/augment (get-extent)
    (values 100 1)))

(define-interactive-syntax table-field$ field$
  (super-new)
  (define/augment (get-extent)
    (values 300 1)))

(define-interactive-syntax table-base$ vertical-block$
  (super-new)
  (init keys contracts name)
  (define cleaned-name
    (let ([str (string-join (for/list ([str (in-list (string-split (symbol->string name) "-"))])
                              (string-set! str 0 (char-upcase (string-ref str 0)))
                              str)
                            " ")])
      (if (equal? (string-ref str (sub1 (string-length str))) #\$)
          (substring str 0 (sub1 (string-length str)))
          str)))
  (define-state table (hash)
    #:getter #t
    #:elaborator #t
    #:deserialize (λ (des)
                    (refresh-view des)
                    des))
  (define/public (set-field! key val)
    (set! table (dict-set table key val))
    (refresh-view #:focus key)
    this)
  (define (refresh-view [maybe-table #f]
                        #:focus [maybe-focus #f])
    (define view-table (or maybe-table table))
    (send this clear)
    (new label$ [parent this]
         [text cleaned-name])
    (new blank$ [parent this]
         [height 2])
    (define kv-row (new horizontal-block$ [parent this]))
    (define k-col (new vertical-block$ [parent kv-row]))
    (new blank$ [parent kv-row]
         [width 10])
    (define v-col (new vertical-block$ [parent kv-row]))
    (define focus
      (for/fold ([to-focus #f])
                ([key (in-list keys)]
                 [contract (in-list contracts)])
        (new blank$ [parent k-col]
             [height 1])
        (new blank$ [parent v-col]
             [height 1])
        (new label$ [parent k-col]
             [text key])
        (define item
          (if (procedure? contract)
              (new table-field$ [parent v-col]
                   [text (dict-ref view-table key "")]
                   [background (if (contract (with-input-from-string (hash-ref view-table key "#f") read))
                                   "white"
                                   "red")]
                   [callback (λ (t e)
                               (set-field! key (send t get-text)))])
              (new contract [parent v-col]
                   [context this]
                   [state (dict-ref view-table key #f)]
                   [callback (λ (t e)
                               (set-field! key t))])))
        (if (equal? key maybe-focus)
            item
            to-focus)))
    (when focus
      ;(send this set-child-focus kv-row)
      ;(send kv-row set-child-focus v-col)
      (send v-col set-child-focus focus)))
  (refresh-view))

(begin-for-interactive-syntax
  (module+ test
    (test-window (new form-builder$))))
