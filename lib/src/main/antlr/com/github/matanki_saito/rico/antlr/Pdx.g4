grammar Pdx;
@header {
    package com.github.matanki_saito.rico.antlr;
}

// lexer
COMMENT: '#' ~('\n'|'\r')* ('\r\n' | '\r' | '\n' | EOF) -> skip;

// "ABC" "" "\n" "ABC\nCBA" "cat and dog"
WRAP_STRING: '"' CHAR* '"';

// space is ignored
SPACE: (' '|'\t'|'\r'|'\n'|'\r\n') -> skip;

// ex) 1.0, 0.1, 95.21, -2.52, 0.0
FLOAT: '-'? [0-9]+ DOT [0-9]+;
// ex) -1 -2
MINT: '-' [1-9] [0-9]*;
// ex) 0, 2, 100
INT: '0' | ([1-9] [0-9]*);

DATE_TIME : INT DOT INT DOT INT;

FALSE: 'false';
TRUE: 'true';
NULL : 'null';
YES : 'yes';
NO : 'no';

ROOT: 'ROOT' | 'root';
PREV: 'PREV';
TAG3 : [A-Z] [A-Z] [A-Z];

// logic
OR : 'OR';
NOT : 'NOT';
IF: 'if';
ELSE_IF: 'else_if';
ELSE: 'else';
CALC_TRUE_IF: 'calc_true_if';
TRIGGR: 'trigger';
LIMIT : 'limit';
CHANCE: 'chance';

// int operation
PRIVINCE_ID: 'province_id';
AMOUNT: 'amount';
FACTOR: 'factor';

// number operation
GLOBAL_UNREST: 'global_unrest';
DURATION: 'duration';
RECOVER_NAVY_MORALE_SPEED: 'recover_navy_morale_speed';
GLOBAL_MANPOWER_MODIFIER: 'global_manpower_modifier';
LAND_ATTRITION: 'land_attrition';
LEADER_LAND_SHOCK: 'leader_land_shock';
ADVISOR_POOL: 'advisor_pool';
MANPOWER_RECOVERY_SPEED: 'manpower_recovery_speed';
LAND_FORCELIMIT_MODIFIER: 'land_forcelimit_modifier';
NAVAL_FORCELIMIT_MODIFIER: 'naval_forcelimit_modifier';

// binary operation
ONMAP: 'onmap';
IS_CAPITAL: 'is_capital';
IS_FEMALE: 'is_female';
FEMALE: 'female';
HAS_PORT: 'has_port';
IS_TRIGGERD_ONLY: 'is_triggered_only';

// pointed operation
TAG: 'tag';

// string operation
HAS_DLC : 'has_dlc';

// logic or number operation
PRESTIGE: 'prestige';
WAR_EXHAUSTION: 'war_exhaustion';

// logic or binary operation
LUCK: 'luck';

// logic or string
MODIFIER: 'modifier';

BRACHET_START: '{';
BRACHET_END: '}';
EQ: '=';
LT: '<';
GT: '>';
LTE: '<=';
GTE: '>=';

Semicolon: ':';
Apostrophe: '’';
SINGLE_QUOTE: '\'';
UNDERSCORE: '_';
HTPHEN: '-';
DOT: '.';
AT_MARK: '@';
ALPHABETS: [a-zA-Z];
EUROPEAN_LANG_CHARS: [\u{C0}-\u{FF}\u{153}\u{161}\u{178}\u{160}\u{152}\u{17D}\u{17E}]; // À-ÿœšŸŠŒŽž

CHAR: ~[\u{22}\u{5C}\u{0}-\u{1F}]
    | '\\' [bfnrt];
EXP: [eE] ('-'|'+')? [0-9]+;
FRAC: DOT [0-9]+;

// parser
root
: elements+=element+ EOF;

keyLevelString:
  ( DOT
  | AT_MARK
  | ALPHABETS
  | EUROPEAN_LANG_CHARS
  | INT
  | Semicolon
  | HTPHEN
  | UNDERSCORE
  | Apostrophe
  | SINGLE_QUOTE)+;

primitive
: FALSE
| DATE_TIME
| TRUE
| NULL
| YES
| NO
| FLOAT
| MINT
| INT
| ROOT
| PREV
| TAG3
| keyLevelString
| WRAP_STRING;

nameSeparator
: LT
| LTE
| GT
| GTE
| EQ;

value
: element
| array;

// Key allows numbers
// example) 1000.0
// Key allows datetime
// example) 1024.20.1
// Key allows special characters
// example) abc.1
// example) bbb-6-czAÿ.10a_1''5
// Key allows wrap string
// example) "Ku-htihth #0"
key
: (WRAP_STRING|INT|DATE_TIME|keyLevelString|OR|NOT);

element
: logicPair
| chancePair
| intPair
| intAndMintPair
| numberPair
| factorPair
| binaryPair
| modifierPair
| stringPair
| ifPair
| tagPair
| wrapedStringPair
| keyValue
| array
| primitive;

keyValue
: key nameSeparator value;

ifPair
: IF EQ array (ELSE_IF EQ array)* (ELSE EQ array)? ;

logicPair
: (CALC_TRUE_IF
    |TRIGGR
    |LIMIT
    |PRESTIGE
    |LUCK
    |WAR_EXHAUSTION
  ) EQ array;

binaryPair
: (ONMAP
    |IS_CAPITAL
    |IS_FEMALE
    |FEMALE
    |HAS_PORT
    |IS_TRIGGERD_ONLY
    |LUCK
  ) EQ (YES|NO);

intPair
: (AMOUNT|PRIVINCE_ID|ADVISOR_POOL) EQ INT;

intAndMintPair
: (DURATION) EQ (INT|MINT);

stringPair
: MODIFIER EQ keyLevelString;

wrapedStringPair
: HAS_DLC EQ WRAP_STRING;

tagPair
: TAG EQ (ROOT|TAG3);

chancePair
: CHANCE EQ BRACHET_START elements+=chancePairElement* BRACHET_END;

chancePairElement
: factorPair
| modifierPair;

modifierPair
: MODIFIER EQ array;

factorPair
: FACTOR EQ (FLOAT|INT|MINT);

numberPair
: (RECOVER_NAVY_MORALE_SPEED
    |GLOBAL_UNREST
    |GLOBAL_MANPOWER_MODIFIER
    |LAND_ATTRITION
    |LEADER_LAND_SHOCK
    |PRESTIGE
    |WAR_EXHAUSTION
    |MANPOWER_RECOVERY_SPEED
    |LAND_FORCELIMIT_MODIFIER
    |NAVAL_FORCELIMIT_MODIFIER
  ) EQ (FLOAT|INT|MINT);

array
: BRACHET_START elements+=element* BRACHET_END;

