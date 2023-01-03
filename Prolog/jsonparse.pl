%%% AJSONPARSE


%%% Casi base
jsonparse('[]', jsonarray([])):- !.
jsonparse({}, jsonobj([])) :- !.

%%% Seconda chiamata oggetto
jsonparse(String, jsonobj(Parsed)) :-
    string(String),
    normalize_space(string(Normalized_String), String),
    term_string(Term, Normalized_String),
    isObject(Term),
    Term =.. [_, Properties],
    prop_to_list(Properties, Parsed), 
    !.
%%% Seconda chiamata array
jsonparse(ArrayString, Parsed) :-
    string(ArrayString),
    normalize_space(string(Normalized_String), ArrayString),
    term_string(Term, Normalized_String),
    isArray(Term),
    isValue(Term, Parsed),
    !.
%%% Prima chiamata
jsonparse(Atom, Parsed) :-
    atom(Atom),
    !,
    atom_string(Atom, String),
    jsonparse(String, Parsed).

jsonparse(X, Parsed) :-
    var(X),
    stringify(Parsed, X).
    

%%% Da compound proprietà a lista
%%% Caso base (una singola proprietà)
prop_to_list(Properties, Parsed) :-
    functor(Properties, :, 2),
    arg(1, Properties, PropName),
    string(PropName),
    arg(2, Properties, PropValue),
    isValue(PropValue, ParsedValue),
    Parsed = [(PropName, ParsedValue)].
%%% Passo ricorsivo (approcio divide et impera)
prop_to_list(Properties, Parsed) :-
    functor(Properties, ',' , 2),
    arg(1, Properties, Prop1),
    prop_to_list(Prop1, Parse1),
    arg(2, Properties, Prop2),
    prop_to_list(Prop2, Parse2),
    append(Parse1, Parse2, Parsed).

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
    Object =.. [{}| _].
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
    isObject(Object),
    term_string(Object, String),
    jsonparse(String, ParsedObject),
    !.
isValue(Array, jsonarray(ParsedArray)) :-
    isArray(Array),
    element_to_list(Array, ParsedArray),
    !.
isValue([], jsonarray([])).
isValue(true, true).
isValue(false, false).
isValue(null, null).


%%% JSONACCESS
jsonaccess(jsonobj(ObjectFields), SearchFields, Result) :-
    SearchFields = [Field], %CORREGGERE
    findField(ObjectFields, Field, Result),
    !.
%%% Caso passo, più campi
jsonaccess(jsonobj(ObjectFields), [Field | OtherFields], Result) :-
    findField(ObjectFields, Field, Result1),
    jsonaccess(Result1, OtherFields, Result),
    !.
%%%  Caso gestion stringa
jsonaccess(jsonobj(ObjectFields), StringField, Result) :-
    string(StringField),
    findField(ObjectFields, StringField, Result),
    !.
jsonaccess(jsonarray(Array), [Index], Result) :-
    number(Index),
    findField(Array, Index, Result),
    !. 
jsonaccess(jsonarray(Array), [Index | OtherFields], Result) :-
    number(Index),
    findField(Array, Index, Result1),
    jsonaccess(Result1, OtherFields, Result),
    !.
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
    N > 0,
    number(N),
    N1 is (N - 1),
    findField(OtherFields, N1, Result),
    !.



%%% JSONREAD

jsonread(FileName, JSON) :- 
    open(FileName, read, Stream),
    read_string(Stream, _, Stringa),
    jsonparse(Stringa, JSON),
    close(Stream).


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


%%% Query per visualizzare sempre l'output complet
:- set_prolog_flag(answer_write_options,[max_depth(0)]).
