;;;;
;;;; Program enumerator
;;;;
(in-package #:systems.duck.ks2.bue)

(defun generate-metric-list/rec (metric arity)
  (if (zerop arity)
      (list nil)
      (let ((result nil))
        (loop for item in (generate-metric-list/rec metric (1- arity))
              do (loop for i from 0 to (1- metric)
                       do (push (cons i item) result)))
        result)))

(defun height-filter (metric item)
  (some #'(lambda (x) (= x (1- metric))) item))

(defun size-filter (metric item)
  (= (apply #'+ item) (1- metric)))

(defun generate-metric-list (metric arity type)
  "Generates a metric list for a production of arity ARITY"
  (remove-if-not (a:curry (case type
                            (:height #'height-filter)
                            (:size #'size-filter))
                          metric)
                 (generate-metric-list/rec metric arity)))

(defun new-terms (bank grammar metric type)
  (let ((terms nil))
    (loop for prod in (g:productions grammar)
          if (and (zerop metric) (zerop (g:arity prod))) do
            (push (make-instance 'ast:program-node
                                 :production prod)
                  terms)
          else do
            (loop for heights in (generate-metric-list metric (g:arity prod) type)
                  for child-opts = (map 'list (a:curry #'banked-programs bank)
                                        (g:occurrences prod)
                                        heights)
                  do
                     (loop with combos = (all-cart-prod child-opts)
                           for combo in combos
                           do (push (make-instance 'ast:program-node
                                                   :production prod
                                                   :children combo)
                                    terms))))
    (cons terms nil)))

(co:defcoroutine coroutine-new-terms (arg)
  (destructuring-bind (bank grammar metric type) arg
    (loop for prod in (g:productions grammar)
          if (and (zerop metric) (zerop (g:arity prod))) do
              (co:yield (make-instance 'ast:program-node
                                       :production prod))
          else do
            (loop for heights in (generate-metric-list metric (g:arity prod) type)
                  for child-opts = (map 'list (a:curry #'banked-programs bank)
                                        (g:occurrences prod)
                                        heights)
                  do
                     (loop with combos = (all-cart-prod child-opts)
                           for combo in combos
                           do (co:yield (make-instance 'ast:program-node
                                                       :production prod
                                                       :children combo)))))))

(defun has-more-terms? (candidates)
  (not (null (car candidates))))

(defun next-term (candidates)
  (prog1
      (first (car candidates))
    (setf (car candidates) (rest (car candidates)))))

(defun co-new-terms (bank grammar metric type)
  (list
   (co:make-coroutine 'coroutine-new-terms)
   nil
   (list bank grammar metric type)))

(defun co-has-more-terms? (candidates)
  (let ((res (funcall (first candidates) (third candidates))))
    (setf (second candidates) res)))

(defun co-next-term (candidates)
  (second candidates))

(defun enumerate (semgus-problem metric-type)
  "Runs bottom-up enumeration"
  (let* ((grammar (semgus:grammar semgus-problem))
         (initial-nt (g:initial-non-terminal grammar))
         (bank (make-bank grammar)))
    (loop for i from 0 do
      (format t "METRIC: ~a~%" i)
      (loop with candidates = (co-new-terms bank grammar i metric-type)
            while (co-has-more-terms? candidates)
            for term = (co-next-term candidates)
            if (and (eql initial-nt (ast:non-terminal term))
                    (semgus:check-program semgus-problem term))
              do (return-from enumerate term)
            end
            do (add-to-bank bank term i)))))
