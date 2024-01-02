;;;;
;;;; System definition for the ks2 bottom-up enumerator solver plugin
;;;;
(asdf:defsystem "systems.duck.ks2.bue"
  :description "Plugin for the ks2 synthesizer suite for using by-the-book bottom-up enumeration"
  :version "0.0.1"
  :author "Keith Johnson <quack@duck.systems>"
  :license "MIT"
  :depends-on ("cl-coroutine"
               "com.kjcjohnson.ks2/solver-api"
               "com.kjcjohnson.synthkit/semgus")
  :pathname "src"
  :serial t
  :components ((:file "package")
               (:file "utility")
               (:file "bank")
               (:file "enumerator")
               (:file "solver")))
