%%% JSONPARSE


%%% Casi base
jsonparse('[]', jsonarray([])):- !.
jsonparse({}, jsonobj([])) :- !.

%%% Seconda chiamata oggetto
jsonparse(String, jsonobj(Parsed)) :-
    string(String), % Riconosco stringa per evitare conflitti
    term_string(Term, String), % converto stringa in termine
    isObject(Term), % controllo che sia un oggetto JSON
    Term =.. [_, Properties], % rimuovo funtore '{}' dell'oggetto JSON e ottengo il resto degli argomenti (1)
    prop_to_list(Properties, Parsed), % converto le proprietà in una lista di termini di arietà 2
    !. % inserisco il cut perchè backtracking stupido
%%% Seconda chiamata array
jsonparse(ArrayString, Parsed) :-
    string(ArrayString),
    term_string(Term, ArrayString),
    isArray(Term),
    isValue(Term, Parsed),
    !.
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

%%% Da elementi array a lista
%%% Caso Base, un solo elemento nell'array
element_to_list(Element, Parsed) :-
    Element =.. ['[|]', Value, []],
    isValue(Value, ParsedValue),
    Parsed = [ParsedValue].
element_to_list(Elements, Parsed) :-
    Elements =.. ['[|]', Value, Values],
    element_to_list(Values, ParsedValues),
    isValue(Value, ParsedValue),
    append([ParsedValue], ParsedValues, Parsed).

%% Riconoscimento oggetti e array
isObject(Object) :-
    Object =.. [{}| _]. % Se il funtore è {} allora è un oggetto
isArray(Array) :-
    Array =.. ['[|]' | _].

%% Riconoscimento valori
isValue(String, String) :-
    string(String),
    !.
isValue(Number, Number) :-
    number(Number),
    !.
isValue(Object, ParsedObject) :-
    isObject(Object), % è un oggetto
    term_string(Object, String), % converto oggetto in stringa perchè è un compund e quindi non verrebbe accettato come atomo
    jsonparse(String, ParsedObject), % Passo ricorsivo, effettuo parse e ritorno oggetto parsato
    !.
isValue(Array, jsonarray(ParsedArray)) :-
    isArray(Array), % controllo array
    element_to_list(Array, ParsedArray), % converto array in lista di elementi parsati
    !.
isValue([], jsonarray([])).
isValue(true, true).
isValue(false, false).
isValue(null, null).



%% String test: '{"ciao": "value"}'
%% String test 2: '{"ciao": "value", "ciao2": "value", "ciao3": {"ciao4" : "value"}}'
%% String test 3: '{"oggetto": [1, 2, 3]}'

%%% JSONACCESS
%%% TODO
% Inserire controllo validità input, non deve dare risposta se l'oggetto è sbagliato (is not Value)
% Inserire cut
%%% Caso base su oggetto, un solo campo da cercare
jsonaccess(jsonobj(ObjectFields), SearchFields, Result) :-
    SearchFields = [Field],
    findField(ObjectFields, Field, Result). % Cerco singolo campo
%%% Caso passo, più campi
jsonaccess(jsonobj(ObjectFields), [Field | OtherFields], Result) :-
    findField(ObjectFields, Field, Result1), % Cerco primo capo
    jsonaccess(Result1, OtherFields, Result). % Effettuo ricerca sul risultato del campo
%%%  Caso gestion stringa
jsonaccess(jsonobj(ObjectFields), StringField, Result) :-
    string(StringField),
    findField(ObjectFields, StringField, Result).
jsonaccess(jsonarray(Array), [Index], Result) :-
    number(Index),
    findField(Array, Index, Result).
jsonaccess(jsonarray(Array), [Index | OtherFields], Result) :-
    number(Index),
    findField(Array, Index, Result1),
    jsonaccess(Result1, OtherFields, Result).
%%% Ricerca campi
%%% Caso base
findField([(Field, Value) | _], Field, Value) :-
    string(Field),
    !.
%%% Caso passo
findField([_ | OtherFields], Field, Value) :-
    string(Field),
    findField(OtherFields, Field, Value),
    !.
findField([Result | _], 0, Result).
findField([_ | OtherFields], N, Result) :-
    number(N),
    N1 is (N - 1),
    findField(OtherFields, N1, Result).



%%% JSONREAD

jsonread(FileName, JSON) :-
    open(FileName, read, Stream),
    read_string(Stream, _, Stringa),
    normalize_space(atom(FString), Stringa),
    jsonparse(FString, JSON).


%%% JSONDUMP

jsondump(JSONObj, FileName):-
    stringify(JSONObj, JSONString),
    open(FileName, write, Stream,[create([all])]),
    write(Stream, JSONString),
    close(Stream).


stringify(jsonobj([]), {}) :- !. 
stringify(jsonarray([]), []) :- !. 
stringify(jsonobj(Object), JSONString) :-
    elements_strings(Object, ObjectString),
    string_concat("{", ObjectString, Concat1),
    string_concat(Concat1, "}", JSONString),
    !.
stringify(jsonarray(Array), JSONString) :-
    array_elements_strings(Array, ArrayString),
    string_concat("[", ArrayString, Concat1),
    string_concat(Concat1, "]", JSONString),
    !.
stringify(String, JSONString) :-
    string(String),
    string_concat("\"", String, String1),
    string_concat(String1, "\"", JSONString),
    !.
stringify(Number, Number) :-
    number(Number), !.
stringify(true, true) :- !.
stringify(false, false) :- !.
stringify(null, null) :- ! .


elements_strings([(Field, Value)], JSONString) :-
    stringify(Field, JSONField),
    stringify(Value, JSONValue),
    string_concat(JSONField, ": ", Concat1),
    string_concat(Concat1, JSONValue, JSONString),
    !.
elements_strings([Property| OtherFields], JSONString) :-
    elements_strings([Property], Prop1),
    elements_strings(OtherFields, Props),
    string_concat(Prop1, ", ", Concat1),
    string_concat(Concat1, Props, JSONString),
    !.

array_elements_strings([Value], JSONString) :-
    stringify(Value, JSONString),
    !.
array_elements_strings([Value | Values], JSONString) :-
    stringify(Value, ValueString),
    array_elements_strings(Values, ValuesString),
    string_concat(ValueString, ", ", Concat1),
    string_concat(Concat1, ValuesString, JSONString),
    !.
    
