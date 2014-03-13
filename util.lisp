(in-package :fern)

(defun make-queue ()
  "Makes a thread-safe FIFO queue (unbounded)."
  (make-instance 'jpl-queues:synchronized-queue
                 :queue (make-instance 'jpl-queues:unbounded-fifo-queue)))

(defun test ()
  (let ((switcher (create-switcher))
        (process1 nil)
        (process2 nil))
    (setf process1 (process (lambda (process)
                              (let ((msg-count 0))
                                (with-messages process (msg)
                                  (format t "process1: ~a~%" msg)
                                  (incf msg-count)
                                  (message process2 (format nil "~a, 1" msg))
                                  (when (< 2 msg-count)
                                    (terminate process))))))
          process2 (process (lambda (process)
                              (let ((msg-count 0))
                                (with-messages process (msg)
                                  (format t "process2: ~a~%" msg)
                                  (message process1 (format nil "~a, 2" msg))
                                  (incf msg-count)
                                  (when (< 2 msg-count)
                                    (terminate process)))))))
    (message process1 "hai")
    (message process2 "zzz")
    (sleep 1)
    (stop-switcher switcher)))

