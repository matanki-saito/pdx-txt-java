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
E: '=';
A: '{';
Z: '}';
ROOT: 'ROOT' | 'root' | 'prev';
REGION_X: [a-z_]+ '_region';
AREA_X: [a-z_]+ '_area';
BOOL: 'yes'|'no';
BASE: [a-zA-Z_.@\-’:\\'\u{C0}-\u{FF}\u{153}\u{161}\u{178}\u{160}\u{152}\u{17D}\u{17E}0-9]+; // À-ÿœšŸŠŒŽž

// ミッションルート
root: series* EOF;

// ミッションツリー
series: key E A (
//  表示列１～５
('slot' E INT)
// これを汎用ミッションにするかどうか
|('generic' E BOOL)
// AIがこのミッションを運用するかどうか
|('ai' E BOOL)
// このミッションを有効にするDLC所持条件
|('potential_on_load' E A ('has_dlc' E WRAP_STRING)* Z)
// このミッションを使う対象国の条件
|('potential' E A c_c_pair* Z)
// 紋章のアイコンがあるかどうか
|('has_country_shield' E BOOL)
)+
mission*
Z;

// ミッション
mission: key E A (
// アイコンgfx名
('icon' E key)
// 事前条件となるミッション
|('required_missions' E A key* Z)
// ハイライトするプロビンス（複数あり）
|('provinces_to_highlight' E A c_p_pair* Z)
// ミッションが完了とみなされる条件
|('trigger' E A c_c_pair* Z)
// ミッションが完了すると発動する効果
|('effect' E A c_pair* Z)
// 表示行
|('position' E INT)
)+
Z;

c_pair
: 'desc' E key
| 'potential' E A c_pair* Z
| 'tooltip' E A c_pair* Z
| 'custom_tooltip' E key
| 'hidden_effect' E A c_pair* Z
| 'country_event' E A 'id' E key Z
//////////////////////////////////////////////////////
// 国家補正を指定の期間有効にする。duration -1は永続
| 'add_country_modifier' E A'name' E key 'duration' E (INT|MINT) Z
// 対象の文化を需要文化とする
| 'add_accepted_culture' E key
// 統治点を加算
| 'add_adm_power' E INT
// 外交点を加算
| 'add_dip_power' E INT
// 軍事点を加算
| 'add_mil_power' E INT
// 国家ランクを指定のレベルにする
| 'set_government_rank' E INT
// 威信を加算
| 'add_prestige' E INT
// 安定度１上昇もしくは統治点を加算
| 'add_stability_or_adm_power' E BOOL
// 指定の階級の土地所有割合を指定の数値に変更する
| 'change_estate_land_share' E A'estate' E ('all'|'any') 'share' E (INT|MINT) ('province' E ROOT)? Z
| 'add_estate_loyalty_modifier' E A'estate' E key 'desc' E key 'loyalty' E INT 'duration' E (INT|MINT) Z
// 独立欲求を数値の数だけ増やす
| 'add_liberty_desire' E INT
// 対象の国家の属国を解放する
| 'free_vassal' E ROOT
// 対象を属国にする
| 'vassalize' E ROOT
// 正統性を加算する
| 'add_legitimacy' E INT
// 帝国派の影響を加算する
| 'add_imperial_influence' E INT
// 現在のスコープとすべての所有プロヴィンス (有効な場合) を帝国に配置する
| 'set_in_empire' E BOOL
// 戦力投射を加算する
| 'add_power_projection' E A 'type' E key 'amount' E INT Z
//////////////////////////////////////////////////
// エリアにスコープする　[OPTION] すべて もしくは いずれか１つ以上
| AREA_X E A ('limit' E A c_a_pair* Z)? a_pair* Z
// リージョンにスコープする　[OPTION] すべて もしくは いずれか１つ以上
| REGION_X E A ('limit' E A c_r_pair* Z)? r_pair* Z
// プロビンスにスコープする
| INT E A p_pair* Z
| (ROOT|TAG) E A c_pair* Z
// すべての属国にスコープする
| 'every_subject_country' E A c_limit c_pair* Z
// 首都にスコープする
| 'capital_scope' E A p_pair* Z
| 'random_owned_province' E A c_limit? p_pair* Z
| 'every_province' E A c_limit? p_pair* Z
| 'every_country' E A c_limit? c_pair* Z
| 'any_owned_province' E A p_pair* Z
| 'any_province' E A p_pair* Z
| 'every_owned_province' E A p_limit? p_pair* Z
////////////////////////////////////////////////////
| 'if' E A c_limit c_pair* Z ('else_if' E A c_limit c_pair* Z)* ('else' E A c_pair* Z)?
| 'AND' E A c_pair* Z
| 'NOT' E A c_pair* Z
| 'OR' E A c_pair* Z
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A c_pair* 'amount' E INT c_pair* Z
//| key (E|'<'|'>'|'<='|'>=') (primitive|(A c_pair* Z))
//| primitive
;

c_c_pair:
// localization ?
'desc' E key
// 条件に合えば指定のツールチップを表示する
| 'custom_trigger_tooltip' E A 'tooltip' E key c_c_pair* Z
/////////////////////////////////////////////////////
// 指定のプロビンスが中核州である
| 'owns_core_province' E INT
// 指定のプロビンスが自国もしくは属国によって保有されている
| 'owns_or_non_sovereign_subject_of' E INT
// 指定の国家と同盟しているかどうか
| 'alliance_with' E TAG
// 数値以上の連隊もしくは対象国以上の連隊を保有しているかどうか
| 'army_size' E (TAG|INT|ROOT)
// 統治技術が数値以上かどうか
| 'adm_tech' E INT
//指定の文化を受容しているかどうか
| 'accepted_culture' E key
// 主要な文化が指定のものかどうか
| 'primary_culture' E key
// 教皇の影響力が数値以上かどうか
| 'papal_influence' E INT
// 文化が指定のものかどうか
| 'culture' E key
// 国教が指定のものかどうかもしくは指定の国家と同じかどうか
| 'religion' E (ROOT|key)
// ランダム新世界機能を使っているかどうか
| 'map_setup' E key
// 指定の国家かどうか
| 'tag' E (key|TAG|ROOT)
// 国家ランクが指定以上かどうか
| 'government_rank' E INT
// 対象が現時点で存在しているかどうかもしくはスコープが存在しているかどうか
| 'exists' E (TAG|BOOL)
// 戦争中かどうか
| 'is_at_war' E BOOL
// 対象がライバルかどうか
| 'is_rival' E (ROOT|TAG)
| 'is_subject_of' E (TAG|ROOT)
// 指定の年代よりも後かどうか
| 'is_year' E INT
// 指定の国難が現在発生中かどうか
| 'has_disaster' E key
| 'num_of_cities' E INT
// 対象のDLCを保有しているかどうか
| 'has_dlc' E WRAP_STRING
| 'has_opinion_modifier' E A 'who' E ROOT 'modifier' E key Z
// 指定の国家フラグが存在するかどうか
| 'has_country_flag' E key
// 指定の対象国から指定の数以上の評価をもらっているかどうか
| 'has_opinion' E A 'who' E (ROOT|TAG) 'value' E INT Z
// 指定の階級が存在しているかどうか
| 'has_estate' E key
// 指定した階級の土地所有が指定以上であるかどうか
| 'estate_loyalty' E A'estate' E key 'loyalty' E INT Z
// HREの構成国が対象の数値以上かどうか
| 'hre_size' E INT
| 'hre_religion_treaty' E BOOL
| 'hre_religion_locked' E BOOL
// 自国が保有するプロビンスもしくは属国が保有するプロビンスが指定数以上かつ指定の条件かどうか
| 'num_of_provinces_owned_or_owned_by_non_sovereign_subjects_with' E A c_p_pair* 'value' E INT c_p_pair* Z
// 自国が保有するプロビンスが指定数以上かつ指定の条件かどうか
| 'num_of_owned_provinces_with' E A c_p_pair* 'value' E INT c_p_pair* Z
| 'total_own_and_non_tributary_subject_development' E (TAG|ROOT)
// 独立欲求が指定の数以上かどうか
| 'liberty_desire' E INT
// HRE皇帝かどうか
| 'is_emperor' E BOOL
// 帝国派の影響が指定値以上であるかどうか
| 'imperial_influence' E INT
// 階級の土地所有における王国シェアが指定％以上かどうか
| 'crown_land_share' E INT
// 威信が指定以上かどうか
| 'prestige' E INT
// 陸軍伝統が指定以上かどうか
| 'army_tradition' E INT
// 摂政評議会であるかどうか
| 'has_regency' E BOOL
// HREの構成国であるかどうか
| 'is_part_of_hre' E BOOL
// 選帝侯であるかどうか
| 'is_elector' E BOOL
// 対象国に対してHRE皇帝が好意的な評価をしているかどうか
| 'preferred_emperor' E ROOT
// 政体が指定のものであるかどうか
| 'government' E key
// 正統性が数値以上であるかどうか
| 'legitimacy' E INT
// 列強かどうか
| 'is_great_power' E BOOL
// 総計開発度が指定以上かどうか
| 'total_development' E INT
// 属国であるかどうか
| 'is_subject' E BOOL
// 統治者が指定のフラグを有しているかどうか
| 'has_ruler_flag' E key
// 独立国または朝貢国であるかどうか
| 'is_free_or_tributary_trigger' E BOOL
// 国の政府が遊牧民であるかどうか
| 'is_nomad' E BOOL
// ゲームが通常の国または歴史的な国を使用するように設定されているかどうか
| 'normal_or_historical_nations' E BOOL
// エンドゲームタグを一度も発火させていない
| 'was_never_end_game_tag_trigger' E BOOL
// AIであるかどうか
| 'ai' E BOOL
// カスタム国家であるかどうか
| 'is_playing_custom_nation' E BOOL
// 植民国家であるかどうか
| 'is_colonial_nation' E BOOL
// 独立した植民国家であるかどうか
| 'is_former_colonial_nation' E BOOL
///////////////////////////////////////////////////
// プロビンスにスコープにする
| INT E A c_p_pair* Z
// エリアにスコープにする
| AREA_X E A ('type' E ('all'|'any'))? c_a_pair* Z
// リージョンにスコープにする
| REGION_X E A ('type' E ('all'|'any'))? c_r_pair* Z
// 任意の属国にスコープする
| 'any_subject_country' E A c_c_pair* Z
// 対象国もしくは自国にスコープする
| (ROOT|TAG) E A c_c_pair* Z
// すべての国家にスコープする
| 'all_country' E A c_c_pair* Z
// 条件を満たす任意の国家にスコープする
| 'any_country' E A c_c_pair* Z
// 条件を満たすすべての国家にスコープする
| 'all_ally' E A c_c_pair* Z
// 条件を満たすいずれかの国家にスコープする
| 'any_ally' E A c_c_pair* Z
// 首都にスコープする
| 'capital_scope' E A c_p_pair* Z
// すべての選帝侯にスコープする
| 'all_elector' E A c_c_pair* Z
// HRE皇帝にスコープする
| 'emperor' E A c_c_pair* Z
// 帝国の危機が発生中かどうか
| 'active_imperial_incident' E ('any'|'all')
// 女性後継者であるかどうか
| 'has_female_heir' E BOOL
// 国家フラグが有効になってから指定の日数が経過したかどうか
| 'had_country_flag' E A 'flag' E key 'days' E INT Z
// 統治者が指定の人物であるかどうか
| 'has_ruler' E WRAP_STRING
// 後継者が存在するかどうか
| 'has_heir' E BOOL
// 対象のプロビンスを支配している
| 'controls' E INT
//////////////////////////////////////////////////
| 'if' E A c_limit c_c_pair* Z ('else_if' E A c_limit c_c_pair* Z)* ('else' E A c_c_pair* Z)?
| 'AND' E A c_c_pair* Z
| 'NOT' E A c_c_pair* Z
| 'OR' E A c_c_pair* Z
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A c_c_pair* 'amount' E INT c_c_pair* Z;

p_pair
// 指定の国家がこのプロビンスに永続請求権を得る
: 'add_permanent_claim' E ROOT
//指定の数値を製造開発度に追加する
| 'add_base_production' E INT
// 指定の数値を人的開発度に追加する
| 'add_base_manpower' E INT
// 指定の数値を税開発度に追加する
| 'add_base_tax' E INT
// 指定の州補正を指定の期間だけ与える。duration -1は永続
| 'add_province_modifier' E A 'name' E key 'duration' E (INT|MINT) Z
// 指定の交易補正を指定の期間だけ与える。duration -1は永続
| 'add_trade_modifier' E A 'who' E ROOT 'duration' E INT 'power' E INT 'key' E key Z
// 指定の文化に変更する
| 'change_culture' E ROOT
// 指定の宗教に変更する
| 'change_religion' E ROOT
// HREに追加する
| 'set_in_empire' E BOOL
////////////////////////////////////////////////
| ROOT E A c_pair* Z
| TAG E A c_pair* Z
| 'owner' E A c_pair* Z
| 'area' E A ('limit' E A c_a_pair* Z)? a_pair+ Z
| 'area_for_scope_province' E A a_pair* Z
////////////////////////////////////////////////
| 'if' E A p_limit p_pair* Z ('else_if' E A p_limit p_pair* Z)* ('else' E A p_pair* Z)?
| 'OR' E A p_pair* Z
| 'NOT' E A p_pair* Z
| 'AND' E A p_pair* Z
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A p_pair* 'amount' E INT p_pair* Z
;

c_p_pair
// 指定の文化であるかどうか
: 'culture' E key
| 'continent' E key
// 対象のリージョンであるかどうか
| 'region' E REGION_X
// 対象のエリアであるかどうか
| 'area' E AREA_X
| 'is_claim' E ROOT
// 対象の国家もしくは自国がこの州を保有しているかどうか
| 'owned_by' E (ROOT|TAG)
// 対象のプロビンスであるかどうか
| 'province_id' E INT
| 'trade_share' E A 'country' E ROOT 'share' E INT Z
// 指定の国家の交易力が最大であるかどうか
| 'is_strongest_trade_power' E ROOT
// 対象の国家にとって中核州であるかどうか
| 'is_core' E ROOT
| 'is_state_core' E ROOT
| 'is_capital_of' E ROOT
| 'is_capital' E BOOL
// 対象の国家が現存しているかどうか
| 'exists' E (TAG)
// 対象の国家もしくはその属国によって保有されているかどうか
| 'country_or_non_sovereign_subject_holds' E ROOT
// CoTがある場合にそのレベルが指定以上かどうか
| 'province_has_center_of_trade_of_level' E INT
// 指定の建物が建っているかどうか
| 'has_building' E key
| 'hre_size' E INT
// 建物の空きスロットが指定数以上かどうか
| 'num_free_building_slots' E INT
// 対象の国家によって支配されている
| 'controlled_by' E (ROOT|TAG)
// 指定の州補正が存在する
| 'has_province_modifier' E key
////////////////////////////////////////////////
// 対象国へスコープ変更
| (ROOT|TAG) E A c_c_pair* Z
| 'owner' E A c_c_pair* Z
////////////////////////////////////////////////
| 'OR' E A c_p_pair* Z
| 'NOT' E A c_p_pair* Z
| 'AND' E A c_p_pair* Z
| 'if' E A p_limit c_p_pair* Z ('else_if' E A p_limit c_p_pair* Z)* ('else' E A c_p_pair* Z)?
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A c_p_pair* 'amount' E INT c_p_pair* Z
;

a_pair
// 対象にこのエリアの永続請求権を与える
: 'add_permanent_claim' E ROOT
////////////////////////////////////////////////
// 隣接するすべてのプロビンスにスコープする
| 'every_neighbor_province' E A p_pair* Z;

c_a_pair:
'is_capital_of' E ROOT
| 'is_claim' E ROOT
// このエリアのすべてが対象の中核州かどうか
| 'is_core' E ROOT
// このエリアのすべてに対して対象の永続請求権があるかどうか
| 'is_permanent_claim' E ROOT
// 対象が保有しているかどうか
| 'owned_by' E (ROOT|TAG)
// 対象の文化かどうか
| 'culture' E key
// 対象の国家もしくはその属国によって保有されているかどうか
| 'country_or_non_sovereign_subject_holds' E ROOT
////////////////////////////////////////////////
| 'OR' E A c_a_pair* Z
| 'NOT' E A c_a_pair* Z
| 'AND' E A c_a_pair* Z
;

r_pair:
// 永続請求権を与える
'add_permanent_claim' E ROOT
// この地域のすべてのプロビンスに補正を与える
| 'add_province_modifier' E A 'name' E key 'duration' E (INT|MINT) Z;

c_r_pair
// 対象国によって保有されているかどうか
: 'owned_by' E (ROOT|TAG)
// 対象の国家がこのエリアに対して永続請求権を所有しているかどうか
| 'is_permanent_claim' E ROOT
// 対象の国家の中核州であるかどうか
| 'is_core' E ROOT
////////////////////////////////////////////////
| 'OR' E A c_r_pair* Z
| 'NOT' E A c_r_pair* Z
| 'AND' E A c_r_pair* Z;

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

c_limit: 'limit' E A c_c_pair* Z;
p_limit: 'limit' E A c_p_pair* Z;

