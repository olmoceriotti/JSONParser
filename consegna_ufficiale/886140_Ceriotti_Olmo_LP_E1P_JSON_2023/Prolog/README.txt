README
Partecipanti
Olmo Ceriotti 886140

----- Note importanti -----
1. Per inserire virgolette (") nelle stringhe utilizzare \\\".
2. I numeri scritti in notazione scientifica verranno convertiti ove possibile in float.
3. Nei predicati dove è possibile scrivere un filepath utilizzare forward slash (/) al posto dei backslash (\).
4. Per utilizzare i caratteri di escape (ad esempio \n) è necessario scrivere un backslash (\) in più (ad esempio "\\n").

La spiegazione a queste note è presente nella sezione Utilizzo

----- Introduzione -----
Lo sviluppo di applicazioni web su Internet, ma non solo, richiede di scambiare dati fra applicazioni eterogenee, 
ad esempio tra un client web scritto in Javascript e un server, e viceversa.
Uno standard per lo scambio di dati molto diffuso è lo standard JavaScript Object Notation, o JSON. Lo scopo di questo progetto è di realizzare due librerie, una in Prolog e l’altra in Common Lisp, 
che costruiscano delle strutture dati che rappresentino degli oggetti JSON a partire dalla loro rappresentazione come stringhe.

----- Utilizzo -------
I predicati scritti rispettano i requisiti espressi nella consegna. Hanno infatti la seguente arità:
JSONPARSE/2,
JSONACCESS/3,
JSONREAD/2,
JSONDUMP/2.

Il predicato JSONPARSE ha il seguente significato: il primo argomento, che può essere un atomo, una stringa o una variabile, è l'oggetto JSON scritto nella sintassi tradizionale. Il secondo argomento, che può essere una variabile o il termine parzialmente o totalmente istanziato, è l'oggetto JSON espresso nella sintassi richiesta dalla consegna.
Il predicato accetta come oggetto JSON classico qualsiasi oggetto scritto rispettando le regole espresse sul sito www.json.org, unico accorgimento riguarda l'utilizzo di virgolette all'interno della stringa: essendo scritta all'interno di un atomo e non di una stringa la seguente sintassi sembrerà corretta ma produrrà un errore nell'interprete Prolog: '{"stringa \" ": 1}'. Questo perchè una volta interrogato il programma, l'interprete trasformerà l'atomo in una stringa nel seguente modo: "{\"stringa \" \": 1}'.
E' evidente quindi che per correggere questo problema insito nel compilatore la via migliore si quella di effettuare le proprie query scrivendo \\\" al posto di \" quando si vuole scrivere delle virgolette all'interno di una stringa.
L'altro accorgimento riguarda i numeri scritti in notazione scientifica. Essi verranno letti e parsati adeguatamente dal programma ma, dove possibile, verranno riportati nell'oggetto JSON come float. Nel momento in cui l'oggetto JSON tradizionale non fosse scritto rispettando la sintassi corretta il predicato produrrà un syntax error o fallirà.

Il predicato JSONACCESS ha il seguente significato: il primo argomento rappresenta l'oggetto JSON nella sintassi richiesta, il secondo i campi di ricerca, che possono essere una singola stringa, liste di un solo elemento contenenti un numero o un stringa, liste di più elementi contenenti più di un numero o una stringa. Non vi sono particolari accorgimenti rigurdanti questo predicato.

Il predicato JSONREAD si comporta nel seguente modo: il primo argomento è il nome o percorso, relativo o assoluto, del file che si vuole leggere mentre il secondo è l'oggetto JSON presente nel file convertito. Per evitare problemi è indicato usare i forward slash nella scrittura di un eventuale percorso al posto dei backslash. Nel caso il nome del file non corrisponda a nessun file esistente nel percorso richiesto il predicato fallisce.

Il predicato JSONDUMP si comporta nel seguente modo: Il primo argomento è l'oggetto JSON in formato "Prolog" mentre il secondo è il nome del file su quale si andrà a scrivere l'oggetto in formato tradizionale. Come per il JSONREAD è opportuno scrivere il percorso utilizzando i forward slash al posto dei backslash. L'oggetto in sintassi tradizionale non sarà ovviamente indentato.

----- Predicati Ausiliari -----
PROP_TO_LIST: questo predicato serve per convertire la sotto-stringa contenuta tra le parentesi graffe della stringa oggetto del JSONPARSE nel formato richiesto.
ELEMENT_TO_LIST: questo predicato converte la sotto-stringa contenuta tra le parentesi quadre della stringa rappresentante un array da convertire.
ISOBJECT: predicato che controlla se il funtore del termine derivato dalla stringa iniziale è {}. Verifica quindi che il termine sia un oggetto.
ISARRAY: predicato che controlla che il funtore del termine derivato dalla stringa iniziale è []. Verifica quindi che il termine sia un oggetto.
ISVALUE: predicato "cuore" del JSONPARSE, controlla che i campi VALUE inseriti siano validi e, nel caso di un array o un oggetto, richiama JSONPARSE sul valore.
FINDFIELD: questo predicato scorre la lista alla ricerca del campo indicato nel JSONACCESS. Alternativamente scorre la lista fino a che l'indice inserito non sia 0.
STRINGIFY: questo predicato si occupa della conversione da oggetto Prolog a stringa JSON.
ELEMENTS_STRINGS: questo predicato scorre la lista di proprietà all'interno del corpo dell'oggetto Prolog e la converte in stringa
ARRAY_ELEMENTS_STRINGS: questo predicato scorre la lista di proprietà all'interno del corpo dell'array Prolog e la converte in stringa.

----- Note -----
Al termine del programma è presente una query per fare in modo che in ogni caso e sistema operativo venga visualizzato il risultato completo delle query vista la tendenza su Mac ad abbreviare le query troppo lunghe.

