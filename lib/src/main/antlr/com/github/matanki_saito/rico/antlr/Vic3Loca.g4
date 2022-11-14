grammar Vic3Loca;
@header {
    package com.github.matanki_saito.rico.antlr;
}

D: '$';
BRANKET_START: '[';
BRANKET_END: ']';
R_BRANKET_START: '(';
R_BRANKET_END: ')';

DASH: '\'';
COMMA: ',';

TAG_START: '#' ;
EXC: '!';
ATT: '@';

PIPE: '|';
EQ: '=';
PLUS: '+';
MINUS: '-';
PERCENT: '%';
CORON: ':';
SEMICORON: ';';
ASTER: '*';
HATENA: '?';

LINEBREAK: '\\n';
ESCAPED_DOWBLE_QUOTE: '\\"';

NUMBER: [0-9];
DOT: '.';
SPACE: ' '|' ';
UNDERSCORE: '_';
ALPHABET: [a-zA-Z];
JAPANESE: [ぁ-んァ-ヶｱ-ﾝﾞﾟ一-龠（）、「」【】・。：；ー！？]+;

root: section* EOF;

section
:variable
|icon
|shell
|tag
|tooltippable_tag_1
|tooltip_tag_1
|tooltip_tag_2
|tooltip_tag_3
|text;

text
: NUMBER+
| ALPHABET+
| JAPANESE+
| D
| BRANKET_START
| BRANKET_END
| DOT
| SPACE
| UNDERSCORE
| PLUS
| MINUS
| EXC
| ATT
| PIPE
| PERCENT
| R_BRANKET_START
| R_BRANKET_END
| COMMA
| CORON
| LINEBREAK
| TAG_START
| ASTER
| SEMICORON
| ESCAPED_DOWBLE_QUOTE
| HATENA;

format: NUMBER|ALPHABET|EQ|PLUS|MINUS|PERCENT|ASTER;
id: (ALPHABET|UNDERSCORE)+;
arguments: (SPACE* (scope|wtext) SPACE* COMMA? SPACE*)*;
function: id R_BRANKET_START arguments R_BRANKET_END;
variable: D id (PIPE format+)? D;
scope: (id|function) (DOT (id|function))* ;
shell_target: scope;
shell: BRANKET_START SPACE* shell_target (PIPE format+)? SPACE* BRANKET_END;
tooltippable_tag_1: '#tooltippable;' id SEMICORON id CORON id SPACE section* TAG_START EXC;
tooltip_target_tag: (id|variable|shell);
tooltip_tag_1: '#tooltip:' (tooltip_target_tag PIPE?)+ SPACE section* TAG_START EXC;
tooltip_tag_2: '#tooltip:' (tooltip_target_tag PIPE?)+ SPACE* COMMA SPACE* id SPACE section* TAG_START EXC;
tooltip_tag_3: '#tooltip:' (tooltip_target_tag PIPE?)+ SPACE* COMMA SPACE* id SPACE* COMMA SPACE* id SPACE section* TAG_START EXC;
tag: TAG_START id SPACE section* TAG_START EXC;
icon: ATT id EXC;
wtext: DASH section* DASH;