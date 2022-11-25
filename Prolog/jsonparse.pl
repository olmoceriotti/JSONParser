%%% Casi base
jsonparse([], jsonarray([])):- !.
jsonparse({}, jsonobj([])) :- !.

%%% Seconda chiamata
jsonparse(String, Parsed) :-
    string(String), % Riconosco stringa per evitare conflitti
    term_string(Term, String), % converto stringa in termine
    isObject(Term), % controllo che sia un oggetto JSON
    Term =.. [_, Properties], % rimuovo funtore '{}' dell'oggetto JSON e ottengo il resto degli argomenti (1)
    prop_to_list(Properties, Parsed). % converto le proprietà in una lista di termini di arietà 2
    !. % inserisco il cut perchè backtracking stupido

%%% Prima chiamata
jsonparse(Atom, Parsed) :-
    atom(Atom), % Oggeto sempre passato come atomo
    atom_string(Atom, String), % Atomo convertito in stringa
    jsonparse(String, Parsed). % Passo string al parse

%%% TODO
prop_to_list(Properties, Parsed) :-
    arg(1, X, Y),
    




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
