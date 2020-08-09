#lang editor/lang

(require racket/match
         "rbtree.rkt"
         (for-editor racket/list
                     images/icons/arrow
                     framework
                     pict
                     pict/tree-layout
                     data/gvector
                     racket/set
                     racket/string
                     racket/stream
                     racket/draw
                     racket/draw/arrow
                     racket/match
                     racket/port
                     graph
                     racket/gui/event)
         (for-syntax racket/base
                     racket/match
                     racket/dict
                     racket/class
                     racket/list
                     racket/syntax
                     syntax/parse
                     graph
                     editor/private/editor))

(begin-for-interactive-syntax
  (module+ test
    (require editor/test
             racket/serialize)))

(begin-for-interactive-syntax
  (define node-diam 60)
  (define code-node-diam 240)
  (define code-node (filled-rectangle code-node-diam (/ node-diam 1.5)
                               #:color "white"))
  (define red-node (disk node-diam #:color "crimson"))
  (define black-node (disk node-diam #:color "black"))
  (define subtree-node
    (scale-to-fit
     (dc (λ (dc dx dy)
           (define old-brush (send dc get-brush))
           (send dc set-brush (new brush% [color "white"]))
           (define path (new dc-path%))
           (send path move-to 25 0)
           (send path line-to 0 100)
           (send path line-to 100 100)
           (send path line-to 75 0)
           (send path close)
           (send dc draw-path path dx dy)
           (send dc set-brush old-brush))
        100 100)
     node-diam node-diam)))

(define-interactive-syntax node$ widget$
  (inherit set-background)
  (define code-editor (new racket:text%))
  (define-state type 'red
    #:elaborator #t
    #:getter #t
    #:init #t)
  (define-state name ""
    #:elaborator #t
    #:getter #t
    #:init #t)
  (super-new)
  (define/augment (get-extent)
    (case type
      [(code)
       (values code-node-diam (/ node-diam 1.5))]
      [else
       (values node-diam node-diam)]))
  (set-background "white" 'transparent)
  (define/augment (draw dc)
    (define picture
      (cc-superimpose
       (case type
         [(red) red-node]
         [(black) black-node]
         [(subtree) subtree-node]
         [(code) code-node])
       (case type
         [(red) (text name (list (make-object color% "white")) 36)]
         [(black) (text name (list (make-object color% "white")) 36)]
         [(subtree) (text name '() 24)]
         [(code) (text name "modern" 24)])))
    (draw-pict picture dc 0 0)))

(define-interactive-syntax tree$ vertical-block$
  (super-new [alignment 'center])
  (inherit set-background)
  (set-background "white" 'transparent)
  (define tree (new pasteboard$ [parent this]
                    [extra-width 0]
                    [extra-height 10]))
  (define op-row (new horizontal-block$ [parent this]))
  (define new-node (new button$ [parent op-row]
                        [label (new label$ [text "ADD"])]
                        [callback (λ (b e)
                                    (define d (new node-insert$))
                                    (send d show #t)
                                    (define res (send d get-result))
                                    (when res
                                      (match-define (list name parent-name type)
                                        res)
                                      (define node (new node$ [type type]
                                                        [name name]))
                                      (cond
                                        [(non-empty-string? parent-name)
                                         (define parent
                                           (for/fold ([acc #f])
                                                     ([n (in-vertices nodes)])
                                             (or acc
                                                 (and (string=? (send n get-name)
                                                                parent-name)
                                                      n))))
                                         (cond
                                           [parent (add-child-node parent node)]
                                           [else
                                            (log-error "Couldn't find parent ~a" parent-name)
                                            (add-root-node node)])]
                                        [else (add-root-node node)])))]))
  ;(send tree add-child new-node 0 0)
  (define-state nodes (directed-graph '() '())
    #:elaborator #t
    #:getter #t
    #:serialize (λ (nodes)
                  (for/list ([n (in-vertices nodes)])
                    (define-values (x y) (send tree get-child-position n))
                    (list n x y
                          (for/list ([other (in-neighbors nodes n)])
                            (cons other (edge-weight nodes n other))))))
    #:deserialize (λ (nodes)
                    (define new (directed-graph '() '()))
                    (for ([n (in-list nodes)])
                      (send tree add-child (first n) (second n) (third n))
                      (add-vertex! new (first n)))
                    (for ([n (in-list nodes)])
                      (for ([other (in-list (fourth n))])
                        (add-directed-edge! new (first n) (car other) (cdr other))))
                    new))
  (define-state root #f
    #:elaborator #t)
  (define-elaborator
    (let ()
      (struct str ()
        #:property prop:procedure (λ (this stx)
                                    ((elaborator-parser
                                      this
                                      (define graph
                                        (for/hash ([n (in-list (send this get-nodes))])
                                          (values (first n) (rest n))))
                                      (define root
                                        (for/fold ([root #f]
                                                   [root-y +inf.0]
                                                   #:result root)
                                                  ([(k v) (in-dict graph)])
                                          (match-define (list _ y _) v)
                                          (if (y . < . root-y)
                                              (values k y)
                                              (values root root-y))))
                                      (let loop ([root root])
                                        (define name (send root get-name))
                                        (define type (send root get-type))
                                        (case type
                                          [(red black)
                                           (match-define (list _ _ children)
                                             (dict-ref graph root))
                                           (define-values (left right)
                                             (for/fold ([left #f]
                                                        [left-pos +inf.0]
                                                        [right #f]
                                                        [right-pos 0]
                                                        #:result (values left right))
                                                       ([child (in-list children)])
                                               (match-define (list x _ _)
                                                 (dict-ref graph (car child)))
                                               (apply values
                                                      (append (if (x . < . left-pos)
                                                                  (list (car child) x)
                                                                  (list left left-pos))
                                                              (if (x . > . right-pos)
                                                                  (list (car child) x)
                                                                  (list right right-pos))))))
                                           #`(mk-tree #:color '#,type
                                                      #:value '#,name
                                                      #:left #,(loop left)
                                                      #:right #,(loop right))]
                                          [(subtree) #`'#,name])))
                                     stx))
        #:property prop:match-expander (elaborator-parser
                                        this
                                        (define graph
                                          (for/hash ([n (in-list (send this get-nodes))])
                                            (values (first n) (rest n))))
                                        (define root
                                          (for/fold ([root #f]
                                                     [root-y +inf.0]
                                                     #:result root)
                                                    ([(k v) (in-dict graph)])
                                            (match-define (list _ y _) v)
                                            (if (y . < . root-y)
                                                (values k y)
                                                (values root root-y))))
                                        (let loop ([root root])
                                          (define name (format-id this-syntax "~a" (send root get-name)))
                                          (define type (send root get-type))
                                          (case type
                                            [(red black)
                                             (match-define (list _ _ children)
                                               (dict-ref graph root))
                                             (define-values (left right)
                                               (for/fold ([left #f]
                                                          [left-pos +inf.0]
                                                          [right #f]
                                                          [right-pos 0]
                                                          #:result (values left right))
                                                         ([child (in-list children)])
                                                 (match-define (list x _ _)
                                                   (dict-ref graph (car child)))
                                                 (apply values
                                                        (append (if (x . < . left-pos)
                                                                    (list (car child) x)
                                                                    (list left left-pos))
                                                                (if (x . > . right-pos)
                                                                    (list (car child) x)
                                                                    (list right right-pos))))))
                                             #`(tree '#,type _ #,(loop left) #,(loop right))]
                                            [(subtree)
                                             #'_]))))
      (str)))
  (define/public (add-root-node node [x 0] [y 0])
    (send tree add-child node x y)
    (set! root node)
    (add-vertex! nodes node))
  (define/public (add-child-node parent node [x 0] [y 0]
                                 [type 'default-value])
    (add-root-node node x y)
    (add-directed-edge! nodes parent node type))
  (define/augment (draw dc)
    (for ([edge (in-edges nodes)])
      (define start (first edge))
      (define end (second edge))
      (define-values (sx sy) (send tree get-child-position start))
      (match-define-values (sw sh)
        (send start get-extent))
      (define-values (ex ey) (send tree get-child-position end))
      (match-define-values (ew eh)
        (send end get-extent))
      (draw-arrow dc (+ sx (/ sw 2)) (+ sy sh)
                  (+ ex (/ ew 2)) ey
                  0 0
                  #:arrow-head-size 16
                  #:arrow-root-radius 0))))

(define-interactive-syntax ->$ widget$
  (inherit get-margin)
  (super-new)
  (define y-diff 100)
  (define x-diff 10)
  (define -> (arrow 50 0))
  (define/augment (get-extent)
    (values (+ (pict-width ->) (* 2 x-diff))
            (+ (pict-height ->) (* 2 y-diff))))
  (define/augment (draw dc)
    (draw-pict -> dc x-diff y-diff)))

(define-interactive-syntax match-case$ vertical-block$
  (super-new [alignment 'center])
  (define val-field (send (new labeled-option$ [parent this]
                               [label "Match: "]
                               [option (λ (p) (new field$ [parent p]
                                                   [callback (λ (f e)
                                                               (set! val (send f get-text)))]))])
                          get-option))
  (define match-row (new horizontal-block$ [parent this]))
  (define-state val ""
    #:setter (λ (v)
               (set! val v)
               (send val-field set-text! v))
    #:getter #t
    #:elaborator #t)
  (define-state pattern #f
    #:setter (λ (item)
               (send match-row update-child 0 (λ (old) item))
               (set! pattern item))
    #:getter #t
    #:deserialize (λ (des)
                    (when des
                      (send match-row update-child 0 (λ (old) des)))
                    des)
    #:elaborator #t)
  (define-state template #f
    #:setter (λ (item)
               (send match-row update-child 2 (λ (old) item))
               (set! template item))
    #:getter #t
    #:deserialize (λ (des)
                    (when des
                      (send match-row update-child 2 (λ (old) des)))
                    des)
    #:elaborator #t)
  (send match-row add-child (new widget$))
  (send match-row add-child (new ->$))
  (send match-row add-child (new widget$))
  (define-elaborator this
    (define pattern (send this get-pattern))
    (define template (send this get-template))
    (define val (format-id this-syntax "~a" (send this get-val)))
    #`(match #,val
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
                  #:color r-color)])))

(begin-for-syntax
  (define (deserialize-tree nodes)
    (define new (directed-graph '() '()))
    (for ([n (in-list nodes)])
      (add-vertex! new (first n)))
    (for ([n (in-list nodes)])
      (for ([other (in-list (fourth n))])
        (add-directed-edge! new (first n) (car other) (cdr other))))
    new))

(define-interactive-syntax node-insert$ dialog$
  (inherit show
           set-result!)
  (super-new)
  (define name (send (new labeled-option$ [parent this]
                          [label "Name: "]
                          [option (λ (p) (new field$ [parent p]))])
                     get-option))
  (define parent (send (new labeled-option$ [parent this]
                            [label "Parent: "]
                            [option (λ (p) (new field$ [parent p]))])
                       get-option))
  ;; XXX This should be a radio, also removing text->type
  (define type (send (new labeled-option$ [parent this]
                          [label "Type: "]
                          [option (λ (p) (new field$ [parent p]))])
                     get-option))
  (define (text->type text)
    (case text
      [("red") 'red]
      [("black") 'black]
      [("code") 'code]
      [else 'subtree]))
  (define confirm-row (new horizontal-block$ [parent this]))
  (new button$ [parent confirm-row]
       [label (new label$ [text "Cancel"])]
       [callback (λ (button event)
                   (show #f))])
  (new button$ [parent confirm-row]
       [label (new label$ [text "OK"])]
       [callback (λ (b e)
                   (set-result! (list (send name get-text)
                                      (send parent get-text)
                                      (text->type (send type get-text))))
                   (show #f))]))

(begin-for-interactive-syntax
  (module+ test
    ;; Right rotate example
    (define (mk-sample)
      (define tree
        (let ()
          (define tree (new tree$))
          (define root (new node$ [name "x"]))
          (define y (new node$ [name "y"]))
          (send tree add-root-node root 50 0)
          (send tree add-child-node root (new node$ [name "A"]
                                              [type 'subtree])
                0 100
                'left)
          (send tree add-child-node root y 100 100 'right)
          (send tree add-child-node y (new node$ [name "B"]
                                           [type 'subtree])
                50 200
                'left)
          (send tree add-child-node y (new node$ [name "C"]
                                           [type 'subtree])
                150 200
                'right)
          tree))
      (define tree2
        (let ()
          (define tree (new tree$))
          (define root (new node$ [name "y"]))
          (define x (new node$ [name "x"]))
          (send tree add-root-node root 100 0)
          (send tree add-child-node root x 50 100 'left)
          (send tree add-child-node x (new node$ [name "A"]
                                           [type 'subtree])
                0 200 'left)
          (send tree add-child-node x (new node$ [name "B"]
                                           [type 'subtree])
                100 200 'right)
          (send tree add-child-node root (new node$ [name "C"]
                                              [type 'subtree])
                150 100 'right)
          tree))
      (define mcase (new match-case$))
      (send mcase set-pattern! tree)
      (send mcase set-template! tree2)
      mcase)

    ;; Fold example
    (define (mk-sample2)
      (define tree
        (let ()
          (define tree (new tree$))
          (define root (new node$ [name "x"]))
          (send tree add-root-node root 50 0)
          (send tree add-child-node root (new node$ [name "(app f A)"]
                                              [type 'code])
                0 100
                'left)
          (send tree add-child-node root (new node$ [name "(app f B)"]
                                              [type 'code])
                100 100)
          tree))
      (define tree2
        (let ()
          (define tree (new tree$))
          (define root (new node$ [name "(+ x A B)"]
                            [type 'code]))
          (send tree add-root-node root 100 0)
          tree))
      (define mcase (new match-case$))
      (send mcase set-val! "tree")
      (send mcase set-pattern! tree)
      (send mcase set-template! tree2)
      mcase)

    ;(displayln (editor->string (mk-sample2)))))
    (void ;test-window
     (mk-sample))
    (test-window
     (new tree$))))
    ;(deserialize (serialize (mk-sample)))))
