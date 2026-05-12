;; =========================================================
;; MODULE MAIN (Data Structures)
;; =========================================================
(defmodule MAIN (export ?ALL))

(deftemplate percept
  (slot x) (slot y)
  (slot steps)      
  (slot breeze)
  (slot stench)
  (slot glitter)
  (slot energy)
)

(deftemplate counter
  (slot step)
)

(deftemplate action
  (slot move)
)

;; --- NEW KNOWLEDGE BASE (KB) ---
(deftemplate cell
  (slot x) (slot y)
  (slot visited (default FALSE))
)

(deftemplate danger
  (slot x) (slot y)
  (slot cf (default 0.0)) ; Certainty Factor for hazards
)

(deftemplate wall
  (slot x) (slot y)
)

(deftemplate last-pos
  (slot x) (slot y) (slot dir (default none))
)

(deftemplate evaluated-danger (slot x) (slot y))

;; --- INIT ---
(deffacts initial
  (counter (step 0))
  (last-pos (x -1) (y -1) (dir none))
)

;; The cycle: First update the KB, then choose the move
(defrule deliberate
  (counter (step ?step))
  =>
  (focus PERCEPTION DECISION)
)


;; =========================================================
;; MODULE PERCEPTION (Update KB & CF Choices)
;; =========================================================
(defmodule PERCEPTION (import MAIN ?ALL))

;; 1. Clean the action of the previous step
(defrule clean-old-action
   (declare (salience 200))
   ?a <- (action)
   =>
   (retract ?a)
)

;; 2. Detect Wall (If we tried to move but stayed in same cell)
(defrule detect-wall
   (percept (x ?x) (y ?y))
   (last-pos (x ?px) (y ?py) (dir ?d))
   (test (and (= ?x ?px) (= ?y ?py)))
   (test (neq ?d none))
   =>
   (if (eq ?d right) then (assert (wall (x (+ ?x 1)) (y ?y))))
   (if (eq ?d left)  then (assert (wall (x (- ?x 1)) (y ?y))))
   (if (eq ?d up)    then (assert (wall (x ?x) (y (- ?y 1)))))
   (if (eq ?d down)  then (assert (wall (x ?x) (y (+ ?y 1)))))
)

;; 3. Mark the current cell as visited
(defrule mark-visited
   (percept (x ?x) (y ?y))
   (not (cell (x ?x) (y ?y) (visited TRUE)))
   =>
   (assert (cell (x ?x) (y ?y) (visited TRUE)))
)

;; 4. CF Choices: If Breeze or Stench, mark neighbors with CF 0.5
(defrule evaluate-danger
   (percept (x ?x) (y ?y) (breeze ?b) (stench ?s))
   (test (or (eq ?b TRUE) (eq ?s TRUE)))
   (not (evaluated-danger (x ?x) (y ?y)))
   =>
   (assert (evaluated-danger (x ?x) (y ?y)))
   (assert (danger (x (+ ?x 1)) (y ?y) (cf 0.5)))
   (assert (danger (x (- ?x 1)) (y ?y) (cf 0.5)))
   (assert (danger (x ?x) (y (+ ?y 1)) (cf 0.5)))
   (assert (danger (x ?x) (y (- ?y 1)) (cf 0.5)))
)


;; =========================================================
;; MODULE DECISION (Choose Action)
;; =========================================================
(defmodule DECISION (import MAIN ?ALL))

;; Save our intention so Perception can detect walls next turn
(defrule save-intent
   (declare (salience 1000))
   (action (move ?dir))
   ?lp <- (last-pos)
   (percept (x ?x) (y ?y))
   =>
   (modify ?lp (x ?x) (y ?y) (dir ?dir))
)

;; --- PRIORITY 100: WIN! ---
(defrule grab-gold
   (declare (salience 100))
   (percept (glitter TRUE))
   =>
   (assert (action (move grab)))
   (printout t "ACTION: GRAB GOLD!" crlf)
)

;; --- PRIORITY 50: EXPLORE (Avoid visited, avoid danger) ---
(defrule explore-right
   (declare (salience 50))
   (percept (x ?x) (y ?y))
   (not (cell (x =(+ ?x 1)) (y ?y) (visited TRUE)))
   (not (danger (x =(+ ?x 1)) (y ?y)))
   (not (wall (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right)))
)
(defrule explore-left
   (declare (salience 50))
   (percept (x ?x) (y ?y))
   (not (cell (x =(- ?x 1)) (y ?y) (visited TRUE)))
   (not (danger (x =(- ?x 1)) (y ?y)))
   (not (wall (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left)))
)
(defrule explore-up
   (declare (salience 50))
   (percept (x ?x) (y ?y))
   (not (cell (x ?x) (y =(- ?y 1)) (visited TRUE)))
   (not (danger (x ?x) (y =(- ?y 1))))
   (not (wall (x ?x) (y =(- ?y 1))))
   => (assert (action (move up)))
)
(defrule explore-down
   (declare (salience 50))
   (percept (x ?x) (y ?y))
   (not (cell (x ?x) (y =(+ ?y 1)) (visited TRUE)))
   (not (danger (x ?x) (y =(+ ?y 1))))
   (not (wall (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down)))
)

;; --- PRIORITY 25: BACKTRACK (If blocked, go to visited cells) ---
(defrule backtrack-right
   (declare (salience 25))
   (percept (x ?x) (y ?y))
   (cell (x =(+ ?x 1)) (y ?y) (visited TRUE))
   (not (wall (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right)))
)
(defrule backtrack-left
   (declare (salience 25))
   (percept (x ?x) (y ?y))
   (cell (x =(- ?x 1)) (y ?y) (visited TRUE))
   (not (wall (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left)))
)
(defrule backtrack-up
   (declare (salience 25))
   (percept (x ?x) (y ?y))
   (cell (x ?x) (y =(- ?y 1)) (visited TRUE))
   (not (wall (x ?x) (y =(- ?y 1))))
   => (assert (action (move up)))
)
(defrule backtrack-down
   (declare (salience 25))
   (percept (x ?x) (y ?y))
   (cell (x ?x) (y =(+ ?y 1)) (visited TRUE))
   (not (wall (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down)))
)

;; --- PRIORITY 10: QUIT ---
(defrule quit-game
   (declare (salience 10))
   (percept (x 0) (y 0))
   =>
   (assert (action (move quit)))
)