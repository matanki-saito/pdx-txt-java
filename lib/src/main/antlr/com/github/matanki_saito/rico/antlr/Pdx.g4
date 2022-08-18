grammar Pdx;
@header {
    package com.github.matanki_saito.rico.antlr;
}

COMMENT: '#' ~('\n'|'\r')* ('\r\n' | '\r' | '\n' | EOF) -> skip;

// space is ignored
SPACE: (' '|'\t'|'\r'|'\n'|'\r\n') -> skip;

// "ABC" "" "\n" "ABC\nCBA" "cat and dog"
WRAP_STRING: '"' CHAR* '"';

// ex) 1.0, 0.1, 95.21, -2.52, 0.0
FLOAT: '-'? [0-9]+ '.' [0-9]+;
// ex) -1 -2
MINT: '-' [1-9] [0-9]*;
// ex) 0, 2, 100
INT: '0' | ([1-9] [0-9]*);

DATE_TIME : INT '.' INT '.' INT;

FALSE: 'false';
TRUE: 'true';
NULL : 'null';
YES : 'yes';
NO : 'no';

PREV_PREV: 'PREV_PREV';
CAPITAL_A: 'CAPITAL';
FROM: 'FROM';
ROOT: 'ROOT' | 'root';
PREV: 'PREV' | 'prev';

// logic
OR : 'OR';
IF: 'if';
ELSE_IF: 'else_if';
ELSE: 'else';
CALC_TRUE_IF: 'calc_true_if';

OBJECT_OPERATION
:CHANCE
|'effect'
|'potential';

// int operation(0,1,2,...)
INT_OPERATION
:'amount'
|'government_rank'
|'total_development'
|'mil_tech'
|'slot'
|'owns'
|'is_year'
|'base_tax'
|'base_production'
|'base_manpower'
;

// mint and int operation(...,-2,-1,0,1,2,...)
MINT_INT_OPERATION
: 'add_adm_power'
| 'add_dip_power'
| 'add_mil_power'
| 'add_legitimacy'
| 'loyalty';

// number operation
GLOBAL_UNREST: 'global_unrest';
RECOVER_NAVY_MORALE_SPEED: 'recover_navy_morale_speed';
GLOBAL_MANPOWER_MODIFIER: 'global_manpower_modifier';
LAND_ATTRITION: 'land_attrition';
LEADER_LAND_SHOCK: 'leader_land_shock';
ADVISOR_POOL: 'advisor_pool';
MANPOWER_RECOVERY_SPEED: 'manpower_recovery_speed';
LAND_FORCELIMIT_MODIFIER: 'land_forcelimit_modifier';
NAVAL_FORCELIMIT_MODIFIER: 'naval_forcelimit_modifier';

BINARY_OPERATION
:'onmap'
|'is_capital'
|'is_female'
|'female'
|'has_port'
|'is_triggered_only'
|'has_country_shield'
|'generic'
|'ai'
|'hre'
|'normal_or_historical_nations'
|'is_city'
|'hidden'
|'always'
|'is_node_in_trade_company_region';

TAG_OPERATION
:'tag'
|'country_or_non_sovereign_subject_holds'
|'alliance_with';

STRING_OPERATION
: 'has_dlc';

KEY_OR_STRING_OPERATION
:'icon';

KEY_OPERATION
: 'has_building'
| 'estate'
| 'has_estate'
| 'desc'
| 'region'
| 'map_setup'
| 'has_reform'
| 'government'
| 'trade_goods'
| 'culture_group'
;

// other
PRESTIGE: 'prestige';
WAR_EXHAUSTION: 'war_exhaustion';
LUCK: 'luck';
MODIFIER: 'modifier';
CAPITAL: 'capital';
DYNASTY: 'dynasty';
CHANCE: 'chance';
FACTOR: 'factor';
POSITION: 'position';
ADD_CORE: 'add_core';
CONTROLLER: 'controller';
NAME: 'name';
CULTURE: 'culture';
PROVINCE_ID: 'province_id';

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
HTPHEN: '-';
AT_MARK: '@';
ALPHABETS: [a-zA-Z_.]+;
EUROPEAN_LANG_CHARS: [\u{C0}-\u{FF}\u{153}\u{161}\u{178}\u{160}\u{152}\u{17D}\u{17E}]; // À-ÿœšŸŠŒŽž

CHAR: ~[\u{22}\u{5C}\u{0}-\u{1F}]
    | '\\' [bfnrt];
EXP: [eE] ('-'|'+')? [0-9]+;
FRAC: '.' [0-9]+;

NOT: 'NOT' SPACE?;
AND: 'AND' SPACE?;

// state tag
AAA: ('A'..'Z') ('A'..'Z') ('A'..'Z') SPACE;

// parser
root
: elements+=element* EOF;

keyLevelString:
  ( AT_MARK
  | ALPHABETS
  | EUROPEAN_LANG_CHARS
  | INT
  | FRAC
  | Semicolon
  | HTPHEN
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
| CAPITAL_A
| (keyLevelString)
| tagC
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
: (WRAP_STRING|INT|DATE_TIME|keyLevelString|tagC);

element
: logicPair
| limitPair
| triggerPair
| toolTipPair
| chancePair
| factorPair
| intPair
| provincesToHighlightPair
| intAndMintPair
| numberPair
| add_estate_loyalty_modifierPair
| add_estate_loyaltyPair
| add_province_modifier
| coutnryTargetPair
| positionPair
| binaryPair
| modifierPair
| stringPair
| ifPair
| namePair
| keyOrNamePair
| keyPair
| dynastyPair
| colorPair
| capitalPair
| wrapedStringPair
| addCorePair
| controllerPair
| objectPair
| keyValue
| array
| primitive;

keyValue
: key nameSeparator value;

ifPair
: IF EQ array (ELSE_IF EQ array)* (ELSE EQ array)?;

logicPair
: (CALC_TRUE_IF
    |PRESTIGE
    |LUCK
    |WAR_EXHAUSTION
    |NOT
    |AND
    |OR
    |FROM
  ) EQ cArray;

objectPair
: OBJECT_OPERATION EQ array;

binaryPair
: (BINARY_OPERATION|LUCK) EQ (YES|NO);

intPair
: INT_OPERATION EQ INT;

intAndMintPair
: MINT_INT_OPERATION EQ (INT|MINT);

stringPair
: MODIFIER EQ keyLevelString;

keyPair
: KEY_OPERATION EQ (keyLevelString|array);

wrapedStringPair
: STRING_OPERATION EQ WRAP_STRING;

keyOrNamePair
: KEY_OR_STRING_OPERATION EQ (WRAP_STRING|keyLevelString);

tagPair
: TAG_OPERATION EQ tagC;

namePair
: NAME EQ (WRAP_STRING|keyLevelString|array);

capitalPair
: CAPITAL EQ (INT|WRAP_STRING|keyLevelString);

tagC
: AAA
| ROOT
| FROM
| PREV
| NOT
| AND;

dynastyPair
: DYNASTY EQ (WRAP_STRING|keyLevelString|ROOT);

chancePair
: CHANCE EQ BRACHET_START elements+=chancePairElement* BRACHET_END;

chancePairElement
: factorPair
| modifierPair;

modifierPair
: MODIFIER EQ array;

factorPair
: FACTOR EQ (FLOAT|INT|MINT);

positionPair
: POSITION EQ (INT|(BRACHET_START positionPairElement positionPairElement BRACHET_END));

positionPairElement
: 'x' EQ (INT|MINT)
| 'y' EQ (INT|MINT);

addCorePair
: ADD_CORE EQ (tagC|INT);

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

colorPair
: ('color'|'revolutionary_colors') EQ BRACHET_START INT INT INT BRACHET_END;

controllerPair
: CONTROLLER EQ (tagC|array);

culturePair
: CULTURE EQ (array|keyLevelString|ROOT);

conditionPair
: ('is_claim'
    |'is_core'
    |'is_rival'
    |'country_or_non_sovereign_subject_holds'
    |'is_permanent_claim'
    |'is_capital_of'
    |'is_state_core'
    |'has_discovered') EQ (ROOT|PREV)
| customTriggerTooltip
| 'development' EQ (INT|CAPITAL_A)
| 'owns_core_province'|'hre_size' EQ INT
| 'is_subject_other_than_tributary_trigger'|'is_city' EQ (YES|NO)
| ('adm'|'dip'|'mil'|'num_free_building_slots'|'mil_tech'|'num_of_colonists') EQ INT
| ('has_country_modifier'
    |'has_building'
    |'has_terrain'
    |'has_estate_privilege'
    |'has_reform'
    |'religion_group'
    |'area'
    |'continent'
    |'primary_culture'
    |'has_province_flag') EQ keyLevelString
| 'religion' EQ (keyLevelString|ROOT|PREV|FROM)
| 'type' EQ ('all'|'any')
| rootPair
| provinceIdPair
| tagPair
| ownedByPair
| provinceTargetPair
| logicPair
| culturePair
| num_of_owned_provinces_with
| keyLevelString EQ cArray
| customTriggerTooltip
;

array
: BRACHET_START elements+=element* BRACHET_END;

cArray
: BRACHET_START cElements+=conditionPair* BRACHET_END;

limitPair
: 'limit' EQ cArray;

triggerPair
: 'trigger' EQ (BRACHET_START ifPair BRACHET_END)|cArray;

provinceTargetPair
: (INT|FROM|'any_neighbor_province') EQ BRACHET_START (provinceMethod|tradeSharePair)* BRACHET_END;

provinceMethod
: 'is_strongest_trade_power' EQ ROOT;

tradeSharePair
: 'trade_share' EQ BRACHET_START 'country' EQ ROOT 'share' EQ INT BRACHET_END;

ownedByPair
: 'owned_by' EQ ROOT;

provincesToHighlightPair
: 'provinces_to_highlight' EQ cArray;

coutnryTargetPair
: ('owner'|'overlord'|'every_country'|'area') EQ array;

rootPair
: ROOT EQ array;

provinceIdPair
: PROVINCE_ID EQ (INT|PREV_PREV);

num_of_owned_provinces_with
: 'num_of_owned_provinces_with' EQ BRACHET_START conditionPair* 'value' EQ INT conditionPair* BRACHET_END;

customTriggerTooltip
: 'custom_trigger_tooltip' EQ BRACHET_START
 (('tooltip' EQ keyLevelString)|conditionPair)+
BRACHET_END;

toolTipPair
: 'tooltip' EQ BRACHET_START add_country_modifierPair BRACHET_END;

add_country_modifierPair
: 'add_country_modifier' EQ BRACHET_START namePair durationPair ('hidden' EQ YES|NO)? BRACHET_END;

add_estate_loyalty_modifierPair
: 'add_estate_loyalty_modifier' EQ BRACHET_START
    'estate' EQ keyLevelString
    'desc' EQ keyLevelString
    loyaltyPair
    durationPair
  BRACHET_END;

add_estate_loyaltyPair
: 'add_estate_loyalty' EQ BRACHET_START
    'estate' EQ keyLevelString
    loyaltyPair
  BRACHET_END;

add_province_modifier
: 'add_province_modifier' EQ BRACHET_START
    namePair
    durationPair
  BRACHET_END;

loyaltyPair
: 'loyalty' EQ (MINT|INT);

durationPair
: 'duration' EQ (INT|MINT);