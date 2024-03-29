#| Partecipanti |#
#| Olmo Ceriotti 886140 |#

#| JSONParse |#
(defun jsonparse (JSONString)
  (if (stringp JSONString)
      (jsonroute (reformatString (charlist JSONString)))
      (error "Not a String")))

(defun charlist (JSONString)
  (cond ((= (length JSONString) 0) NIL)
	(T (cons (char JSONString 0) (charlist (subseq JSONString 1))))))

(defun reformatString (charlist)
   (normalizeNumbers
    (normalizeWhitespace
     (normalizeString charlist NIL 0))
    NIL))

(defun normalizeWhitespace (charlist)
  (deleteChar
   (deleteChar
    (deleteChar
     (deleteChar
      (deleteChar charlist #\Space)
      #\Linefeed)
     #\Tab)
    #\Return)
   #\Newline))

(defun normalizeString (charlist acc mode)
  (cond ((and (null charlist) (null acc)) NIL)
	((null charlist) (error "Not correct string"))
	((and (eql (car charlist) #\") (eql mode 0))
	 (normalizeString (rest charlist) acc 1))
	((and (eql (car charlist) #\") (eql mode 1))
	 (append (list (compact acc)) (normalizeString (rest charlist) NIL  0)))
	((and (eql mode 1) (eql (car charlist) #\\))
	 (normalizeString (rest charlist) acc 2)) 
	((eql mode 1)
	 (normalizeString (rest charlist) (append acc (list (car charlist))) 1))
	((and (eql mode 2) (eql (car charlist) #\"))
	 (normalizeString (rest charlist) (append acc (list (car charlist))) 1))
	((eql mode 2)
	 (normalizeString (rest charlist)
			  (append acc (list (substituteEscape (car charlist)))) 1))
	(T
	 (cons (car charlist) (normalizeString (rest charlist) acc mode)))))

(defun substituteEscape (char)
  (cond ((eql char #\n) #\Newline)
	((eql char #\b) #\Backspace)
	((eql char #\r) #\Return)
	((eql char #\t) #\Tab)
	(T char)))


(defun normalizeNumbers (charlist acc)
  (cond ((and (null charlist) (null acc)) NIL)
	((null charlist)
	 (list (parseNumber (compact acc))))
	((and (not (stringp (car charlist)))
	      (not (null (digit-char-p (car charlist)))))
	 (normalizeNumbers (rest charlist) (append  acc (list (car charlist)))))
	((or (eql (car charlist) #\-)
	     (eql (car charlist) #\.)
	     (eql (car charlist) #\+)
	     (eql (car charlist) #\e)
	     (eql (car charlist) #\E))
	 (normalizeNumbers (rest charlist) (append acc (list (car charlist)))))
	((not (null acc))
	 (append (list (parseNumber (compact acc)))
		 (normalizeNumbers charlist NIL)))
	(T
	 (append (list (car charlist)) (normalizeNumbers (rest charlist) acc)))))

(defun parseNumber (numString)
  (cond ((equal numString "e") #\e)
	((or (not (null (find #\. numString)))
	     (or (not (null (find #\e numString)))
		 (not (null (find #\E numstring)))))
	 (parse-float numString))
	(T (parse-integer numString))))

(defun jsonroute (tokens)
  (cond ((and (eql (car tokens) #\{) (eql (car (last tokens)) #\}))
	 (cons 'jsonobj (findprops (nolast (rest tokens)) NIL 0 0 0 0 "obj")))
	((and (eql (car tokens) #\[) (eql (car (last tokens)) #\]))
	 (cons 'jsonarray (findprops (nolast (rest tokens)) NIL 0 0 0 0 "arr")))
	(T (error "Not a valid object"))))

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
		(append (list (evalPair acc))
			(findProps (rest tokens) NIL 0 0 0 0 "obj")))
	       ((equal mode "arr")
		(append (list (isValue  acc))
			(findProps (rest tokens) NIL 0 0 0 0 "arr")))
	       (T (error "Mode Error"))))
	(T
	 (findProps (rest tokens) (append acc (list (car tokens)))
		    gOpen gCLosed sOpen sClosed mode))))

(defun evalPair (pairToken)
  (cond ((not (stringp (first pairToken)))
	 (error "Not valid property name"))
	((not (eql (second pairToken) #\:))
	 (error "Not valid property"))
	(T (append (list (first pairToken))
		   (list (isValue (cdr (cdr pairToken))))))))
	 
(defun isValue (valueToken)
  (cond ((null valueToken) NIL)
	((stringp (car valueToken)) (car valueToken))
	((numberp (car valueToken)) (car valueToken))
	((and (eql (car valueToken) #\{) (eql (car (last valueToken)) #\}))
	 (cons 'jsonobj (findProps (nolast (rest valueToken)) NIL 0 0 0 0 "obj")))
	((and (eql (car valueToken) #\[) (eql (car (last valueToken)) #\]))
	 (cons 'jsonarray
	       (findProps (nolast (rest valueToken)) NIL 0 0 0 0 "arr")))
	((equal (compact valueToken) "true") 'true)
	((equal (compact valueToken) "false") 'false)
	((equal (compact  valueToken) "null") 'null)
	(T  (error "Not a value"))))

#|Utility JSONParse|#

(defun compact (charlist)
  (cond ((null charlist) "")
	(T (concatenate  'string  (string (car charlist))
			 (compact (rest charlist))))))

(defun nolast (list)
  (reverse (rest (reverse list))))

(defun deleteChar (charlist char)
  (cond  ((null charlist) charlist)
	 ((eql (car charlist) char)
	  (deleteChar (rest charlist) char))
	 (T
	  (cons (car charlist) (deleteChar (rest charlist) char)))))

#| JSONAcces |#
(defun jsonaccess (JSONObject &rest access)
  (jsonhelper JSONObject (flatten access)))

(defun jsonhelper (JSONObject access)
  (cond ((null access) NIL)
	((and (eql (car JSONObject) 'jsonobj)
	      (stringp (car access)))
	 (cond ((not (null (rest access)))
		(jsonaccess (findProp (rest JSONObject) (car access)) (rest access)))
	       (T  (findProp (rest JSONObject) (car access)))))
	((and (eql (car JSONObject) 'jsonarray)
	      (numberp  (car access)))
	 (cond ((not (null (rest access)))
		(jsonaccess (findValue (rest JSONObject) (car access)) (rest access)))
	       (T (findValue (rest JSONObject) (car access)))))
	(T
	 (error "Not a  valid search field"))))

(defun findProp (fieldList Field)
  (cond ((null fieldList)
	 (error "Field not present"))
	((equal (car (first fieldList)) Field)
	 (second (first  fieldList)))
	(T
	 (findProp (rest fieldList) Field))))

(defun findValue (array index)
  (cond ((null array)
	 (error "Not valid index"))
	((eql index 0)
	 (car array))
	(T
	 (findValue (rest array) (- index 1)))))

(defun flatten (list)
  (cond ((null list) list)
	((atom list) (list list))
	(T (append (flatten (first list))
		   (flatten (rest list))))))


#| JSONRead |#
(defun jsonread (filename)
  (with-open-file (stream filename
			  :direction :input
			  :if-does-not-exist :error)
    (let* ((contents (make-string (file-length stream)))
	   (position (read-sequence contents stream)))
      (if (> (length contents) position)
	  (jsonparse (subseq contents 0 position))
	  (jsonparse contents)))))

#| JSONDump |#
(defun jsondump (JSON filename)
  (with-open-file (stream filename
			  :direction :output
			  :if-exists :supersede
			  :if-does-not-exist :create)
    (format stream "~A" (jsonconvert JSON)))
  filename)

(defun jsonconvert (JSON)
  (cond ((eql (car JSON) 'jsonobj)
	 (concatenate 'string "{"
		      (reduceObj 'pairConvert (rest JSON)  "" "") "}"))
	((eql (car JSON) 'jsonarray)
	 (concatenate 'string "["
		      (reduceObj 'valueConvert (rest JSON)  "" "") "]"))
	(T
	 (error "Not a valid argument"))))

(defun reduceObj (function list initial-value tok)
  (cond ((null list) initial-value)
	(T
	 (reduceObj function (rest list)
		    (concatenate 'string initial-value  tok
				 (funcall function (car list)))
		    ", "))))

(defun pairConvert (JSON)
  (concatenate 'string
	       (valueConvert (first JSON))
	       ": "
	       (valueConvert (second JSON))))

(defun valueConvert (JSONValue)
  (cond ((null JSONValue) NIL)
	((stringp JSONValue) (concatenate 'string "\"" JSONValue "\""))
	((numberp JSONValue) (write-to-string JSONValue))
	((or (eql JSONValue 'true)
	    (eql JSONValue 'false)
	    (eql JSONValue 'null))
	 (write-to-string JSONValue))
	((or (eql (car JSONValue) 'jsonobj)
	     (eql (car JSONValue) 'jsonarray))
	 (jsonconvert JSONValue))))
