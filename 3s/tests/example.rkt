#lang racket/base
(require racket/list
         racket/runtime-path
         3s)

(define-runtime-path track1-pth "341620__projectsu012__arpeggiating-delay-ringing.wav")
(define (go!)
  (define sema (make-semaphore))
  (define new-custodian (make-custodian))
  (define test-t
    (parameterize ([current-custodian new-custodian])
      (thread
       (lambda ()
         (define sc (make-sound-context))
         (define track1 (path->audio track1-pth))
         (displayln "T Initializing")
         (define ss0 (initial-system-state sc))
         (semaphore-wait sema)
         (displayln "T Playing sound")
         (define ss1
           (render-sound ss0 1.0 0.0+0.0i #f
                         (list
                          (background (λ (w) track1)
                                      #:pause-f (λ (w) w)))))
         (displayln "T Waiting")
         (semaphore-wait sema)
         (displayln "T Stopping sound")
         (define ss2 (render-sound ss1 1.0 0.0+0.0i #t empty))
         (displayln "T Waiting")
         (semaphore-wait sema)
         (displayln "T Restarting sound")
         (define ss3 (render-sound ss2 1.0 0.0+0.0i #f empty))
         (displayln "T Waiting")
         (semaphore-wait sema)
         (displayln "T Dying")
         (sound-destroy! ss3)
         (sound-context-destroy! sc)))))
  
  (sleep 1)
  (semaphore-post sema)
  (sleep 2)
  (semaphore-post sema)
  (sleep 1)
  (semaphore-post sema)
  (sleep 2)
  (displayln "P Killing custodian")
  (custodian-shutdown-all new-custodian)
  (thread-wait test-t)
  (displayln "P Waiting")
  (sleep 5)
  (displayln "P Exitting"))

(module+ main
  (go!))
