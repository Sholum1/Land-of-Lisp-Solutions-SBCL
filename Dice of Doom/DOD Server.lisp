(load "Dice of Doom v4")

(defparameter *cur-game-tree* nil)
(defparameter *from-tile* nil)

(defun web-initialize ()
  (setf *from-tile* nil)
  (setf *cur-game-tree* (game-tree (gen-board) 0 0 t)))

(defun web-announce-winner (board)
  (fresh-line)
  (let ((w (winners board)))
    (if (> (length w) 1)
	(format t "The game is a tie between ~a" (mapcar #'player-letter w))
	(format t "The winner is ~a" (player-letter (car w)))))
  (tag a (href "game.html")
    (princ " play again")))

(defun web-handle-human (pos)
  (cond ((not pos) (princ "Please choose a hex to move from:"))
        ((eq pos 'pass) (setf *cur-game-tree*
                              (cadr (lazy-car (caddr *cur-game-tree*))))
         (princ "Your reinforcements have been placed.")
         (tag a (href (make-game-link nil))
	   (princ "continue")))
        ((not *from-tile*) (setf *from-tile* pos)
	 (princ "Now choose a destination:"))
        ((eq pos *from-tile*) (setf *from-tile* nil)
	 (princ "Move cancelled."))
        (t (setf *cur-game-tree*
                 (cadr (lazy-find-if (lambda (move)
                                       (equal (car move)
                                              (list *from-tile* pos)))
                                     (caddr *cur-game-tree*))))
           (setf *from-tile* nil)
           (princ "You may now ")
           (tag a (href (make-game-link 'pass))
	     (princ "pass"))
           (princ " or make another move:"))))

(defun web-handle-computer ()
  (setf *cur-game-tree* (handle-computer *cur-game-tree*))
  (princ "the computer has moved.")
  (tag script ()
    (princ
     "window.setTimeout('window.location=\"game.html?chosen=NIL\"',5000)")))

(defun draw-dod-page (tree selected-tile)
  (svg *board-width*
      *board-height*
    (draw-board-svg (cadr tree)
		    selected-tile
		    (take-all (if selected-tile
				  (lazy-mapcar
				   (lambda (move)
				     (when (eql (caar move)
						selected-tile)
				       (cadar move)))
				   (caddr tree))
				  (lazy-mapcar #'caar (caddr tree)))))))

;; Exercise 3
;; Implement Multiplayer as per page 410

;; Exercise 4
;; Use something safer than read-from-string
(defun dod-request-handler (path header params)
  (declare (ignore header))
  (format t "HTTP/1.0 200 OK~2%")
  (if (equal path "game.html")
      (progn (princ "<!doctype html>")
	     (tag center ()
	       (princ "Welcome to DICE OF DOOM!")
	       (tag br ())
	       (let ((chosen (assoc 'chosen params)))
		 (when (or (not *cur-game-tree*) (not chosen))
		   (setf chosen nil)
		   (web-initialize))
		 (cond ((lazy-null (caddr *cur-game-tree*))
			(web-announce-winner (cadr *cur-game-tree*)))
		       ((zerop (car *cur-game-tree*))
			(web-handle-human
			 (when chosen
			   (read-from-string (cdr chosen)))))
		       (t (web-handle-computer))))
	       (tag br ())
	       (draw-dod-page *cur-game-tree* *from-tile*)))
      (princ "Sorry... I don't know that page.")))
