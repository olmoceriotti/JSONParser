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
    isValue(PropValue), % controllo che sia un valore
    Parsed = [(PropName, PropValue)]. % restituisco coppia di nome più valore

    




%% Object recognition
isObject(Object) :-
    Object =.. [{}| _].
%% Value recognition
isValue(String) :-
    string(String),
    !.
isValue(Number) :-
    number(Number),
    !.
isValue([]).
isValue(true).
isValue(false).
isValue(null).



%% String test: '{"ciao": "value"}'
