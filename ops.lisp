;;; -*- Mode: Lisp; Syntax: Common-Lisp; -*-
;;; Module: ops.lisp
;;; different worlds and operators for the GPS planner.
;;; bugs to vladimir kulyukin in canvas
;;; =========================================

(in-package :user)

(defstruct op "An operation"
  (action nil) 
  (preconds nil) 
  (add-list nil) 
  (del-list nil))

(defun executing-p (x)
  "Is x of the form: (execute ...) ?"
  (starts-with x 'execute))

(defun convert-op (op)
  "Make op conform to the (EXECUTING op) convention."
  (unless (some #'executing-p (op-add-list op))
    (push (list 'execute (op-action op)) (op-add-list op)))
  op)

(defun op (action &key preconds add-list del-list)
  "Make a new operator that obeys the (EXECUTING op) convention."
  (convert-op
    (make-op :action action :preconds preconds
             :add-list add-list :del-list del-list)))

;;; ================= Son At School ====================

(defparameter *school-world* '(son-at-home car-needs-battery
					   have-money have-phone-book))

(defparameter *school-ops*
  (list
    ;;; operator 1
   (make-op :action 'drive-son-to-school
	    :preconds '(son-at-home car-works)
	    :add-list '(son-at-school)
	    :del-list '(son-at-home))
   ;;; operator 2
   (make-op :action 'shop-installs-battery
	    :preconds '(car-needs-battery shop-knows-problem shop-has-money)
	    :add-list '(car-works))
   ;;; operator 3
   (make-op :action 'tell-shop-problem
	    :preconds '(in-communication-with-shop)
	    :add-list '(shop-knows-problem))
   ;;; operator 4
   (make-op :action 'telephone-shop
	    :preconds '(know-phone-number)
	    :add-list '(in-communication-with-shop))
   ;;; operator 5
   (make-op :action 'look-up-number
	    :preconds '(have-phone-book)
	    :add-list '(know-phone-number))
   ;;; operator 6
   (make-op :action 'give-shop-money
	    :preconds '(have-money)
	    :add-list '(shop-has-money)
	    :del-list '(have-money))))

;;; ================= Sussman's Anomaly ====================

(defparameter *block-world* '(a-on-t b-on-t c-on-a clear-c clear-b))

(defparameter *block-ops*
  (list
   ;;; your block world operators to avoid the Sussman Anomaly.
    (make-op :action 'PUT-A-FROM-T-ON-B
	     :preconds '(B-ON-C C-ON-T CLEAR-B)
	     :add-list '(A-ON-B)
	     :del-list '(CLEAR-B))
    (make-op :action 'PUT-C-FROM-A-ON-T
	     :preconds '(CLEAR-C)
	     :add-list '(C-ON-T)
	     :del-list '(C-ON-A))
    (make-op :action 'PUT-B-FROM-T-ON-C
	     :preconds '(CLEAR-C C-ON-T)
	     :add-list '(B-ON-C)
	     :del-list '(CLEAR-C))
   )
  )
	    
;;; ================= Monkey and Bananas ====================

(defparameter *banana-world* '(at-door on-floor has-ball hungry chair-at-door))

(defparameter *banana-ops*
  (list
    ;;; your banana world operators to help the hungry monkey not to starve.
    (make-op :action 'EAT-BANANAS
	     :preconds '(HAS-BANANAS)
	     :add-list '(NOT-HUNGRY)
	     :del-list '(HUNGRY)
)
    (make-op :action 'GRASP-BANANAS
	     :preconds '(AT-BANANAS EMPTY-HANDED)
	     :add-list '(HAS-BANANAS))
    (make-op :action 'CLIMB-ON-CHAIR 
             :preconds '(CHAIR-AT-MIDDLE-ROOM ON-FLOOR)
             :add-list '(AT-BANANAS)
	     :del-list '(ON-FLOOR))
    (make-op :action 'PUSH-CHAIR-FROM-DOOR-TO-MIDDLE-ROOM
	     :preconds '(AT-DOOR)
	     :add-list '(CHAIR-AT-MIDDLE-ROOM)
	     :del-list '(CHAIR-AT-DOOR))
    (make-op :action 'DROP-BALL
	     :preconds '(HAS-BALL)
	     :add-list '(EMPTY-HANDED)
	     :del-list '(HAS-BALL))
    )
  )
  
(mapc #'convert-op *school-ops*)
(mapc #'convert-op *block-ops*)
(mapc #'convert-op *banana-ops*)

(provide :ops)
