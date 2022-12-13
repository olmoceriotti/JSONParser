#|
   TODO
1) rimuovere whitespace
2) tokenizzare numeri
3) tokenizzare boolean
|#

(defun jsonparse (JSONString)
  (if (stringp JSONString)
      (jsonroute (reformatString (charlist JSONString)))
      (error "Not a String! Not cool!")))

(defun charlist (JSONString)
  (cond ((= (length JSONString) 0) NIL)
	(T (cons (char JSONString 0) (charlist (substring JSONString 1))))))

(defun reformatString (charlist)
  (normalizeBooleans
   (normalizeNumbers
    (normalizeString
     (normalizeWhitespace charlist) NIL 0))))

(defun normalizeWhitespace (charlist) charlist)

(defun normalizeString (charlist acc mode)
  (cond ((and (null charlist) (null acc)) NIL)
	((null charlist) (error "Not correct string"))
	((and (eql (car charlist) #\") (eql mode 0))
	 (normalizeString (rest charlist) acc 1))
	((and (eql (car charlist) #\") (eql mode 1))
	 (append (list (compact acc)) (normalizeString (rest charlist) NIL  0)))
	((eql mode 1)
	 (normalizeString (rest charlist) (append acc (list (car charlist))) 1))
	(T
	 (cons (car charlist) (normalizeString (rest charlist) acc mode)))))
	 
(defun normalizeNumbers (charlist) charlist)
(defun normalizeBooleans (charlist) charlist)


(defun jsonroute (tokens)
  (cond ((and (eql (car tokens) #\{) (eql (car (last tokens)) #\}))
	 (cons 'jsonobj (findprops (nolast (rest tokens)) NIL 0 0 0 0 "obj")))
	((and (eql (car tokens) #\[) (eql (car (last tokens)) #\]))
	 (cons 'jsonarray (findprops (nolast (rest tokens)) NIL 0 0 0 0 "arr")))
	(T (error "Fuck that"))))

(defun findProps (tokens acc gOpen gClosed sOpen sClosed mode)
  (cond ((and (null tokens) (null acc)) NIL)
	((null tokens)
	 (cond ((equal mode "obj")
		(list (evalPair acc)))
	       ((equal mode "arr")
		(list (isValue acc)))
	       (T (error "Mode error"))))
	((eql (car tokens) #\{)
	 (findProps (rest tokens)
		    (append acc (list (car tokens)))
		    (+ 1 gOpen) gClosed sOpen sClosed mode))
	((eql (car tokens) #\})
	 (findProps (rest tokens)
		    (append acc (list (car tokens)))
		    gOpen (+ 1 gClosed) sOpen sClosed mode))
	((eql (car tokens) #\[)
	 (findProps (rest tokens)
		    (append acc (list (car tokens)))
		    gOpen gClosed (+ 1 sOpen) sClosed mode))
	((eql (car tokens) #\])
	 (findProps (rest tokens)
		    (append acc (list (car tokens)))
		    gOpen gClosed sOpen (+ 1 sClosed) mode))
	((and (eql (car tokens) #\,) (eql gOpen gClosed) (eql sOpen sClosed))
	 (cond ((equal mode "obj")
		(append (list (evalPair acc)) (findProps (rest tokens) NIL 0 0 0 0 "obj")))
	       ((equal mode "arr")
		(append (list (isValue  acc)) (findProps (rest tokens) NIL 0 0 0 0 "arr")))
	       (T (error "Mode Error"))))
	(T
	 (findProps (rest tokens) (append acc (list (car tokens)))
		    gOpen gCLosed sOpen sClosed mode))))

(defun evalPair (pairToken)
  (cond ((not (stringp (first pairToken)))
	 (error "Not valid property name"))
	((not (eql (second pairToken) #\:))
	 (error "Not valid property"))
	(T (append (list (first pairToken)) (list (isValue (cdr (cdr pairToken))))))))
	 
(defun isValue (valueToken)
  (cond ((null valueToken) NIL)
	((stringp (car valueToken)) (car valueToken))
	((and (eql (car valueToken) #\{) (eql (car (last valueToken)) #\}))
	 (cons 'jsonobj (findProps (nolast (rest valueToken)) NIL 0 0 0 0 "obj")))
	((and (eql (car valueToken) #\[) (eql (car (last valueToken)) #\]))
	 (cons 'jsonarray (findProps (nolast (rest valueToken)) NIL 0 0 0 0 "arr")))))

#|Utility|#

(defun compact (charlist)
  (cond ((null charlist) "")
	(T (concatenate  'string  (string (car charlist)) (compact (rest charlist))))))

(defun nolast (list)
  (reverse (rest (reverse list))))
