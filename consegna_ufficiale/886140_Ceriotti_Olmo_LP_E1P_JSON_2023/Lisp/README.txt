README
Partecipanti
Olmo Ceriotti 886140

----- Note importanti -----
1. Utilzzando il JSONPARSE, per inserire le virgolette nelle stringhe è necessario usare \\\".
2. Utilzzando il JSONREAD, le virgolette possono essere inserite liberamente nelle stringhe.
3. Lo stesso vale per i caratteri di escape, per scrivere un Newline sarà necessario scrivere "\\n" usando il JSONPARSE e  "\n" usando il JSONREAD.
4. Nelle funzioni dove è possibile scrivere un filepath utilizzare forward slash (/) al posto dei backslash (\)

----- Introduzione -----
Lo sviluppo di applicazioni web su Internet, ma non solo, richiede di scambiare dati fra applicazioni eterogenee, 
ad esempio tra un client web scritto in Javascript e un server, e viceversa.
Uno standard per lo scambio di dati molto diffuso è lo standard JavaScript Object Notation, o JSON. Lo scopo di questo progetto è di realizzare due librerie, una in Prolog e l’altra in Common Lisp, 
che costruiscano delle strutture dati che rappresentino degli oggetti JSON a partire dalla loro rappresentazione come stringhe.

----- Utilizzo -----
Le funzioni scritte rispettano i requisiti espressi dalla consegna. Hanno le seguenti caratteristiche:
JSONPARSE: Stringa ---->  Cons cell
JSONACCESS: Cons cell, lista ----> numero, stringa, boolean o cons cell
JSONREAD: Stringa (Filepath) ----> Cons cell
JSONDUMP: Cons cell, filename ----> Stringa (Filepath) (effetto collaterale: scrittura su file)

----- Funzioni Ausiliarie -----
CHARLIST:  questa funzione si occupa di convertire una stringa in una lista di caratteri
REFORMATSTRING: questa funzione si serve delle seguenti tre funzioni per tokenizzare la stringa in input.
NORMALIZEWHITESPACE: rimuove i caratteri "whitespace" per permettere il parsing
NORMALIZESTRING: ricerca le stringhe  all'interno della stringa e le compatta
NORMALIZENUMBERS: ricerca i numeri all'interno della stringa e li compatta
SUBSTITUTEESCAPE: sostituisce i caratteri di escape con il carattere lisp corrispondente
JSONROUTE: si occupa di indirizzare il parsing verso il percorso per  array o per oggetti a seconda della stringa passata
FINDPROPS: questa funzione ricerca proprietà e valori nella lista di token.
EVALPAIR: valuta e parsa le proprietà.
ISVALUE: controlla che i campi valore siano validi e nel caso siano oggetti o array richiama JSONPARSE
COMPACT: metodo utilizzato per concatenare stringhe
NOLAST: equivalente a BUTLAST
DELETECHAR: rimuove le istanze di un particolare carattere in una lista
JSONHELPER: svolge il lavoro del JSONACCESS con la lista di argometni ridotta ad una lista di primo livello.
FINDPROP: trova il valore richiesto inserendo il nome della proprietà.
FINDVALUE: trova il valore richiesto inserendo l'indice.
FLATTEN: appiattisce la una lista a più livelli in una lista a livello singolo.
JSONCONVERT: converte l'oggetto JSON Lisp in stringa
REDUCEOBJ: metodo REDUCE riscritto per essere compatibile con la sintassi oggetto richiesta.
PAIRCONVERT: converte le proprietà in stringhe.
VALUECONVERT: converte i valori in stringhe
