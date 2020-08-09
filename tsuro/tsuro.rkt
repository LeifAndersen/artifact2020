#lang editor/lang

(provide tsuro-game%
         tsuro-tile%)

(require (for-syntax racket/base
                     racket/class
                     racket/match
                     syntax/parse
                     racket/port
                     racket/string)
         (for-editor pict
                     pict/shadow
                     pict/code
                     racket/gui
                     racket/draw
                     racket/list
                     racket/set))

(begin-for-interactive-syntax
  (module+ test
    (require editor/test)))

(begin-for-interactive-syntax
  ;; A Point-Index is an Integer in [0, 7].
  ;; A Tsuro-Tile is a (Listof Point-Index) of length 8.
  ;; A Player-Start is a (List Integer Integer Integer)
  ;;   namely (List x y input-port)
  ;; A Tsuro-Board is a (Pair (Listof (Listof (Or Tsuro-Tile #f)))
  ;;                          (Listof Player-Start))


  ;; Track a player's path through the board, returning the resulting
  ;;    location or #f if they died.
  ;; Tsuro-Board -> (Or (Listof Integer Integer Integer) #f)
  (define (trace-player board player)
    (define start (list-ref (cdr board) player))
    (define board-width (length (list-ref (car board) 0)))
    (define board-height (length (car board)))
    (let loop ([x (first start)]
               [y (second start)]
               [port (third start)]
               [first-step #t])
      (cond [(and (equal? x (first start))
                  (equal? y (second start))
                  (equal? port (third start))
                  (not first-step))
             #f]
            [(or (< x 0) (>= x board-width)
                 (< y 0) (>= y board-height))
             #f]
            [else
             (define square (list-ref (list-ref (car board) y) x))
             (match square
               [`(text ,text) #f]   
               [#f
                (list x y port)]
               [else
                (define dest (list-ref square port))
                (case dest
                  [(0) (loop x (- y 1) 5 #f)]
                  [(1) (loop x (- y 1) 4 #f)]
                  [(2) (loop (+ x 1) y 7 #f)]
                  [(3) (loop (+ x 1) y 6 #f)]
                  [(4) (loop x (+ y 1) 1 #f)]
                  [(5) (loop x (+ y 1) 0 #f)]
                  [(6) (loop (- x 1) y 3 #f)]
                  [(7) (loop (- x 1) y 2 #f)])])])))

  ;; Draw's a single tile (no player tokens, usable as a stand alone
  ;;   piece or in a board
  ;; Additionally, if composable is set to #t, also return the blank picts
  ;;   that serve as nodes.
  ;; (Listof (Pairof Point-Index Point-Index))
  ;;    [#:composable? Boolean]
  ;;    [#:background color/c]
  ;;    -> (Or Pict
  ;;           (Pair Pict (Listof Pict)
  (define (draw-tile pairs
                     #:background [background "gray"]
                     #:composable? [composable? #f])
    (define points
      (build-list 8 (λ _ (blank))))
    (define (p-o acc x y n)
      (pin-over acc x y (list-ref points n)))
    (define square
      (let* ([acc (filled-rectangle
                   300 300 #:color background)]
             [acc (p-o acc 100 0 0)]
             [acc (p-o acc 200 0 1)]
             [acc (p-o acc 300 100 2)]
             [acc (p-o acc 300 200 3)]
             [acc (p-o acc 200 300 4)]
             [acc (p-o acc 100 300 5)]
             [acc (p-o acc 0 200 6)]
             [acc (p-o acc 0 100 7)])
        acc))
    (define square+lines
      (for/fold ([acc square])
                ([pair (in-list pairs)])
        (cc-superimpose
         acc
         (dc (λ (dc dx dy)
               (define old-pen (send dc get-pen))
               (define old-brush (send dc get-brush))
               (send dc set-pen
                     (new pen% [width 4]
                          [color "black"]))
               (send dc set-brush
                     (new brush% [style 'transparent]))
               (define-values (sx sy)
                 (cc-find acc (list-ref points (car pair))))
               (define-values (ex ey)
                 (cc-find acc (list-ref points (cdr pair))))
               (define path (new dc-path%))
               (send path move-to (+ sx dx) (+ sy dy))
               (define (adjust v)
                 (case v
                   [(0) 50]
                   [(300) 250]
                   [(100 200) v]))
               (send path curve-to
                     (+ (adjust sx) dx)
                     (+ (adjust sy) dy)
                     (+ (adjust ex) dx)
                     (+ (adjust ey) dy)
                     (+ ex dx)
                     (+ ey dy))
               (send dc draw-path path)
               (send dc set-pen old-pen)
               (send dc set-brush old-brush))
             (pict-width acc) (pict-height acc)))))
    (define node
      (filled-ellipse 10 10 #:color "white"))
    (define (node-find b p)
      (define-values (x y)
        (cc-find b p))
      (values (- x (/ (pict-width node) 2))
              (- y (/ (pict-height node) 2))))
    (define ((label-find pic i) b p)
      (define-values (raw-x raw-y)
        (cc-find b p))
      (define x (- raw-x (/ (pict-width pic) 2)))
      (define y (- raw-y (/ (pict-height pic) 2)))
      (values (cond [(set-member? (set 2 3) i) (+ x 20)]
                    [(set-member? (set 6 7) i) (- x 20)]
                    [else x])
              (cond [(set-member? (set 0 1) i) (- y 20)]
                    [(set-member? (set 4 5) i) (+ y 20)]
                    [else y])))
    (if composable?
        (cons square+lines points)
        (panorama
         (for/fold ([acc square+lines])
                   ([point (in-list points)]
                    [index (in-naturals)]
                    [letter (in-naturals 65)])
           (let ([acc (pin-over acc point node-find node)]
                 [label (text (string (integer->char letter)) '() 24)])
             (pin-over acc point (label-find label index) label))))))
  
  (module+ test
    (let ()
      (draw-tile '())
      (draw-tile (list (cons 0 3)))
      (draw-tile (list (cons 0 3)
                       (cons 1 2)
                       (cons 4 6)
                       (cons 5 7)))
      (draw-tile (list (cons 0 4)
                       (cons 1 5)
                       (cons 2 6)
                       (cons 3 7)))
      (draw-tile (list (cons 0 1)
                       (cons 2 3)
                       (cons 4 5)
                       (cons 6 7)))
      (draw-tile (list (cons 0 3)
                       (cons 1 2)
                       (cons 4 7)
                       (cons 5 6)))
      (draw-tile (list (cons 0 4)
                       (cons 1 3)
                       (cons 2 6)
                       (cons 5 7)))
      (void)))

  (define blank-tile (draw-tile '()))

  ;; Draws the board and (living) players on it
  ;; Board -> Pict
  (define (draw-board board)
    (define blank-tile (draw-tile '() #:composable? #t))
    (define tiles
      (for/list ([row (in-list (car board))])
        (for/list ([tile (in-list row)])
          (match tile
            [`(text ,tile-code)
             (define b (draw-tile '()
                                  #:composable? #t
                                  #:background "white"))
             (define code-background
               (parameterize ([get-current-code-font-size (λ () 60)])
                 (blur (codeblock-pict (string-append "#lang racket\n" tile-code)
                                       #:keep-lang-line? #f)
                       20)))
             (parameterize ([get-current-code-font-size (λ () 120)])
               (cons (refocus (cc-superimpose (car b) code-background (code (...)))
                              (car b))
                     (cdr b)))]
            [#f (draw-tile '() #:composable? #t)]
            [_
             (draw-tile (for/list ([t (in-list tile)]
                                   [index (in-naturals)])
                          (cons index t))
                        #:composable? #t)]))))
    (define plain-board
      (apply vc-append
             (for/list ([row (in-list tiles)])
               (apply hc-append
                      (for/list ([tile (in-list row)])
                        (car tile))))))
    (define token-diam 125)
    (define player-token
      (for/list ([player (in-list (cdr board))]
                 [index (in-naturals)])
        (cc-superimpose
         (filled-ellipse token-diam token-diam
                         #:color "white")
         (text (number->string index) '() 100))))
    (define (token-find b p)
      (define-values (x y) (cc-find b p))
      (values (- x (/ token-diam 2))
              (- y (/ token-diam 2))))
    (define board+players
      (for/fold ([acc plain-board])
                ([player (in-list player-token)]
                 [index (in-naturals)])
        (define dest (trace-player board index))
        (cond [dest
               (pin-over acc
                         (list-ref (cdr (list-ref (list-ref tiles (second dest)) (first dest))) (third dest))
                         token-find
                         player)]
              [else acc])))
    (scale board+players 1/6))
  (define board-tile-size (* 300 1/6))

  (module+ test
    (let ()
      (draw-board
       '((((1 0 3 2 5 4 7 6) (2 3 0 1 6 7 4 5) (1 0 3 2 6 7 4 5))
          ((7 6 5 4 3 2 1)   #f                #f)
          (#f                #f                #f))
         (1 0 0)
         (1 0 1)
         (0 0 0)))
      (void))))

(define-interactive-syntax tsuro-pic$ base$
  (super-new)
  (define-state tile blank-tile
    #:getter #t
    #:setter #t
    #:persistence #f)
  (define/augment (get-extent)
    (values (pict-width blank-tile)
            (pict-height blank-tile)))
  (define/augment (draw dc)
    (draw-pict tile dc 0 0)))

(define-interactive-syntax blank$ base$
  (super-new)
  (define-state space 0
    #:init #t
    #:getter #t
    #:setter #t)
  (define/augment (get-extent)
    (values space space)))

(define-interactive-syntax tsuro-tile$ horizontal-block$
  (super-new)
  (define picture
    (new tsuro-pic$))
  (send this add-child (new blank$ [space 30]))
  (send this add-child picture)
  (define-state pairs (hash)
    #:elaborator #t
    #:getter #t
    #:setter #t
    #:deserialize (λ (des)
                    (for ([(k v) des])
                      (define field (hash-ref field-gui k))
                      (send field set-text! v))
                    (draw-pairs des)
                    des))
  (define/public (set-pair! letter other)
    (set! pairs (hash-set pairs letter other))
    (draw-pairs)
    this)
  (define/public (connect! letter other)
    (send (hash-ref field-gui letter) set-text! other)
    (send (hash-ref field-gui other) set-text! letter)
    (set-pair! letter other)
    (set-pair! other letter)
    this)
  (define (draw-pairs [pairs pairs])
    (send picture set-tile!
          (draw-tile
           (for/list ([(k v) (in-hash pairs)]
                      #:when (and (string=? (hash-ref pairs v "") k)
                                  (string<? k v)))
             (cons (- (char->integer (string-ref k 0)) 65)
                   (- (char->integer (string-ref v 0)) 65))))))
  (define fields (new vertical-block$ [parent this]))
  (send this add-child (new blank$ [space 30]))
  (define (tsuro-field letter)
    (new labeled-option$ [parent fields]
         [font (make-object font% 24 'default)]
         [label (format "~a: " letter)]
         [option (λ (p) (new field$ [parent p]
                             [font (make-object font% 24 'default)]
                             [background "mistyrose"]
                             [callback (λ (f e)
                                         (set-pair! letter (send f get-text)))]))]))
  (define field-gui
    (hash "A" (send (tsuro-field "A") get-option)
          "B" (send (tsuro-field "B") get-option)
          "C" (send (tsuro-field "C") get-option)
          "D" (send (tsuro-field "D") get-option)
          "E" (send (tsuro-field "E") get-option)
          "F" (send (tsuro-field "F") get-option)
          "G" (send (tsuro-field "G") get-option)
          "H" (send (tsuro-field "H") get-option)))
  (define/public (get-fields-gui)
    field-gui)
  (define-elaborator this
    #`'#,(for/hash ([(k v) (in-hash (send this get-pairs))])
           (values (string->symbol k) (string->symbol v)))))

(begin-for-interactive-syntax
  (module+ test
    (void ;test-window
     (new tsuro-tile$))))

(define-interactive-syntax tile-dialog$ dialog$
  (inherit show
           set-result!)
  (super-new)
  (init tile)
  (define (redraw tile-contents)
    (send this clear)
    (define tile-editor
      (cond [(list? tile-contents)
             (new field$ [parent this]
                  [text (second tile-contents)])]
          [else
           (define tile-editor (new tsuro-tile$ [parent this]))
           (for ([(k v) (in-dict tile-contents)])
             (send tile-editor set-pair! k v))
           tile-editor]))
    (define b-row (new horizontal-block$ [parent this]))
    (new button$ [parent b-row]
         [label (new label$ [text "OK"])]
         [callback (λ (b e)
                     (if (list? tile-contents)
                         (set-result! `(text ,(send tile-editor get-text)))
                         (set-result! (send tile-editor get-pairs)))
                     (show #f))])
    (new button$ [parent b-row]
         [label (new label$ [text (if (list? tile-contents)
                                      "Switch to Tile"
                                      "Switch to Text")])]
         [callback (λ (b e)
                     (if (list? tile-contents)
                         (redraw (hash))
                         (redraw '(text ""))))]))
  (redraw tile))

(define-interactive-syntax tsuro-board$ base$
  (super-new)
  (define-state width 4)
  (define-state height 4)
  (define-state board (make-list 4 (make-list 4 #f))
    #:elaborator #t
    #:getter #t
    #:setter (λ (x)
               (set! board x)
               (update-board!))
    #:deserialize (λ (des)
                    (set! board des)
                    (update-board!)
                    des))
  (define/public (set-tile! tile x y)
    (set-board!
     (for/list ([row (in-list board)]
                [y* (in-naturals)])
       (for/list ([cell (in-list row)]
                  [x* (in-naturals)])
         (if (and (= x x*) (= y y*))
             tile
             cell))))
    this)
  (define-state players (list (list 2 0 0)
                              (list 0 3 7)
                              (list 3 3 4))
    #:elaborator #t
    #:getter #t
    #:setter (λ (x)
               (set! players x)
               (update-board!))
    #:deserialize (λ (des)
                    (set! players des)
                    (update-board!)
                    des))
  (define board-pict-scale 1.8)
  (define board-pic (scale (draw-board (cons board players)) board-pict-scale))
  (define (update-board!)
    (set! board-pic (scale (draw-board (cons board players)) board-pict-scale)))
  (define/augment (get-extent)
    (values (pict-width board-pic)
            (pict-height board-pic)))
  (define/augment (draw dc)
    (draw-pict board-pic dc 0 0))
  (define/augment (on-event event)
    (cond [(is-a? event mouse-event%)
           (when (eq? (send event get-event-type) 'left-down)
             (define x-tile (exact-floor (/ (/ (send event get-x) board-tile-size) board-pict-scale)))
             (define y-tile (exact-floor (/ (/ (send event get-y) board-tile-size) board-pict-scale)))
             (define t (list-ref (list-ref board y-tile) x-tile))
             (define n
               (new tile-dialog$ [tile
                                  (if (and t (equal? (first t) 'text))
                                      t
                                      (for/hash ([target (in-list (or t '()))]
                                                 [index (in-naturals)])
                                        (values (string (integer->char (+ index 65)))
                                                (string (integer->char (+ target 65))))))]))
             (send n show #t)
             (define res (send n get-result))
             (cond
               [(list? res)
                (set-tile! res x-tile y-tile)]
               [(dict? res)
                (set-tile! (for/list ([i (in-range 65 (+ 65 8))])
                             (define key (string (integer->char i)))
                             (- (char->integer (string-ref (dict-ref res key "A") 0)) 65))
                           x-tile y-tile)]
               [else (void)]))]))
  (define-elaborator this
    #:with ((the-tiles ...) ...) (for/list ([row (in-list (send this get-board))])
                                   (for/list ([tile (in-list row)])
                                     (match tile
                                       [`(text ,text)
                                        (datum->syntax this-syntax (with-input-from-string text read))]
                                       [_
                                        #`'#,tile])))
    #`(new tsuro-game%
           [tiles (list (list the-tiles ...) ...)]
           [players '#,(send this get-players)])))

(begin-for-interactive-syntax
  (module+ test
    (test-window
     (new tsuro-board$))))

(define tsuro-tile%
  (class object%
    (super-new)
    (init connections)
    (define iconnections connections)
    (define/public (rotate degrees)
      `(rotated ,iconnections ,degrees)))) ;; stub for example

(define tsuro-game%
  (class* object% (equal<%>)
    (super-new)
    (init tiles players)
    (define it tiles)
    (define/public (get-tiles)
      it)
    (define/public (addTile tile player)
      this) ;; Stub for example
    (define/public (equal-to? other rec)
      #t) ;; Stub for example
    (define/public (equal-hash-code-of hash-code)
      0) ;; Stub for example
    (define/public (equal-secondary-hash-code-of hash-code)
      0))) ;; Stub for example
    
