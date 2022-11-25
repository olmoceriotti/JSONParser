%%% Casi base
jsonparse([], jsonarray([])):- !.
jsonparse({}, jsonobj([])) :- !.

%%% Seconda chiamata
jsonparse(String, jsonobj(Parsed)) :-
    string(String), % Riconosco stringa per evitare conflitti
    term_string(Term, String), % converto stringa in termine
    isObject(Term), % controllo che sia un oggetto JSON
    Term =.. [_, Properties], % rimuovo funtore '{}' dell'oggetto JSON e ottengo il resto degli argomenti (1)
    prop_to_list(Properties, Parsed), % converto le proprietà in una lista di termini di arietà 2
    !. % inserisco il cut perchè backtracking stupido

%%% Prima chiamata
jsonparse(Atom, Parsed) :-
    atom(Atom), % Oggeto sempre passato come atomo
    atom_string(Atom, String), % Atomo convertito in stringa
    jsonparse(String, Parsed). % Passo string al parse

%%% Da compound proprietà a lista
%%% Caso base (una singola proprietà)
prop_to_list(Properties, Parsed) :-
    functor(Properties, :, 2), % controllo che ci sia una singola proprietà
    arg(1, Properties, PropName), % ottengo il primo argomento (nome della proprietà)
    string(PropName), % controllo che sia una stringa
    arg(2, Properties, PropValue), % prendo il secondo argomento
    isValue(PropValue, ParsedValue), % controllo che sia un valore
    Parsed = [(PropName, ParsedValue)]. % restituisco coppia di nome più valore
%%% Passo ricorsivo (approcio divide et impera)
prop_to_list(Properties, Parsed) :-
    functor(Properties, ',' , 2), % controllo che siano presenti più di una proprietà
    arg(1, Properties, Prop1), % prendo prima proprietà
    prop_to_list(Prop1, Parse1), % trasformo prima proprietà in una lista con un singolo argomento (PropName, PropValue)
    arg(2, Properties, Prop2), % prendo il resto delle proprietà
    prop_to_list(Prop2, Parse2), % eseguo chiamata ricorsiva che non si ferma finchè non c'è una sola proprietà e ottengo lista di proprietà   
    append(Parse1, Parse2, Parsed). % attacco la prima proprietà con il resto delle proprietà



%% Object recognition
isObject(Object) :-
    Object =.. [{}| _]. % Se il funtore è {} allora è un oggetto
%% Value recognition
isValue(String, String) :-
    string(String),
    !.
isValue(Number, Number) :-
    number(Number),
    !.
isValue(Object, ParsedObject) :-
    isObject(Object), % è un oggetto
    term_string(Object, String), % converto oggetto in stringa perchè è un compund e quindi non verrebbe accettato come atomo
    jsonparse(String, ParsedObject). % Passo ricorsivo, effettuo parse e ritorno oggetto parsato
isValue([], []).
isValue(true, true).
isValue(false, false).
isValue(null, null).



%% String test: '{"ciao": "value"}'
%% String test 2: '{"ciao": "value", "ciao2": "value", "ciao3": {"ciao4" : "value"}}'
