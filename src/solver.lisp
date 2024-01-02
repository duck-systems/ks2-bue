;;;;
;;;; Solver configuration
;;;;
(in-package #:systems.duck.ks2.bue)

(s-api:register-solver :bue 'bottom-up-enumerator)

(defclass bottom-up-enumerator (s-api:solver)
  ()
  (:documentation "The bottom-up enumerator solver class"))

(s-api:define-solver-metadata bottom-up-enumerator
  :name "By-the-book Bottom-Up Enumerator"
  :symbol "bue"
  :description "A by-the-book bottom-up enumerator for SemGuS problems"
  :action "BUE Solve"
  :spec-transformer #'%io-cegis-rel-spec-transformer
  :options (list
            (s-api:make-solver-option
             :keyword :metric
             :name "Metric"
             :description "Metric for computing costs of programs"
             :default :size
             :type '(:member :size :height))))

(defmethod s-api:solve-problem ((solver bottom-up-enumerator) semgus-problem
                          &key (metric :size) trace)
  (maybe-trace (semgus-problem
                (format nil "~a" metric)
                trace)
    (semgus:maybe-with-cegis (solver semgus-problem)
      (enumerate semgus-problem metric))))


(defun test (problem &optional (metric :size))
  (let ((solver (s-api:resolve-solver :bue)))
    (s-api:solve-problem solver problem :metric metric)))
