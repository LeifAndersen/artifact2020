#lang editor editor/lang

(require (for-editor racket/set
                     racket/serialize
                     syntax/parse/define
                     racket/class
                     racket/struct
                     racket/match
                     racket/list
                     racket/draw
                     pict
                     (prefix-in pict: pict)
                     editor/private/editor
                     "image.rkt"
                     (for-syntax racket/base
                                 racket/syntax)))

(begin-for-interactive-syntax
  (module+ test
    (require rackunit
             editor/test)))
;; Component/lead pair to be added to a node's component
;;   table.
;; Both component and lead are compared by eq?. (To
;;   remove cycles.)
;; node-component? = component? symbol?
(begin-for-interactive-syntax
  (serializable-struct node-component (component
                                       lead)
                       #:methods gen:equal+hash
                       [(define (equal-proc this other rec)
                          (and (eq? (node-component-component this)
                                    (node-component-component other))
                               (eq? (node-component-lead this)
                                    (node-component-lead other))))
                        (define (hash-proc this rec)
                          (+ (eq-hash-code (node-component-component this))
                             (eq-hash-code (node-component-lead this))))
                        (define (hash2-proc this rec)
                          (* (eq-hash-code (node-component-component this))
                             (eq-hash-code (node-component-lead this))))]
                       #:methods gen:custom-write
                       [(define write-proc
                          (make-constructor-style-printer
                           (λ (this) 'node-component)
                           (λ (this) (list (node-component-component this)
                                           (node-component-lead this)))))]))

(define-interactive-syntax node$ base$
  (super-new)
  (define-state components (set)
    #:init #t
    #:getter #t)
  (define-state node-x 0
    #:init #t
    #:getter #t)
  (define-state node-y 0
    #:init #t
    #:getter #t)
  (define/public (add-component! comp lead)
    (set! components (set-add components (node-component comp lead))))
  (define/public (remove-component! comp lead)
    (set! components (set-remove components (node-component comp lead)))))

;; Components ========================================================================================

;; (define-lead <name>)
;; Defines a lead for use in a circuit component,
;; leads connect to nodes.
(begin-for-interactive-syntax
  (define-local-member-name lead-table)
  (define-syntax-parser define-lead
    [(_ name:id)
     #:with this (format-id this-syntax "this")
     #:with lead-name (format-id this-syntax "~a-lead" #'name)
     #'(begin
         (set-field! lead-table this (set-add (get-field lead-table this) 'name))
         (define-state lead-name (box #f)
           #:getter (λ () (unbox lead-name))
           #:setter (λ (x)
                      (define prev (unbox lead-name))
                      (when prev
                        (send prev remove-component! this 'name))
                      (when x
                        (send x add-component! this 'name))
                      (set! lead-name (box x)))))])
  (define (in-leads component)
    (in-set (send component get-lead-table))))


(define-interactive-syntax component$ widget$
  (super-new)
  (define-state id (random))
  (define-state image #f
    #:init #t
    #:persistence #f)
  (define-state component-x #f
    #:init #t
    #:getter #t)
  (define-state component-y #f
    #:init #t
    #:getter #t)
  (define-state rotation 0
    #:init #t
    #:getter #t)
  (define-state flip? #f
    #:getter #t)
  (define-state scale 1
    #:init #t
    #:getter #t)
  (field [lead-table (set)])
  (define/public (get-lead-table)
    lead-table)
  (define/public (set-lead name x)
    (define the-name (string->symbol (format "set-~a-lead!" name)))
    (dynamic-send this the-name x))
  (define/augment (get-extent)
    (if (pict? image)
        (values (pict-width image)
                (pict-height image))
        (values 0 0)))
  (define/augment (draw dc)
    (when (pict? image)
      (send dc draw-bitmap (pict->bitmap (let* ([i image]
                                                [i (if rotate
                                                       (rotate i rotation)
                                                       i)]
                                                [i (if scale
                                                       (pict:scale i scale)
                                                       i)])
                                           i))
            0 0))
    (void)))

(define-interactive-syntax dc-voltage-source$ component$
  (super-new)
  (define-state voltage 0
    #:getter #t)
  (define-lead positive)
  (define-lead negative))

(define-interactive-syntax voltage-source$ component$
  (init [(iv voltage) 0]
        [image #f])
  (super-new [image image])
  (define-state voltage iv
    #:getter #t)
  (define-lead source))


(define-interactive-syntax ground$ voltage-source$
  (super-new [voltage 0]))

(define-interactive-syntax resistor$ component$
  (super-new [image #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"image.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q image$)
  c
  (c (mpi (c submod c (? . 0) q deserializer) ? . 1) q image$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q image$:elaborate)))((4)
 3
 (((submod (relative up #"image.rkt") deserializer) . image$:deserialize)
  ((lib "racket/private/set-types.rkt")
   .
   deserialize-info:mutable-custom-set-v0)
  ((submod (relative up #"image.rkt") deserializer) . image-data$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      focus$$
      (h - (equal) (focus? . #t)))
     signaler$$
     (h - (equal) (receivers 1 #f (h ! (equal)))))
    button$
    (? . 0))
   image$
   (h
    -
    (equal)
    (data
     2
     0
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      image-data$
      (h
       -
       (equal)
       (display-height . #f)
       (background? . #f)
       (distort? . #f)
       (display-width . #f)
       (resize? . #f)
       (picture
        u
        .
        #"\211PNG\r\n\32\n\0\0\0\rIHDR\0\0\0=\0\0\0\20\b\6\0\0\0\245Pw\1\0\0\3JIDATH\211\345\225?Hja\30\306\237{),'\301\301r\b!\347\4\247\266\"\\\4\v;\24\202\273\270&\330P\2038\325P\223\264\24\211\243\bRX\240[\324PH\210h\350\"6\350\242\2718\b\376\327\347N\35\356\271\235kyNw\272\17\348\337\313\217\227\347\371^x\277\37$\211\377L?\3256\270\270\270@8\34\376\22\373\364\364\4\237\317\367%\266^\257cww\27\303\341P\215=yQ\205\272\335.\1\20\0{\275\336\247\274\305b!\0V*\225O\331@ @\0L&\223j,\312JU\350x<.\206N$\22\23\331R\251$\262>\237o\"\333n\267\t\2006\233\215&\223I\215EY\251\n\255\323\351(\b\2\35\16\a\r\6\303D\326\343\361\20\0\317\316\316\b\200\255V\353\257l4\32%\0>??\23\0\v\205\202\32\233\37\2448t&\223!\0\346\363yf\263Y\2`.\227\223e\233\315&\0010\22\211\210\377\341pX\226\35\217\307\324h4t\273\335$I\255VK\227\313\245\324\246\254\24\207\266\333\3554\32\215\342Y\257\327\323\351t\312\262\241PH2]\257\327K\0\34\215F\37\330t:M\0,\26\213$\311X,F\0l4\32J\255~\320\217N\247\303z\275>\325\362{{{\303\352\352*nnn\260\271\271\t\0\270\276\276\206 \b\250\325jXXX\20\331\341p\210\331\331Y\370\375~\234\234\234\0\0^__a6\233q\177\177\217\265\2655I\357\215\215\rT\253U\224\313e\0@\267\333\305\374\374<\216\216\216ppp a_^^\240\325j1333\225\177\370\375~q\301L\373\365\373}\361\366\3367y0\30\224\334j*\225\"\0V\253UI\335j\265\322j\265Jj\325j\225\0\230J\245$\365`0H\0\354v\273b\255\337\357+\366\255h\322\303\341\20\355v\e+++\222\372\361\3611\16\17\17\321\351t077\a\0000\233\315XZZ\302\335\335\235\204}xx\300\372\372:\312\3452\226\227\227\1\0\373\373\3738==\305`0\220L\257^\257cqq\21WWW\330\336\336\6\0\334\336\336bkk\v\351t\32\6\203a*\377\252\266\367\237j4\32\4\300X,F\222,\26\213\4\300t:\375\201\35\215F\4@\257\327K\222l\265Z\4\300P($\333\333\351tR\257\327\213g\243\321H\273\335\256\310\347\267\206&I\227\313E\255VK\222t\273\335\324h4\34\217\307\262l8\34&\0006\233MF\"\21\361_N\271\\\216\0\230\315f\231\317\347\t\200\231LF\221\307o\17](\24$ol4\32\375+\373>\335\367\267\333\343\361L\354m0\30\350p8(\b\2u:\235b\217\337\36\232$M&\23m6\e\1\260\335nOd}>\237\270`J\245\322D6\221H\210l<\36W\354\357\237\204N&\223\4\300@ \360)[\251T\b\200\26\213\345S\266\327\353\211\241\177\337\344\323\352\237\204\36\f\6\334\331\331a\255V\373\22\277\267\267\307\307\307\307/\261\227\227\227<??Wc\217\277\0\333|k\377\35\345W\247\0\0\0\0IEND\256B`\202"))))))))])
  (define-lead a)
  (define-lead b))

(define-interactive-syntax capacitor$ component$
  (super-new [image #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"image.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q image$)
  c
  (c (mpi (c submod c (? . 0) q deserializer) ? . 1) q image$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q image$:elaborate)))((4)
 3
 (((submod (relative up #"image.rkt") deserializer) . image$:deserialize)
  ((lib "racket/private/set-types.rkt")
   .
   deserialize-info:mutable-custom-set-v0)
  ((submod (relative up #"image.rkt") deserializer) . image-data$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      focus$$
      (h - (equal) (focus? . #t)))
     signaler$$
     (h - (equal) (receivers 1 #f (h ! (equal)))))
    button$
    (? . 0))
   image$
   (h
    -
    (equal)
    (data
     2
     0
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      image-data$
      (h
       -
       (equal)
       (display-height . #f)
       (background? . #f)
       (distort? . #f)
       (display-width . #f)
       (resize? . #f)
       (picture
        u
        .
        #"\211PNG\r\n\32\n\0\0\0\rIHDR\0\0\0=\0\0\0\314\b\6\0\0\0\300\254\253U\0\0\1\230IDATx\234\355\3351\252\203@\24@\321\231\257\205\biL\210\340*t\31YV\266\232\rXEIH\234_\v\277~~\270\367\200\3154\357]\230\312BS\t6\216c\3119\357\236\333\355\26\272\303O\0022\232\302h\n\243)\214\2460\232\302h\n\243)\214\2460\232\302h\n\243)\214\2460\232\302h\n\243)\214\2460\232\302h\n\243)\214\2460\232\302h\ndt\276^\257eY\226\260\201\353\272\246m\333vgUU\245\246i\302v\250?\237Oz>\237a\3\377\362\375~Cw@^o\243)\362\353\365*G/\21-\227Rp\321\310\353m4\205\321\24FS\30Ma4\205\321\24\365\375~O\221\357\310\376\203\334u]\231\347\371\350=B!\25772\272\356\373>\235\317\347\260\201\217\307#\275\337\357\335Y\333\266i\30\206\260\35R\350\aF\212\33799\214\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4E\35=\360r\271\244i\232vg\247\323)t\a\377\242Da4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS\30Ma4\205\321\24FS \243\177\0012m\370Z_\243\245\267\0\0\0\0IEND\256B`\202"))))))))])
  (define-lead a)
  (define-lead b))

(define-interactive-syntax inductor$ component$
  (super-new)
  (define-lead a)
  (define-lead b))

(define-interactive-syntax transistor$ component$
  (super-new)
  (define-state type #f ;; 'PNP, 'NPN
    #:getter #t))

(define-interactive-syntax bjt$ transistor$
  (super-new)
  (define-lead collector)
  (define-lead emitter)
  (define-lead base))

(define-interactive-syntax fet$ transistor$
  (super-new)
  (define-lead source)
  (define-lead drain)
  (define-lead gate))

(define-interactive-syntax diode$ component$
  (super-new [image #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"image.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q image$)
  c
  (c (mpi (c submod c (? . 0) q deserializer) ? . 1) q image$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q image$:elaborate)))((4)
 3
 (((submod (relative up #"image.rkt") deserializer) . image$:deserialize)
  ((lib "racket/private/set-types.rkt")
   .
   deserialize-info:mutable-custom-set-v0)
  ((submod (relative up #"image.rkt") deserializer) . image-data$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      focus$$
      (h - (equal) (focus? . #t)))
     signaler$$
     (h - (equal) (receivers 1 #f (h ! (equal)))))
    button$
    (? . 0))
   image$
   (h
    -
    (equal)
    (data
     2
     0
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      image-data$
      (h
       -
       (equal)
       (display-height . #f)
       (background? . #f)
       (distort? . #f)
       (display-width . #f)
       (resize? . #f)
       (picture
        u
        .
        #"\211PNG\r\n\32\n\0\0\0\rIHDR\0\0\0\\\0\0\0\32\b\6\0\0\0:\356;)\0\0\2\252IDATh\201\355\231?O\352P\30\306\177\271q\242\372%\204\352\n$\200\361\e(\25\234\364c4\f$b\204\1\215.~\16\\E\376\354\f\16j\240\316%8\311\342*eq8\0167=\221Hn.\366$=\347\346\376\222&=o\322\223\247O\337<i\337\"4b8\34\212\\.'\356\357\357\225\354\367\372\372*\252\325\252\230N\247J\366S\1q\v\370J6\233\25\200\0D\243\321\20\363\371<\322~\256\353\n@T*\25E\n\243\363\v\215\310f\263\362\274\331l\222H$\350\367\3731*R\217V\206oll\0\3408\216\254\25\213Evvv\230L&q\311R\212V\206\207$\223If\263\31'''\0<<<\220J\245h4\32\314\347\363\230\325ECK\303\1,\313\342\352\352\n\337\367I\247\323\0\234\237\237cY\26\275^/fu?G[\303Cl\333\306\363<nooe\315q\34\n\205\202\2211\243\275\341!\345ry!f\36\37\37\215\214\31c\f\207\305\230\311d2\200y1c\224\341!\266m3\32\215h\267\333\262\3468\16\371|^\373\2301\322\360\220R\251\304l6\243V\253\1\360\364\364D*\225\242^\257k\e3F\e\16\277c\346\362\362\22\337\367\345\207\323\305\305\5\226e\361\362\362\22\263\272\357\254M\247S\256\257\257\343\326\1\300`0\0\340\375\375}\345km\333f8\34\322\351t(\225J\0t:\35\0\372\375>B\buB\243P\255V\345\374B\227#\235NG\232W\274\275\275\211\335\335\335\330\357c\331\261\346\272.\37\37\37?~`*\31\f\6x\236\2670SY\225\257\35\36\262\275\275\315\336\336^TyjP3\3SC\245R\21\200p]w\345k}\337\27\231Lf\241\233\16\16\16\376O\vU\23\4\1\247\247\247lmm\341y\36\0ggg\4A\300\346\346f\314\352\276\263\26\267\200(\334\335\335Q.\227\345:\227\313qssC2\231\214Q\325\2371\322\360\361x\314\361\361\261\354h\200n\267K\261X\214Q\325\337aT\244\4A@\255V[\210\217z\275N\20\4F\230\r\6ux\273\335\346\360\360P\256\363\371<\255VK\353\370X\206\366\206\217\307c\216\216\216x~~\2265S\342c\31\332F\312\327\370\b\3156->\226\241e\207O&\23\326\327\327\345\272P(\320j\265\264|\315[\25\255\f\17g(\335nW\326z\275\36\373\373\373qIR\216V\2212\32\215\344y\370'\347_2\e\340\23\257\5\201\263b\377\275+\0\0\0\0IEND\256B`\202"))))))))])
  (define-lead annode)
  (define-lead cathode))

(define-interactive-syntax zener-diode$ diode$
  (super-new))

(define-interactive-syntax transformer$ component$
  (super-new [image #editor((4)
 0
 ()
 2
 (".."
  (mpi
   (c submod c (p* up #"image.rkt") c deserializer c (? . 0) q editor)
   .
   #f))
 ()
 (c
  (c (? . 1) q image$)
  c
  (c (mpi (c submod c (? . 0) q deserializer) ? . 1) q image$:deserialize)
  c
  (c (mpi (c submod c (? . 0)) ? . 1) q image$:elaborate)))((4)
 3
 (((submod (relative up #"image.rkt") deserializer) . image$:deserialize)
  ((lib "racket/private/set-types.rkt")
   .
   deserialize-info:mutable-custom-set-v0)
  ((submod (relative up #"image.rkt") deserializer) . image-data$:deserialize))
 1
 ((h - (equal)))
 ()
 (0
  0
  (v!
   (v!
    (v!
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      focus$$
      (h - (equal) (focus? . #t)))
     signaler$$
     (h - (equal) (receivers 1 #f (h ! (equal)))))
    button$
    (? . 0))
   image$
   (h
    -
    (equal)
    (data
     2
     0
     (v!
      (v! (v! (v! #f base$ (? . 0)) get-path$$ (? . 0)) widget$ (? . 0))
      image-data$
      (h
       -
       (equal)
       (display-height . #f)
       (background? . #f)
       (distort? . #f)
       (display-width . #f)
       (resize? . #f)
       (picture
        u
        .
        #"\211PNG\r\n\32\n\0\0\0\rIHDR\0\0\0d\0\0\0d\b\6\0\0\0p\342\225T\0\0\b\353IDATx\234\355\235\315O\23]\e\207\177\274 `;\203\204\212F\23\232\270h\2115U@4\256$\222\30]\30D\23\27\332\344I\214\30e\243i\210bt\353\302\177\300\200\eI\2206\32\242QW~BpAT\250U\t\0204\224\257\210\21Z\2N\321\222\322\376\236\305\373\312+\17EKi\231\303\343\271\222n:\235s\356\233\213\3631g\316\264i$\t\2110\374G\357\0$\363\221B\4C\n\21\f)D0\244\20\301\220B\4C\n\21\f)D0\244\20\301\220B\4C\n\21\214\214DN\n\4\2\311\216c\16\223\311\224\262\262\27C\244|\322\226\272\270\250i\32\256]\273\266\244J\342\345\341\303\207\350\352\352JI\331\277\302n\267\243\242\242\"%e_\272t\t\252\252\306\375\371%\vI%v\273]7!z\324\e\v9\206\b\206\24\"\30R\210`H!\202!\205\b\206\24\"\30R\210`H!\202!\205\b\206\24\"\30R\210`H!\202!\205\b\206\24\"\30R\210`H!\202\261\352\205\224\227\227\343\363\347\317\0\200\317\237?\243\274\274\\\347\210\226\307\252\27\322\332\332\nM\323\0\374\367\366rkk\253\316\21-\217U/\344\337FB\273NRA(\24B \20\300\343\307\217a6\233\261a\303\206\224\356@\t\4\2\30\e\e\303\360\3600\2\201\0B\241\20\262\263\263SV_\334P\20\374~?\25E\241\301` \0\2`EE\5;::~y\36\0\366\365\365\221$\373\372\372\370\273\224:::XQQ1W\207\301`\240\242(\364\373\375I\313e9\b\323e\231L&h\232\206\351\351i\220\204\317\347\203\305b\301\256]\273p\361\342Ep\231\233cH\342\342\305\213\330\265k\27,\26\v|>\37Hbzz\32\232\246\351\262\37,&\372\376?\374\236\301\301A\2\240\303\341\210y\34q\266\20\207\303A\0\34\34\34LY\254\311@x!$9<<L\0\f\4\2\v\216\305#$\20\b\20\0\207\207\207S\36\353r\21\246\313\372\25\5\5\5PU\25---\t\235\337\322\322\2UUQPP\220\344\310\222\217\256BH\342\306\215\e\310\317\317GZZ\332\334\313h4\342\310\221#\360x< \211\257_\277B\3234\224\224\224$TOII\t4M\303\327\257_A\22\36\217\aG\216\34\201\242(\363\352\315\317\317G}}\375\262\307\253e\241g\363\254\256\256&\0\272\335n\16\f\fp||\234\335\335\335|\364\350\21\235N'\001033\223UUU\4\300h4\272\240\f\304\321eE\243Q\2`UU\025333\t\200N\247\223\217\36=bww7\307\307\307900@\267\333M\0<s\346L\312s_\f]\205\0\340\343\307\217c\36\213F\243|\363\346\r\17\36<H\0lkk[\264\214x\6\365\266\2666\2\340\301\203\a\371\346\315\233\230rI\362\311\223'\277\235:\247\22]/\f\353\352\352p\340\300\1TVV\342\350\321\243\310\317\317\307\307\217\37\321\325\325\5\267\333\215\351\351i\234;w\16\177\375\365\27\312\312\312\20\16\207\221\221\261\364\220gggQVV\6\227\313\205W\257^\241\244\244\4F\243\21'N\234\200\335n\207\305b\301\370\3708\356\335\273\207\373\367\357\343\372\365\353)\3106Nt\373W\370\37===\274|\3712\213\213\213\251(\n\367\357\337\317\332\332Z\272\\.j\232F\222\234\231\231!\0vvv.8\37q\264\20\217\307C\0\234\231\231!Ij\232F\227\313\305\332\332Z\356\337\277\237\212\242\260\270\270\230\227/_fOOO\n\263\375=\272/\235l\336\274\31\245\245\245\b\207\303\260Z\255\330\261c\a\n\v\v\261e\313\26\30\215F\0@zz:\0 \30\f&T\307\217\305\307\37\345\30\215F\330l6dggc\335\272u\310\313\313\203\331l\306\316\235;\261y\363\346$d\2258\272\316\262\236>}\212\334\334\\\34?~\34\301`\20v\273\35^\257\27N\247\23%%%0\30\f\270u\353\26^\277~\r\0\330\275{wB\365\3748\257\243\243\3MMM0\30\f(..\206\323\351\204\327\353\205\335nG0\30\304\211\23'\220\233\233\213'O\236$-\307%\243g\363\314\312\312\342\355\333\267c\36\v\6\203t\273\335\314\311\311!\000644\304\374\34\342\34\324o\336\274I\0\314\311\311\241\333\355f0\30\214\371\271;w\356p\315\2325KO&I\350*\344\360\341\303\264\331l\364z\275\214D\"\f\207\303\234\234\234d\177\177?].\27\25E!\0\26\25\25\321j\265\306,#^!V\253\225EEE\4@EQ\350r\271\330\337\337\317\311\311I\206\303aF\"\21z\275^n\333\266\215\25\25\25)\313\371w\350*\344\333\267o<u\352\324\334\312\353\317/\203\301\300\246\246&j\232\306\261\2611\2\340\350\350\350\2022\342\0212::J\0\34\e\e\243\246iljj\232\267\252\374\363\353\324\251S\374\366\355[\312s_\f\335gY$\31\n\205\370\351\323'\366\366\366\322\357\367\317\315\206~\306j\265\322\345r-x?\36!.\227+f\v\233\231\231\241\337\357goo/?}\372\304P(\224\204l\226\207l!\262\205\374\237\312\312J9\206\374\203?f\226\325\320\320\20\367,+##c\351\311$\t]\205\374X7\312\312\312buu5\257^\275\312c\307\216\321l6\317\275\337\330\330\310\366\366v\2\210\331\225\304#\344\373\367\357\4\300\366\366v6662++\213\0h6\233y\354\3301^\275z\225\325\325\325\314\316\316\376\345\372\332J\240\373\27\aLMM\341\371\363\347x\371\362%\206\206\206PTT4w\245^TT\204\264\2644D\"\21ddd\240\255\255\r{\367\356\235w~ZZ\32\372\372\372`\265Z\361\341\303\a\24\26\26.X>\177\361\342\5\312\312\3120;;\213\364\364t\220\304\333\267o100\200\276\276>\274{\367\16f\263\31{\366\354Ayy9rssW\362O0\17\335\227NFGG\341\361x\360\354\3313|\374\370\21\223\223\223\230\232\232B(\24\202\305b\201\242(\210D\"\0000\267\224\262T\24E\1\0D\"\21\244\247\247czz\32\275\275\275x\377\376=\274^/\332\333\333a\261X\260f\315\32l\335\272UW!\272.\235\324\327\327\303f\263\241\273\273\eN\247\23\315\315\3158t\350\20&&&p\372\364i\250\252\212\363\347\317\343\356\335\273\0\200\35;v$T\317\366\355\333\1\0w\357\336\305\371\363\347\241\252*N\237>\215\211\211\t\34:t\b\315\315\315p:\235\350\351\351\201\315fC]]]\322r\\2\272u\226\224\367Cb\241\253\220\263g\317\312;\206\377@W!\321h\224uuu\\\277~\375\202\213\302\312\312Jvvv2\32\215rjj\212\0\330\337\337\277\240\214x\204\364\367\367\23\0\247\246\246\30\215F\331\331\331\311\312\312\312\5\27\207\353\327\257g]]\335\242\255g%\20b\351$\36TUess\363\202\367\343\21\322\334\334LUUS\36c2X\25\333\200FFF\240iZ\302\217\32\224\227\227C\3234\214\214\214$9\262\344#\274\220\241\241!\230\315f8\34\16\344\345\345%TF^^\36\34\16\a\314f3\206\206\206\222\34a\222\321\273\211.\206\317\347cMM\r\1\360\302\205\v\213\366\353\210s\226\25\215Fy\341\302\5\2`MM\r}>_\312b_\16\302\b\371\261\373\335h4\376\321\273\337u\277R\377\201\321h\204\252\252hhh@AA\0016n\334\230\222\35\351\245\245\245x\360\340\1\2\201\0\276|\371\202\221\221\21\234<y\22\6\203!\351u%\2020B\262\263\263a2\231p\340\300\201\25\251\317d2\301d2\301f\263\301d2a\355\332\265+R\357\357\20~P\377\323X\365B\366\355\3337\367\275\270\252\252b\337\276}:G\264<\204\351\262\22\345\347G\0246m\332\224\360#\v\242\260\352[\310\277\r)D0\244\20\301\220B\4C\n\21\f)D0\244\20\301\220B\4C\n\21\f)D0\244\20\301\220B\4C\n\21\f)D0\244\20\301\220B\4c\3117\250R\371K\237zr\345\312\225\224\224\273\"\277\364)\322o\307&\3\221\362\321\375\t*\311|\344\30\"\30R\210`H!\202!\205\b\206\24\"\30R\210`H!\202!\205\b\206\24\"\30R\210`\374\r\333\262\vc\235\252\240\\\0\0\0\0IEND\256B`\202"))))))))])
  (define-lead in+)
  (define-lead in-)
  (define-lead out+)
  (define-lead out-))

(begin-for-interactive-syntax
  (module+ test
    (let ()
      (define trans (new fet$))
      (check-equal? (set-count (send trans get-lead-table)) 3)
      (define node (new node$))
      (check-equal? (send trans get-drain-lead) #f)
      (send trans set-drain-lead! node)
      (check-equal? (send trans get-drain-lead) node)
      (send trans set-lead 'gate node)
      (check-equal? (send trans get-gate-lead) node)
      (check-equal? (set-count (send node get-components)) 2)
      (send trans set-lead 'drain #f)
      (check-equal? (set-count (send node get-components)) 1))))

;; ===================================================================================================

;; State that tracks the entire state of a circuit.
;; A circuit is composed of a set of nodes and components,
;; where components connect to nodes, and nodes connect to other components.
(define-interactive-syntax circuit-state$ base$
  (super-new)
  (define-state nodes (set)
    #:getter #t)
  (define-state components (set)
    #:getter #t)
  (define/public (add-node node)
    (set! nodes (set-add nodes node)))
  (define/public (add-component component)
    (set! components (set-add components component)))

  ;; Remove a node from the circuit. Disconnects itself from
  ;;    all components before removing itself. The components
  ;;    do NOT get removed.
  (define/public (remove-node node)
    (set! nodes (set-remove nodes node))
    (for ([i (in-set (send node components))])
      (match-define (struct* node-component ([component component]
                                             [lead lead]))
        i)
      (send component set-lead lead #f)))

  ;; Remove a component from the circuit. Also disconects its
  ;;   leads from nodes. And deletes any (now empty) nodes.
  (define/public (remove-component component)
    (set! components (set-remove components component))
    (define nodes-to-check
      (for/fold ([nodes (set)])
                ([lead (in-leads component)])
        (define node (send component get-lead lead))
        (send component set-lead lead #f)
        (set-add nodes node)))
    (for ([i (in-set nodes-to-check)])
      (when (<= (set-count (send i get-components)) 1)
        (remove-node i))))

  ;; Connect a component to either a node or another component.
  ;; Adds components/nodes to circuit if they're not added already.
  ;; component? lead? (or/c component? node?) (or/c lead? #f) -> void?
  (define/public (connect comp lead1 other [lead2 #f])
    (unless (set-member? components comp)
      (add-component comp))
    (cond
      [(is-a? other component$) ; Connect two components
       (define node (new node$))
       (add-node node)
       (send comp set-lead lead1 node)
       (send other set-lead lead2 node)
       (unless (set-member? components other)
         (add-component other))]
      [(is-a? other node$)      ; Connect component to existing node
       (send comp set-lead lead1 other)
       (unless (set-member? nodes other)
         (add-node other))]
      [(not other)                ; Remove component connection
       (define curr-node (send comp get-lead lead1))
       (send comp set-lead lead1 #f)
       (when (<= (set-count (send curr-node get-components)) 1)
         (remove-node curr-node))])))

(define-interactive-syntax circuit$ vertical-block$
  (super-new)
  (init [min-width 0]
        [min-height 0])
  (define schema (new pasteboard$ [parent this]
                      [min-width min-width]
                      [min-height min-height]))
  (define state (new circuit-state$))
  (send this set-background "white")
  (send schema set-background "white")
  (define/public (add-component component [x #f] [y #f])
    (send schema add-child component
          (or x (send component get-component-x))
          (or y (send component get-component-y))))
  (define/public (remove-component [component #f])
    (send schema remove-child component))
  (define/augment (draw dc)
    (for ([node (send state get-nodes)])
      (for ([component (send node get-components)])
        (void))))
  (define/public (connect C1 lead1 C2 [lead2 #f])
    (send state connect C1 lead1 C2 lead2))
  (define add/rem (new horizontal-block$ [parent this]))
  (new button$ [parent add/rem]
       [label (new label$ [text "Add Component"])]
       [callback (λ (b e)
                   (add-component (new resistor$) 0 0))])
  (new button$ [parent add/rem]
       [label (new label$ [text "Remove Component"])]
       [callback (λ (b e)
                   (remove-component))])
  ;(define sim-row (new horizontal-block$ [parent this]))
  #;(new button$ [parent sim-row]
       [label (new label$ [text "Simulate"])]))

(begin-for-interactive-syntax
  (module+ test
    (define the-circuit (new circuit$
                             [min-width 300]
                             [min-height 300]))
    (send the-circuit add-component (new resistor$) 100 100)
    (send the-circuit add-component (new capacitor$) 200 100)
    (test-window the-circuit)))
