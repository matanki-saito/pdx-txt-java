grammar Pdx2;
@header {
    package com.github.matanki_saito.rico.antlr;
}

COMMENT: '#' ~('\n'|'\r')* ('\r\n' | '\r' | '\n' | EOF) -> skip;

SPACE: (' '|'\t'|'\r'|'\n'|'\r\n') -> skip;

WRAP_STRING: '"' CHAR* '"'; // "ABC" "" "\n" "ABC\nCBA" "cat and dog"
fragment CHAR: ~[\u{22}\u{5C}\u{0}-\u{1F}] | '\\' [bfnrt];

FLOAT: '-'? [0-9]+ '.' [0-9]+; // ex) 1.0, 0.1, 95.21, -2.52, 0.0
MINT: '-' [1-9] [0-9]*; // ex) -1 -2
INT: '0' | ([1-9] [0-9]*); // ex) 0, 2, 100

TAG: [A-Z] [A-Z] [A-Z];

DATE_TIME : INT '.' INT '.' INT;

ROOT: 'ROOT' | 'root';

AREA_X: [a-z_]+ '_area';

BOOL: 'yes'|'no';

BASE: [a-zA-Z_.@\-’:\\'\u{C0}-\u{FF}\u{153}\u{161}\u{178}\u{160}\u{152}\u{17D}\u{17E}0-9]+; // À-ÿœšŸŠŒŽž

root
: pair* EOF;

pair
: 'icon' '=' key
| 'required_missions' '=' '{' key* '}'
| 'potential' '=' '{' c_c_pair* '}'
| 'potential_on_load' '=' '{' c_c_pair* '}'
| 'trigger' '=' '{' pair* '}'
| 'effect' '=' '{' pair* '}'
| 'tooltip' '=' '{' pair* '}'
| 'add_country_modifier' '=' '{''name' '=' key 'duration' '=' (INT|MINT) '}'
| 'add_accepted_culture' '=' key
| 'set_government_rank' '=' INT
| s_pair
| if_pair
| c_c_pair
| key ('='|'<'|'>'|'<='|'>=') (primitive|('{' pair* '}'))
| primitive;

// to area|province
s_pair
: AREA_X '=' '{' a_pair* '}'
| INT '=' '{' p_pair* '}'
| 'capital_scope' '=' '{' p_pair* '}'
| 'random_owned_province' '=' '{' limit? p_pair* '}'
| 'every_province' '=' '{' limit? p_pair* '}'
| 'provinces_to_highlight' '=' '{' c_p_pair* '}'
| 'any_owned_province' '=' '{' p_pair* '}';

// country
c_c_pair
: INT '=' '{' p_pair* '}'
| 'owns_core_province' '=' INT
| 'capital_scope' '=' '{' c_p_pair* '}'
| 'any_province' '=' '{' c_p_pair* '}'
| 'AND' '=' '{' c_c_pair* '}'
| 'NOT' '=' '{' c_c_pair* '}'
| 'OR' '=' '{' c_c_pair* '}'
| 'map_setup' '=' key
| 'tag' '=' key
| 'government_rank' '=' INT
| 'is_at_war' '=' BOOL
| 'accepted_culture' '=' key
| 'num_of_cities' '=' INT
| 'has_dlc' '=' WRAP_STRING
| 'adm_tech' '=' INT
| 'religion' '=' ROOT
| 'hre_size' '=' INT
| 'hre_religion_treaty' '=' BOOL
| 'hre_religion_locked' '=' BOOL
| 'emperor' '=' '{' c_c_pair* '}'
| 'primary_culture' '=' key
| 'num_of_owned_provinces_with' '=' '{' c_p_pair* 'value' '=' INT c_p_pair* '}'
| 'num_of_provinces_owned_or_owned_by_non_sovereign_subjects_with' '=' '{' c_p_pair* 'value' '=' INT c_p_pair* '}'
| 'custom_trigger_tooltip' '=' '{' 'tooltip' '=' key c_c_pair* '}'
| 'culture' '=' key
| c_c_if_pair;

// provinc
p_pair
: 'add_permanent_claim' '=' ROOT
| 'add_base_production' '=' INT
| 'add_base_manpower' '=' INT
| 'add_base_tax' '=' INT
| 'area' '=' '{' ('limit' '=' '{' c_a_pair* '}')? a_pair+ '}'
| 'change_culture' '=' ROOT
| 'change_religion' '=' ROOT
| 'add_province_modifier' '=' '{' 'name' '=' key 'duration' '=' INT '}'
| 'limit' '=' '{' c_p_pair* '}'
| c_p_pair;

c_p_pair
: 'culture' '=' key
| 'continent' '=' key
| 'area' '=' AREA_X
| ROOT '=' '{' c_c_pair* '}'
| 'OR' '=' '{' c_p_pair* '}'
| 'NOT' '=' '{' c_p_pair* '}'
| 'AND' '=' '{' c_p_pair* '}'
| 'is_claim' '=' ROOT
| 'owned_by' '=' (ROOT|TAG)
| 'province_id' '=' INT
| 'trade_share' '=' '{' 'country' '=' ROOT 'share' '=' INT '}'
| 'is_strongest_trade_power' '=' ROOT
| 'area_for_scope_province' '=' '{' c_a_pair* '}'
| 'is_core' '=' ROOT
| 'is_state_core' '=' ROOT
| 'is_capital_of' '=' ROOT
| 'country_or_non_sovereign_subject_holds' '=' ROOT
| 'has_building' '=' key
| 'num_free_building_slots' '=' INT;

// area
c_a_pair
: 'OR' '=' '{' c_a_pair* '}'
| 'NOT' '=' '{' c_a_pair* '}'
| 'AND' '=' '{' c_a_pair* '}'
| 'is_capital_of' '=' ROOT
| 'is_claim' '=' ROOT
| 'is_core' '=' ROOT
| 'is_permanent_claim' '=' ROOT
| 'type' '=' ('all'|'any')
| 'owned_by' '=' (ROOT|TAG)
| 'culture' '=' key;

a_pair
: 'add_permanent_claim' '=' ROOT
| 'every_neighbor_province' '=' '{' p_pair* '}'
| a_limit
| c_a_pair;

primitive
: DATE_TIME
| FLOAT
| MINT
| INT
| 'CAPITAL'
| BASE
| BOOL
| ROOT
| WRAP_STRING;

key: (WRAP_STRING|DATE_TIME|BASE);

if_pair: 'if' '=' '{' limit pair* '}' ('else_if' '=' '{' limit pair* '}')* ('else' '=' '{' pair* '}')?;
limit: 'limit' '=' '{' c_c_pair* '}';
a_limit: 'limit' '=' '{' c_a_pair* '}';
c_c_if_pair: 'if' '=' '{' limit c_c_pair* '}' ('else_if' '=' '{' limit c_c_pair* '}')* ('else' '=' '{' c_c_pair* '}')?;
