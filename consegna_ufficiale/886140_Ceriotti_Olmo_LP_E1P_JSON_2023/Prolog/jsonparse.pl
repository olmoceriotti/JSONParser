%%% Partecipanti
%% Olmo Ceriotti 886140

%%% JSONPARSE

jsonparse('[]', jsonarray([])) :- !.
jsonparse({}, jsonobj([])) :- !.

jsonparse(String, jsonobj(Parsed)) :-
    string(String),
    normalize_space(string(Normalized_String), String),
    catch(term_string(Term, Normalized_String), _, false),
    isObject(Term),
    Term =.. [_, Properties],
    catch(prop_to_list(Properties, Parsed), _, false),
    !.
jsonparse(ArrayString, Parsed) :-
    string(ArrayString),
    normalize_space(string(Normalized_String), ArrayString),
    catch(term_string(Term, Normalized_String), _, false),
    isArray(Term),
    catch(isValue(Term, Parsed), _, false),
    !.
jsonparse(Atom, Parsed) :-
    atom(Atom),
    !,
    atom_string(Atom, String),
    catch(jsonparse(String, Parsed), _, false).
jsonparse(X, Parsed) :-
    var(X),
    stringify(Parsed, X).

prop_to_list(Properties, Parsed) :-
    functor(Properties, :, 2),
    arg(1, Properties, PropName),
    string(PropName),
    arg(2, Properties, PropValue),
    isValue(PropValue, ParsedValue),
    Parsed = [(PropName, ParsedValue)].
prop_to_list(Properties, Parsed) :-
    functor(Properties, ',', 2),
    arg(1, Properties, Prop1),
    prop_to_list(Prop1, Parse1),
    arg(2, Properties, Prop2),
    prop_to_list(Prop2, Parse2),
    append(Parse1, Parse2, Parsed).

element_to_list(Element, Parsed) :-
    Element =.. ['[|]', Value, []],
    isValue(Value, ParsedValue),
    Parsed = [ParsedValue].
element_to_list(Elements, Parsed) :-
    Elements =.. ['[|]', Value, Values],
    element_to_list(Values, ParsedValues),
    isValue(Value, ParsedValue),
    append([ParsedValue], ParsedValues, Parsed).

isObject(Object) :-
    Object =.. [{} | _].
isArray(Array) :-
    Array =.. ['[|]' | _].

isValue(String, ParsedString) :-
    string(String),
    string_concat("\"", String, Par1),
    string_concat(Par1, "\"", ParsedString),
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
    SearchFields = [Field],
    findField(ObjectFields, Field, Result),
    !.
jsonaccess(jsonobj(ObjectFields), [Field | OtherFields], Result) :-
    findField(ObjectFields, Field, Result1),
    jsonaccess(Result1, OtherFields, Result),
    !.
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

findField([(Field, Value) | _], Field, Value) :-
    string(Field),
    !.
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
    catch(open(FileName, read, Stream), _, false),
    catch(read_string(Stream, _, Stringa), _, false),
    jsonparse(Stringa, JSON),
    close(Stream).

%%% JSONDUMP

jsondump(JSONObj, FileName):-
    catch(stringify(JSONObj, JSONString), _, false),
    open(FileName, write, Stream, [create([all])]),
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
stringify(String, String) :-
    string(String),
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

%%% Query per visualizzare sempre l'output completo
:- set_prolog_flag(answer_write_options, [max_depth(0)]).
