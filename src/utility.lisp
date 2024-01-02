;;;;
;;;; Copied from TDP - put in a library somewhere?
;;;;
(in-package #:systems.duck.ks2.bue)

(defun %io-cegis-rel-spec-transformer (spec context)
  "Converts SPEC to an IO spec if possible, then CEGIS, but still returns relational
if cannot convert to either IO or CEGIS."
  (cond
    ((spec:is-pbe? spec)
     spec)
    ((spec:cegis-supported-for-specification? spec context)
     (spec:convert-to-cegis spec))
    (t
     spec)))

(defun setup-trace (semgus-problem suffix body-fn)
  (let ((path (semgus:path (semgus:context semgus-problem))))
    (with-open-file (ast:*program-trace-stream*
                     (merge-pathnames
                      (make-pathname
                       :name (str:concat (pathname-name path)
                                         "."
                                         suffix)
                       :type "trace")
                      path)
                     :direction :output
                     :if-exists :supersede
                     :if-does-not-exist :create)
      (funcall body-fn))))

(defmacro maybe-trace ((semgus-problem suffix trace) &body body)
  "Maybe traces the execution"
  `(flet ((body-fn () ,@body))
     (if ,trace
         (setup-trace ,semgus-problem ,suffix #'body-fn)
         (funcall #'body-fn))))

(defun all-cart-prod (list)
  "Computes the cartesian product of a list of lists."
  (cond
    ((endp list)
     nil)
    ((= 1 (length list))
     (map 'list #'list (car list)))
    (t
     (let ((output (list)))
       (map nil #'(lambda (n)
                    (setf output (append (map 'list #'(lambda (r)
                                                        (cons r n))
                                              (car list))
                                         output)))
            (all-cart-prod (cdr list)))
       output))))
