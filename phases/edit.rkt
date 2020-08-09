#lang racket/load

(module player-move racket
  (provide trace-player)
  (define (trace-player board player)
    'stub))

(module main racket
  (require editor/base)
  (begin-for-interactive-syntax
    (require 'player-move)
    (trace-player #f #f)))

(require editor/base)

;; Only runs the 'main' run-time code
(require 'main)

;; Also runs the 'main' edit-time code
(require (from-editor 'main))
