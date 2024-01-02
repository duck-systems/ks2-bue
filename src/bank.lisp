;;;;
;;;; A bank of programs
;;;;
(in-package #:systems.duck.ks2.bue)

(defclass bank ()
  ((programs :initform (make-array 10 :adjustable t :initial-element nil)
             :accessor programs)))

(defun make-bank (grammar)
  (declare (ignore grammar))
  (make-instance 'bank))

(defun %ensure-bank-ht (bank metric)
  (when (<= (length (programs bank)) metric)
    (setf (programs bank) (adjust-array (programs bank)
                                        (max (ceiling (* 1.3 (length (programs bank))))
                                             (1+ metric))
                                        :initial-element nil)))
  (when (null (aref (programs bank) metric))
    (setf (aref (programs bank) metric) (make-hash-table))))

(defun add-to-bank (bank program metric)
  (let ((nt (ast:non-terminal program)))
    (%ensure-bank-ht bank metric)
    (let ((ht (aref (programs bank) metric)))
      (push program (gethash nt ht)))))

(defun banked-programs (bank nt metric)
  (%ensure-bank-ht bank metric)
  (gethash nt (aref (programs bank) metric)))
