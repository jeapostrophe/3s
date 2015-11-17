#lang racket/base
(require racket/generic
         racket/match
         lux/chaos
         3s)

(struct 3s-chaos (sndctx [sndst #:mutable])
        #:methods gen:chaos
        [(define (chaos-output! c o)
           (match-define (vector scale lp w cmds) o)
           ;; XXX This is implies that we could switch sounds while
           ;; rendering the next sound... which is bad.
           (define stp (render-sound (3s-chaos-sndst c) scale lp w cmds))
           (set-3s-chaos-sndst! c stp))
         (define (chaos-swap! c t)
           (define old-sndst (3s-chaos-sndst c))
           (when old-sndst
             (sound-pause! old-sndst))
           (define new-sndst
             (initial-system-state
              (3s-chaos-sndctx c)))
           (set-3s-chaos-sndst! c new-sndst)
           (begin0 (t)
             (let ()
               (define end-sndst (3s-chaos-sndst c))
               (sound-pause! end-sndst)
               (sound-destroy! end-sndst)
               (set-3s-chaos-sndst! c old-sndst)
               (when old-sndst
                 (sound-unpause! old-sndst)))))
         (define (chaos-stop! c)
           (sound-context-destroy! (3s-chaos-sndctx c)))])
(define (make-3s)
  (3s-chaos (make-sound-context)
            #f))

(provide make-3s)
