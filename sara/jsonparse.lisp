;;; JSONPARSE
(defun jsonparse (JSONString)
    (cond ((stringp JSONString) (checkPar (composeString (decomposeString JSONString))))
          (T (error "Input not valid"))))

;;; Trasformo stringa in lista di caratteri
(defun decomposeString (JSONString)
    (cond ((= (length JSONString) 0) NIL)
          (T (cons (char JSONString 0) 
                   (decomposeString (subseq JSONString 1))))))

(defun listToString (list)
    (if (null list) 
        ""
        (concatenate 'string (string (car list)) (listToString (rest list)))))

;;; Controllo numeri, stringhe e whitespace e ricompongo la stringa controllata
(defun composeString (decomposedString)
    (checkNumber 
        (checkString 
            (checkWhitespace decomposedString) 
        NIL 0) NIL))

;;; Whitespace
(defun checkWhitespace (decomposedString)
    (deleteChar 
        (deleteChar
            (deleteChar
                (deleteChar decomposedString #\Space)
                #\Linefeed)
            #\Return)
        #\Tab))

(defun deleteChar (decomposedString char)
    (cond ((null decomposedString) decomposedString) 
          ((equal (car decomposedString) char) 
                (deleteChar (rest decomposedString) char))
          (T (cons (car decomposedString) 
                (deleteChar (rest decomposedString) char)))))

;;; String
(defun checkString (decomposedString accumulator step)
    (cond ((and (null decomposedString) (null accumulator)) NIL)
          ((null decomposedString) (error "Not a vaild String"))
          ((and (equal (car decomposedString) #\") (= step 0)) 
                (checkString (rest decomposedString) accumulator 1))
          ((and (equal (car decomposedString) #\") (= step 1))
                (append (list (listToString accumulator)) 
                      (checkString (rest decomposedString) NIL 0)))
          ((= step 1) 
                (checkString (rest decomposedString) 
                (append accumulator (list (first decomposedString))) 1))
          (T (cons (car decomposedString) (checkString (rest decomposedString) accumulator step)))))

(defun checkNumber (decomposedNum accumulator)
    (cond ((and (null decomposedNum) (null accumulator)) NIL)
          ((null decomposedNum) (list (convertNum (listToString accumulator))))
          ((and (not (stringp (first decomposedNum))) (not (null (digit-char-p (first decomposedNum)))))
            (checkNumber (rest decomposedNum) (append accumulator (list (first decomposedNum)))))
          ((or (equal (first decomposedNum) #\.)
                (equal (first decomposedNum) #\+)
                (equal (first decomposedNum) #\-)
                (equal (first decomposedNum) #\e)
                (equal (first decomposedNum) #\E))
            (checkNumber (rest decomposedNum) (append accumulator (list (first decomposedNum)))))
          ((not (null accumulator))
           (append (list (convertNum (listToString accumulator))) (checkNumber decomposedNum NIL)))
          (T (append (list (first decomposedNum)) (checkNumber (rest decomposedNum) accumulator)))))

(defun convertNum (number)
    (cond ((equal number "e") #\e)
          ((or (not (null (find #\. number))) (not (null (find #\e number))) (not (null (find #\E number))))
          (parse-float number))
          (T (parse-integer number))))

(defun checkPar (list)
    (cond ((and (equal (first list) #\{) (equal (first (last list)) #\})) 
                (cons 'jsonobj (checkToken (butlast (rest list)) NIL 0 0 0 0)))
          ((and (equal (first list) #\[) (equal (first (last list)) #\])) 
                (cons 'jsonarray (checkToken (butlast (rest list)) NIL 0 0 0 0)))
          (T (error "Not a valid input"))))

(defun checkToken (tokenList accumulator count1 count2 count3 count4) 
    (cond ((and (null tokenList) (null accumulator)) NIL)
          ((null tokenList) (convertCont accumulator))
          ((equal (first tokenList) #\{)
           (checkToken (rest tokenList) (append accumulator (list (first tokenList))) (+ count1 1) count2 count3 count4))
          ((equal (first tokenList) #\})
           (checkToken (rest tokenList) (append accumulator (list (first tokenList))) count1 (+ count2 1) count3 count4))
          ((equal (first tokenList) #\[)
           (checkToken (rest tokenList) (append accumulator (list (first tokenList))) count1 count2 (+ count3 1) count4))
          ((equal (first tokenList) #\])
           (checkToken (rest tokenList) (append accumulator (list (first tokenList))) count1 count2 count3 (+ count4 1)))
          ((and (equal (first tokenList) #\,)
                (eql count1 count2)
                (eql count3 count4))
            (append (convertCont accumulator) (checkToken (rest tokenList) NIL 0 0 0 0)))
          (T (checkToken (rest tokenList) (append accumulator (list (first tokenList))) count1 count2 count3 count4))))


(defun convertCont (tokenList)
    (cond ((and (stringp (first tokenList)) (equal (second tokenList) #\:))
          (list (append  (list (first tokenList)) (list (parseValue (cdr (cdr tokenList)))))))
          (T (list (parseValue tokenList)))))

(defun parseValue (tokenList)
    (cond  ((= (list-length tokenList) 1)
            (cond ((stringp (first tokenList)) (first tokenList))
                  ((numberp (first tokenList)) (first tokenList))))
            ((or (equal (first tokenList) #\{) (equal (first tokenList) #\[)) (checkPar tokenList))
            ((equal (listToString tokenList) "true") 'true)
            ((equal (listToString tokenList) "false") 'false)
            ((equal (listToString tokenList) "null") 'null)
            (T (error "Not a valid value"))))

(defun jsonaccess (object &rest list)
    (let ((fields (flat list)))
    (cond ((null fields) (error "No specified fields"))
          ((eql (length fields) 1)
           (findValue object (car fields)))
           (T (jsonaccess (findValue object (first fields)) (rest fields))))))

(defun flat (L)
    (if (null L)
        NIL
        (if (atom (first L))
            (cons (first L) (flat (rest L)))
            (append (flat (first L)) (flat (rest L))))))

(defun findValue (object field)
    (cond ((and (equal (car object) 'JSONARRAY) (numberp field))
           (findArrayValue (rest object) field))
          ((and (equal (car object) 'JSONOBJ) (stringp field))
           (findObjectValue (rest object) field))
          (T (error "Not a valid field"))))

(defun findArrayValue (arraylist index)
    (cond ((eql index 0) (car arraylist))
          (T (findArrayValue (rest arraylist) (- index 1)))))

(defun findObjectValue (object field)
    (cond  ((null object) (error "field not present"))
           ((equal (first (first object)) field)
           (second (first  object)))
           (T (findObjectValue (rest object) field))))
