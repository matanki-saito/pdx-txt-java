grammar Vic3Loca;
@header {
    package com.github.matanki_saito.rico.antlr;
}

DOLLER: '$';
BRANKET_START: '[';
BRANKET_END: ']';
R_BRANKET_START: '(';
R_BRANKET_END: ')';
DASH: '\'';
ESCAPED_DASH: '\\\'';
COMMA: ',';
SHARP: '#' ;
ESCAPED_SHARP: '##';
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
AND: '&';
LINEBREAK: '\\n';
DOWBLE_QUOTE: '"';
SLASH: '/';
DOT: '.';
SPACE: ' '|' ';
UNDERSCORE: '_';
SECSIGN: '§';
SECSIGNEND: '§W' | '§!';
LIBRA: '£';

NUMBER: [0-9];
ALPHABET: [a-zA-ZÖ];
LATIN_SIGH:[•~><£];
JAPANESE: [ぁ-んァ-ヶｱ-ﾝﾞﾟ一-龠（）、「」【】・。：；！？々～…×　＝ー―ｰ—－０-９]+;
ZWSP: '​';
FSP: ' ';

root:sections EOF;

sections: section*;

section
:variable
|icon
|icon2
|shell
|tag
|tooltippable_tag_1
|tooltippable_tag_2
|tooltip_tag_1
|tooltip_tag_2
|tooltip_tag_3
|segment
|text;

text
: NUMBER+
| ALPHABET+
| JAPANESE+
| ZWSP
| FSP
| AND
| DOLLER
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
| ASTER
| SEMICORON
| ESCAPED_SHARP
| HATENA
| SLASH
| ESCAPED_DASH
| LATIN_SIGH
| EQ
| DOWBLE_QUOTE;

format: NUMBER|ALPHABET|EQ|PLUS|MINUS|PERCENT|ASTER;
id: (ALPHABET|NUMBER|UNDERSCORE|MINUS)+;
argument_d: scope|wtext;
arguments_second: COMMA SPACE* argument_d;
arguments: argument_d arguments_second*;
function: id R_BRANKET_START SPACE* arguments? SPACE* R_BRANKET_END;
variable_format: PIPE format+;
variable: DOLLER id variable_format? DOLLER;
scope_d: id|function;
scope_second: DOT scope_d;
scope: scope_d scope_second* ;
shell_target: (scope|variable);
shell: BRANKET_START SPACE* shell_target variable_format? SPACE* BRANKET_END;
tagend: SHARP EXC;
segment: SECSIGN ALPHABET sections SECSIGNEND;
tooltippable_tag_1: '#tooltippable;' id SEMICORON id CORON id SPACE sections tagend;
tooltippable_tag_2: '#tooltippable;' id CORON id SPACE sections tagend;
tooltip_target_tag: (id|variable|shell);
tooltip_tag_1: '#tooltip:' (tooltip_target_tag PIPE?)+ SPACE sections tagend;
tooltip_tag_2: '#tooltip:' (tooltip_target_tag PIPE?)+ SPACE* COMMA SPACE* tooltip_target_tag SPACE sections tagend;
tooltip_tag_3: '#tooltip:' (tooltip_target_tag PIPE?)+ SPACE* COMMA SPACE* tooltip_target_tag SPACE* COMMA SPACE* id SPACE sections tagend;
tag: SHARP id (CORON NUMBER)? SPACE sections tagend;
icon: ATT section;
icon2: LIBRA ALPHABET* (LIBRA|SPACE);
wtext: DASH sections DASH;
