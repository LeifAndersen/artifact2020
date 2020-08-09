#lang racket/base

(require bitsyntax)

(define (parse-header bs)
  (bit-string-case
   bs
   ([(source-port :: binary bits 16)
     (destination-port :: binary bits 16)
     (sequence-number :: binary bits 32)
     (acknowledgement-number :: binary bits 32)
     (data-offset :: binary bits 4)
     (reserved :: binary bits 6)
     (urg :: binary bits 1)
     (ack :: binary bits 1)
     (psh :: binary bits 1)
     (rst :: binary bits 1)
     (syn :: binary bits 1)
     (fin :: binary bits 1)
     (window :: binary bits 16)
     (checksum :: binary bits 16)
     (urgent-pointer :: binary bits 16)
     (rest :: binary)]
    checksum)))

(define pattern
  (bytes-append
   #"\x00\x00\x03\x04\x00\x06\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00"
   #"\x45\x00\x00\x37\x21\x2d\x40\x00\x40\x06\x1b\x92\x7f\x00\x00\x01"
   #"\x7f\x00\x00\x01\xbf\x3e\x23\x82\xc6\xfe\xe6\xeb\xbe\xb9\x01\x07"
   #"\x80\x18\x02\x00\xfe\x2b\x00\x00\x01\x01\x08\x0a\x10\xde\xd5\xe7"
   #"\x10\xde\xd5\xe7\x48\x69\x0a"))

(parse-header pattern)
