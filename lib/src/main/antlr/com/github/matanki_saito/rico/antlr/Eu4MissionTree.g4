grammar Eu4MissionTree;
@header {
    package com.github.matanki_saito.rico.antlr;
}

// ＊スコープについて
// 現在の処理対象のこと。これはスコープは１つではなく、ループを実現するために様々用意されている。
// 例えば下記のevery_provinceは現在の国家のすべてのプロビンスに対してという意味になる
//			every_province = {
//				limit = {
//					OR = {
//						province_id = 145
//						province_id = 146
//					}
//				}
//				add_permanent_claim = ROOT
//			}
// 上記は擬似コードだと下記のようになる
// var everyProvinces = MyCountry.getEveryPrivinces();
// var filterdProvinces;
// for(province: everyProvinces){
//     if(province.getProvinceId() == 145 or province.getProvinceId() == 146){
//         filterdProvinces.push(province)
//     }
// }
//
// for(province : filterdProvinces){
//     province.addPermanentClaimTo(ROOT);
// }
// チェーン式で書くと下記のようになる
// MyCountry.getEveryPrivinces()
//          .filter(x, { x.getProvinceId = 145 || x.getProvinceId = 146})
//          .map(x,{ x.addPermanentClaim(Root)})

COMMENT: '#' ~('\n'|'\r')* ('\r\n' | '\r' | '\n' | EOF) -> skip;
SPACE: (' '|'\t'|'\r'|'\n'|'\r\n') -> skip;
WRAP_STRING: '"' CHAR* '"'; // "ABC" "" "\n" "ABC\nCBA" "cat and dog"
fragment CHAR: ~[\u{22}\u{5C}\u{0}-\u{1F}] | '\\' [bfnrt];
MFLOAT: '-' [0-9]+ '.' [0-9]+;
FLOAT_0_1: '0.0' | '1.0' |'0.' [0-9]+;
FLOAT: [0-9]+ '.' [0-9]+;
MINT_3: '-3';
MINT_2: '-2';
MINT_1: '-1';
INT_0: '0';
INT_1: '1';
INT_2: '2';
INT_3: '3';
INT_4: '4';
INT_5: '5';
INT_6: '6';
MINT: '-' [1-9] [0-9]*;
INT: ([1-9] [0-9]*);
TAG: [A-Z] [A-Z] [A-Z];
DATE_TIME : INT '.' INT '.' INT;
E: '=';
A: '{';
Z: '}';
ROOT: 'ROOT' | 'root' | 'prev' | 'PREV' | 'this' | 'THIS' | 'FROM';
COLONIAL_X: 'colonial_' [a-z_]+;
BOOL: 'yes'|'no';
EVENT_TARGET: 'event_target:' [a-z_]+;
BASE: [a-zA-Z_.@\-’:\\'\u{C0}-\u{FF}\u{153}\u{161}\u{178}\u{160}\u{152}\u{17D}\u{17E}0-9]+; // À-ÿœšŸŠŒŽž

// ミッションルート
root: series* EOF;

// ミッションツリー
series: key E A (
//  表示列１～５
('slot' E (INT_1|INT_2|INT_3|INT_4|INT_5))
// これを汎用ミッションにするかどうか
|('generic' E BOOL)
// AIがこのミッションを運用するかどうか
|('ai' E BOOL)
// このミッションを有効にするDLC所持条件
|('potential_on_load' E A ('has_dlc' E dlcs)* Z)
// このミッションを使う対象国の条件
|('potential' E A country_trigger* Z)
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
|('provinces_to_highlight' E A province_trigger* Z)
// ミッションが完了とみなされる条件
|('trigger' E A country_trigger* Z)
// ミッションが完了すると発動する効果
|('effect' E A country_effect* Z)
// 表示行
|('position' E positive_integer)
// 指定の日付を超えたら自動で完了とみなす
|('completed_by' E DATE_TIME)
// AI重要度
|('ai_weight' E A 'factor' E percentage_range_0_inf ('modifier' E A 'factor' E percentage_range_0_inf country_trigger* Z)* Z)
// AI優先度
|('ai_priority' E A 'factor' E percentage_range_0_inf Z)
)+
Z;

country_effect
: 'desc' E key
| 'potential' E A country_effect* Z
| 'tooltip' E A country_effect* Z
| 'custom_tooltip' E key
| 'hidden_effect' E A country_effect* Z
// イベントを発生させる（daysがある場合はMTTH）
| 'country_event' E A 'id' E key ('days' E positive_integer)? Z
//////////////////////////////////////////////////////
// 現在のスコープの国名を指定のもの（locaにあるキー名）に変更する
| 'override_country_name' E key
// 対象国を歴史的友好国とする
| 'add_historical_friend' E ROOT
// 総主教の権威を追加する
| 'add_patriarch_authority' E percentage_range_0_inf
// グローバルフラグを追加する
| 'set_global_flag' E key
// 定義されたスコープの現在のスコープに対してcasus belliを追加します。
| 'reverse_add_casus_belli' E A 'target' E ROOT 'type' E cb_types 'months' E positive_integer Z
// 指定の国家から指定のCBを削除
| 'remove_casus_belli' E A 'type' E cb_types 'target' E TAG Z
// 国家補正を指定の期間有効にする。duration -1は永続
| 'add_country_modifier' E A'name' E key 'duration' E (positive_integer|MINT_1) Z
// 対象の文化を需要文化とする
| 'add_accepted_culture' E cultures
// 統治点を加算
| 'add_adm_power' E integer
// 外交点を加算
| 'add_dip_power' E integer
// 軍事点を加算
| 'add_mil_power' E integer
// 国家ランクを指定のレベルにする
| 'set_government_rank' E (INT_1|INT_2|INT_3)
// 威信を加算
| 'add_prestige' E integer
// 安定度１上昇もしくは統治点を加算
| 'add_stability_or_adm_power' E BOOL
// 安定度を上昇させる
| 'add_stability' E integer
// 指定の階級の土地所有割合を指定の数値に変更する
| 'change_estate_land_share' E A'estate' E ('all'|'any'|estates) 'share' E integer ('province' E ROOT)? Z
| 'add_estate_loyalty_modifier' E A'estate' E estates 'desc' E key 'loyalty' E integer 'duration' E (positive_integer|MINT_1) Z
// 独立欲求を数値の数だけ増やす
| 'add_liberty_desire' E integer
// 対象の国家の属国を解放する
| 'free_vassal' E ROOT
// 対象を属国にする
| 'vassalize' E ROOT
// 正統性を加算する
| 'add_legitimacy' E integer
// 帝国派の影響を加算する
| 'add_imperial_influence' E integer
// 現在のスコープとすべての所有プロヴィンス (有効な場合) を帝国に配置する
| 'set_in_empire' E BOOL
// 戦力投射を加算する
| 'add_power_projection' E A 'type' E key 'amount' E integer Z
// 人的資源に水兵を指定の数だけ加算する
| 'add_sailors' E integer
// 国庫に指定のダカットを加算する
| 'add_treasury' E integer
// 海軍伝統を加算する
| 'add_navy_tradition' E integer
// 年間収入に指定のダカットだけ加算する
| 'add_years_of_income' E percentage_range_0_inf
// 指定の数だけ革新性を加算する
| 'change_innovativeness' E integer
// 指定の階級特権の使用を開放する
| 'unlock_estate_privilege' E A 'estate_privilege' E key Z
// 政府改革の進捗に指定の数だけ加算する
| 'change_government_reform_progress' E integer
// 指定の割合だけ軍熟練度を加算する
| 'add_army_professionalism' E point_number
// 教会点を加算する
| 'add_church_power' E integer
// 信仰心を加算する
| 'add_piety' E point_number
// 指定のプロビンスに新しく入植が始まる
| 'create_colony_mission_reward' E A 'province' E positive_integer Z
// 指定のプロビンスに永続請求権をつける
| 'add_permanent_claim' E positive_integer
// 指定の国家フラグをONにする
| 'set_country_flag' E key
// 指定の中核州を得る
| 'add_core' E positive_integer
// 陸軍伝統を得る
| 'add_army_tradition' E integer
// 指定の対象に対して指定の評価補正を与える。yearsがある場合はその期間のみ
| 'add_opinion' E A 'who' E (ROOT|TAG) 'modifier' ('years' E positive_integer)?  E key Z
// 指定の対象から指定の評価を受ける。yearsがある場合はその期間のみ
| 'reverse_add_opinion' E A 'who' E (ROOT|TAG) 'modifier' ('years' E positive_integer)?  E key Z
// 教皇への影響力を指定の値だけ加算する
| 'add_papal_influence' E integer
// 行動による正統性の値に対する影響を小さくする
| 'increase_legitimacy_small_effect' E BOOL
// 指定の規格の将軍を用意する
| 'define_general' E A (
    ('name' E key)
    |('shock' E positive_integer)
    |('fire' E positive_integer)
    |('manuever' E positive_integer)
    |('siege' E positive_integer)
    |('trait' E key))+ Z
// 指定の規格の相当する将軍を用意する
| 'create_general' E A (
    ('tradition' E positive_integer)
    |('add_fire' E positive_integer)
    |('add_shock' E positive_integer)
    |('add_manuever' E positive_integer)
    |('add_siege' E positive_integer)
    |('culture' E cultures))+ Z
// 重商主義の値を加算する
| 'add_mercantilism' E integer
// 指定の対象に対する指定のCBを指定の期間だけ得る
| 'add_casus_belli' E A ('type' E cb_types)? ('months' E positive_integer)? 'target' E TAG ('type' E cb_types)? Z
// 指定の％だけ年間の水兵増加量が増える
| 'add_yearly_sailors' E integer
// 指定の％だけ年間の人的資源増加量が増える
| 'add_yearly_manpower' E integer
// 指定の規格の顧問を用意する
| 'define_advisor' E A (
    ('name' E WRAP_STRING)
    |('type' E (mil_advisor_types|adm_advisor_types|dip_advisor_types))
    |('skill' E positive_integer)
    |('location' E positive_integer) // プロビンス番号
    |('discount' E BOOL)
    |('culture' E cultures)
    |('cost_multiplier' E percentage_range_0_inf)
    |('female' E BOOL)
    |('religion' E (religions|ROOT|TAG)))+ Z
// 指定の傭兵を解禁する
| 'unlock_merc_company' E A 'merc_company' E key Z
// 指定された期間における指定された州の生産所得に基づいて、現在のスコープの即時ダカットを付与する
| 'add_years_of_owned_provinces_production_income' E A 'years' E positive_integer 'trigger' E A province_trigger* Z 'custom_tooltip' E key Z
// 選択肢に置いてカルトを開放する
| 'unlock_cult_through_selection' E BOOL
// カルトミッションへ変更することを許可する
| 'enable_cult_switching_mission' E BOOL
// 改革に大きな影響を与えるようにする
| 'add_innovativeness_big_effect' E BOOL
// 改革進捗エフェクトを加える
| 'add_reform_progress_medium_effect' E BOOL
// 指定のレベルの探検家を作成する
| 'create_explorer' E A 'tradition' E positive_integer Z
//////////////////////////////////////////////////
// エリアの各プロビンスにスコープする　[OPTION] すべて もしくは いずれか１つ以上
| areas E A ('limit' E A province_trigger* Z)? province_effect* Z
// リージョンの各プロビンスにスコープする　[OPTION] すべて もしくは いずれか１つ以上
| regions E A ('limit' E A province_trigger* Z)? province_effect* Z
// プロビンスにスコープする
| positive_integer E A province_effect* Z
| (ROOT|TAG) E A country_effect* Z
// すべての属国にスコープする
| 'every_subject_country' E A c_limit country_effect* Z
// 首都にスコープする
| 'capital_scope' E A province_effect* Z
| 'random_owned_province' E A c_limit? province_effect* Z
// 条件に合う全てのプロビンスにスコープする
| 'every_province' E A p_limit? province_effect* Z
| 'every_country' E A c_limit? country_effect* Z
// 保有しているいずれかのプロビンスにスコープする
| 'any_owned_province' E A province_effect* Z
| 'any_province' E A province_effect* Z
| 'every_owned_province' E A p_limit? province_effect* Z
// 国の主要な取引ポートがある取引ノードにスコープする
| 'home_trade_node_effect_scope' E A province_effect* Z
// イベントトリガにスコープする
| EVENT_TARGET E A country_effect? province_effect? Z
| 'every_known_country' E A c_limit? country_effect* Z
////////////////////////////////////////////////////
| 'if' E A c_limit country_effect* Z ('else_if' E A c_limit country_effect* Z)* ('else' E A country_effect* Z)?
| 'AND' E A country_effect* Z
| 'NOT' E A country_effect* Z
| 'OR' E A country_effect* Z
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A country_effect* 'amount' E positive_integer country_effect* Z ('else' E A country_effect* Z)?
//| key (E|'<'|'>'|'<='|'>=') (primitive|(A country_effect* Z))
//| primitive
;

country_trigger:
// localization ?
'desc' E key
// 条件に合えば指定のツールチップを表示する
| 'custom_trigger_tooltip' E A 'tooltip' E key country_trigger* Z
/////////////////////////////////////////////////////
// 首都が指定のプロビンスである
| 'capital' E positive_integer
// 総収入に対する貿易収入の比率がX以上の場合、trueを返します
| 'trade_income_percentage' E percentage_range_0_1
// 国が貿易同盟のリーダーである場合はtrueを返します。
| 'is_trade_league_leader' E BOOL
// 年間収入が指定数以上
| 'years_of_income' E positive_integer
// 承認の合計数が指定以上
| 'num_of_merchants' E positive_integer
// 国の地方の基本税の合計が指定数以上の場合、trueを返します。
// 国の基本税の合計が指定された国の基本税以上である場合にtrueを返します。
| 'total_base_tax' E (positive_integer|TAG|ROOT)
// 国が指定国もしくはスコープと同じ貿易同盟のメンバーである場合、trueを返します。
| 'is_in_trade_league_with' E (TAG|ROOT)
// 指定のグローバルフラグが存在する
| 'has_global_flag' E key
// 指定された変数が指定数以上の場合はtrueを返します。
| 'check_variable' E A 'which' E key 'value' E positive_integer Z
// 国が別の宗教の国と戦争している場合はtrueを返します。
| 'at_war_with_religious_enemy' E BOOL
// 指定された国に対する国のスコアが指定数以上の場合、trueを返します。
| 'war_score_against' E A 'who' E ROOT 'value' E integer Z
// 国に信頼度100の同盟国が指定の数以上ある場合はtrueを返します。
| 'num_of_trusted_allies' E positive_integer
// 国が指定の数以上の国から戦争賠償を受け取った場合、trueを返します。
// 指定された国と同じ数の国から戦争賠償を受け取った場合、trueを返します。
| 'num_of_war_reparations' E (ROOT|TAG|positive_integer)
// 技術グループが指定のものである
| 'technology_group' E technology_groups
// 植民者が指定の数以上である
| 'num_of_colonists' E positive_integer
// 国が指定された国に対して平和条約（首都の収奪）を使用した場合、trueを返します
| 'has_pillaged_capital_against' E (ROOT|TAG)
// 国が対象の宗主国である場合にtrueを返します
| 'overlord_of' E (ROOT|TAG)
// 王朝が指定の王朝と同じもしくは指定のものである
| 'dynasty' E (ROOT|TAG|key)
// ?
| 'share_of_starting_income' E percentage_range_0_inf
// 指定されたイベントターゲットが保存されている場合はtrueを返します
| 'has_saved_event_target' E key
// 大型船の数が指定以上もしくは指定国の保有数以上
| 'num_of_heavy_ship' E (positive_integer|ROOT)
// ガレー船の数が指定以上
| 'num_of_galley' E positive_integer
// 小型船の数が指定以上
| 'num_of_light_ship' E positive_integer
// 朝貢国以外の属国の数が指定以上
| 'num_of_non_tributary_subjects' E positive_integer
// yesに設定すると、すべての状況でtrueを返し、noに設定すると、すべての状況でfalseを返します
| 'always' E BOOL
// 国の州の総数が指定された数だけ増加した場合にtrueを返します
| 'grown_by_states' E positive_integer
// 指定のプロビンスが中核州である
| 'owns_core_province' E positive_integer
// 指定のプロビンスが自国もしくは属国によって保有されている
| 'owns_or_non_sovereign_subject_of' E positive_integer
// 指定の国家と同盟しているかどうか
| 'alliance_with' E (TAG|ROOT)
// 数値以上の連隊もしくは対象国以上の連隊を保有しているかどうか
| 'army_size' E (TAG|positive_integer|ROOT)
// 統治技術が数値以上かどうか
| 'adm_tech' E positive_integer
//指定の文化を受容しているかどうか
| 'accepted_culture' E cultures
// 主要な文化が指定のものかどうか
| 'primary_culture' E cultures
// 教皇の影響力が数値以上かどうか
| 'papal_influence' E positive_integer
// 文化が指定のものかどうか
| 'culture' E cultures
// 国教が指定のものかどうかもしくは指定の国家と同じかどうか
| 'religion' E (ROOT|religions)
// ランダム新世界機能を使っているかどうか
| 'map_setup' E key
// 指定の国家かどうか
| 'tag' E (key|TAG|ROOT)
// 国家ランクが指定以上かどうか
| 'government_rank' E (INT_1|INT_2|INT_3)
// 対象が現時点で存在しているかどうかもしくはスコープが存在しているかどうか
| 'exists' E (TAG|BOOL)
// 戦争中かどうか
| 'is_at_war' E BOOL
// 対象がライバルかどうか
| 'is_rival' E (ROOT|TAG)
// 対象の国からライバル視されているかどうか
| 'is_enemy' E (ROOT|TAG)
| 'is_subject_of' E (TAG|ROOT)
// 指定の年代よりも後かどうか
| 'is_year' E positive_integer
// 指定の国難が現在発生中かどうか
| 'has_disaster' E key
| 'num_of_cities' E positive_integer
// 対象のDLCを保有しているかどうか
| 'has_dlc' E dlcs
| 'has_opinion_modifier' E A 'who' E ROOT 'modifier' E key Z
// 指定の国家フラグが存在するかどうか
| 'has_country_flag' E key
// 指定の対象国から指定の数以上の評価をもらっているかどうか
| 'has_opinion' E A 'who' E (ROOT|TAG) 'value' E integer Z
// 指定の階級が存在しているかどうか
| 'has_estate' E estates
// 指定した階級の土地所有が指定以上であるかどうか
| 'estate_loyalty' E A'estate' E estates 'loyalty' E positive_integer Z
// HREの構成国が対象の数値以上かどうか
| 'hre_size' E positive_integer
| 'hre_religion_treaty' E BOOL
| 'hre_religion_locked' E BOOL
// 自国が保有するプロビンスもしくは属国が保有するプロビンスが指定数以上かつ指定の条件かどうか
| 'num_of_provinces_owned_or_owned_by_non_sovereign_subjects_with' E A province_trigger* 'value' E positive_integer province_trigger* Z
// 自国が保有するプロビンスが指定数以上かつ指定の条件かどうか
| 'num_of_owned_provinces_with' E A province_trigger* 'value' E positive_integer province_trigger* Z
// 自国とその朝貢国以外の属国の合計開発度が、指定された国家とその非朝貢国以外の属国より多い場合、trueを返します。数値の場合は数値と比較されます
| 'total_own_and_non_tributary_subject_development' E (TAG|ROOT|positive_integer)
// 独立欲求が指定の数以上かどうか
| 'liberty_desire' E positive_integer
// HRE皇帝かどうか
| 'is_emperor' E BOOL
// 帝国派の影響が指定値以上であるかどうか
| 'imperial_influence' E positive_integer
// 階級の土地所有における王国シェアが指定％以上かどうか
| 'crown_land_share' E positive_integer
// 威信が指定以上かどうか
| 'prestige' E positive_integer
// 陸軍伝統が指定以上かどうか
| 'army_tradition' E positive_integer
// 摂政評議会であるかどうか
| 'has_regency' E BOOL
// HREの構成国であるかどうか
| 'is_part_of_hre' E BOOL
// 選帝侯であるかどうか
| 'is_elector' E BOOL
// 対象国に対してHRE皇帝が好意的な評価をしているかどうか
| 'preferred_emperor' E ROOT
// 政体が指定のものであるかどうか
| 'government' E governments
// 正統性が数値以上であるかどうか
| 'legitimacy' E positive_integer
// 列強かどうか
| 'is_great_power' E BOOL
// 総計開発度が指定以上かどうか
| 'total_development' E positive_integer
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
// 港の数（海に面したプロビンスの数）が指定以上
| 'num_of_ports' E positive_integer
// 指定のダカットを現在保有している
| 'treasury' E integer
// 海軍艦隊数の扶養限界に対する現在の艦隊数の割合が指定以上
| 'navy_size_percentage' E percentage_range_0_inf
// 帝国の危機が発生中かどうか
| 'active_imperial_incident' E ('any'|'all')
// 女性後継者であるかどうか
| 'has_female_heir' E BOOL
// 国家フラグが有効になってから指定の日数が経過したかどうか
| 'had_country_flag' E A 'flag' E key 'days' E positive_integer Z
// 統治者が指定の人物であるかどうか
| 'has_ruler' E WRAP_STRING
// 後継者が存在するかどうか
| 'has_heir' E BOOL
// 対象のプロビンスを支配している
| 'controls' E positive_integer
// 海に面している
| 'has_port' E BOOL
// 月間の外交点収入が指定数以上
| 'monthly_dip' E integer
// 月間の統治点収入が指定数以上
| 'monthly_adm' E integer
// 西欧よりも技術レベルで優位であるかどうか
| 'has_better_tech_than_westerns' E BOOL
// 西欧よりも制度受容で優位であるかどうか
| 'has_more_institutions_than_westerns' E BOOL
// 軍熟練度が指定の割合以上である
| 'army_professionalism' E percentage_range_0_1
// 軍事技術が指定以上
| 'mil_tech' E integer
// 軍事点が指定の数以上保有している
| 'mil_power' E integer
// 外交点が指定の数以上保有している
| 'dip_power' E integer
// 陸軍連隊数の扶養限界に対する現在の連隊の割合が指定以上
| 'army_size_percentage' E percentage_range_0_inf
// 将軍の数が指定以上
| 'num_of_generals' E positive_integer
// カワ連隊の数が指定以上
| 'num_of_cawa' E positive_integer
// 反乱軍の連隊数が指定の数以上である
| 'num_of_rebel_armies' E positive_integer
// プロビンスを保有している
| 'owns' E positive_integer
// 宗教統一度が指定の割合以上である
| 'religious_unity' E percentage_range_0_inf
// 指定の種類の顧問を雇用している
| 'advisor' E key
// 国教が指定の宗教グループであるもしくは指定の国家と同じである
| 'religion_group' E (ROOT|TAG|religion_groups)
// 安定度が数値以上である
| 'stability' E (MINT_3|MINT_2|MINT_1|INT_0|INT_1|INT_2|INT_3)
// 政府改革レベルが指定以上
| 'reform_level' E (INT_0|INT_1|INT_2|INT_3|INT_4|INT_5|INT_6)
// 指定の政府改革がある
| 'has_reform' E key
// 指定の階級特権が選択肢にある
| 'has_estate_privilege' E estates
// 絶対主義が数値以上
| 'absolutism' E positive_integer
// 指定の州が中核州である
| 'is_core' E positive_integer
// 指定の州に永続請求権があるかどうか
| 'is_permanent_claim' E positive_integer
// 人的資源の回復率が指定以上
| 'manpower_percentage' E percentage_range_0_inf
// 指定の国家よりも指定の割合だけ強力である（連隊数と軍事技術が関係？）
| 'army_strength' E A 'who' E (ROOT|TAG) 'value' E percentage_range_0_inf Z
// ランダム新世界が有効になっているかどうか
| 'is_random_new_world' E BOOL
// 指定の国家の植民国家であるかどうか
| 'is_colonial_nation_of' E ROOT
// 破産しているかどうか
| 'is_bankrupt' E BOOL
// 借款の数が指定数以上である
| 'num_of_loans' E positive_integer
// 連邦の数が指定以上
| 'federation_size' E positive_integer
// 文化グループが指定のもの
| 'culture_group' E culture_groups
// 対象の建物が数値以上存在する？
| buildings E positive_integer
// 開発度合計値の増加分が指定の値を超えた
| 'grown_by_development' E positive_integer
// 指定の国から禁輸されている
| 'trade_embargoing' E TAG
// 総開発値が指定の値を超えているもしくは指定の国家を上回っている
| 'total_development' E (TAG|ROOT|positive_integer)
// 対象に勝ってから最大で指定の期間まで真になる
| 'has_won_war_against' E A 'who' E (ROOT|TAG) 'max_years_since' E positive_integer Z
// 国が戦争状態にあり、前述の条件が満たされている場合は真になる
// attacker_leader : 攻撃側主導国が指定の国家
// defender_leader : 防衛側主導国が指定の国家
| 'is_in_war' E A (('defender_leader' E ROOT)|('attacker_leader' E ROOT))+  Z
// 対象の国家にと比較して軍隊の強さ（陸軍、海軍の連隊数を合わせる）が指定の割合を超えているかどうか
| 'military_strength' E A 'who' E ROOT 'value' E percentage_range_0_inf Z
// 指定の時代以上になった
| 'current_age' E ages
// 指定の制度以上になった
| 'has_institution' E institutions
// ？
| 'valid_for_personal_unions_trigger' E BOOL
// 指定のミッションを完了済み
| 'mission_completed' E key
// 対象よりも多い艦隊数を有しているもしくは指定の数よりも多い艦隊数を有している
| 'navy_size' E (ROOT|TAG|positive_integer)
// 革命国家である
| 'is_revolutionary' E BOOL
// （指定のレベルの）軍事顧問が存在する
| ('has_mil_advisor'|'has_mil_advisor_1'|'has_mil_advisor_2'|'has_mil_advisor_3'|'has_mil_advisor_4'|'has_mil_advisor_5') E BOOL
// （指定のレベルの）統治顧問が存在する
| ('has_adm_advisor'|'has_adm_advisor_1'|'has_adm_advisor_2'|'has_adm_advisor_3'|'has_adm_advisor_4'|'has_adm_advisor_5') E BOOL
// （指定のレベルの）外交顧問が存在する
| ('has_dip_advisor'|'has_dip_advisor_1'|'has_dip_advisor_2'|'has_dip_advisor_3'|'has_dip_advisor_4'|'has_dip_advisor_5') E BOOL
// 指定の数以上の同盟を結んでいるもしくは指定の国家が結んでいる同盟以上の同盟を結んでいる
| 'num_of_allies' E (positive_integer|TAG|ROOT)
// 汚職が数値以上かどうか
| 'corruption' E percentage_range_0_inf
// 騎兵の数が指定以上
| 'num_of_cavalry' E positive_integer
// 対象の国家と戦争中である
| 'war_with' E (ROOT|TAG)
// 属国の数が指定以上
| 'num_of_subjects' E positive_integer
// 開放されたカルトの数が数値以上
| 'num_of_unlocked_cults' E positive_integer
// 指定のレベルの顧問が存在する
| (mil_advisor_types|dip_advisor_types|adm_advisor_types) E (INT_1|INT_2|INT_3|INT_4|INT_5)
// 指定の派閥の影響力が指定以上
| 'estate_influence' E A 'estate' E estates 'influence' E positive_integer Z
// 対象の生産リーダーである
| 'production_leader' E A 'trade_goods' E trade_goods Z
// 対象の生産品のボーナスを受け取っているかどうか
| 'trading_bonus' E A 'trade_goods' E trade_goods 'value' E BOOL Z
///////////////////////////////////////////////////
// プロビンスにスコープにする
| positive_integer E A province_trigger* Z
// エリアの各プロビンスにスコープにする
| areas E A province_trigger* ('type' E ('all'|'any'))? province_trigger* Z
// 植民地域の各プロビンスにスコープにする
| COLONIAL_X E A province_trigger* ('type' E ('all'|'any'))? province_trigger* Z
// リージョンにスコープにする
| religions E A ('type' E ('all'|'any'))? province_trigger* ('type' E ('all'|'any'))? Z
// 任意の属国にスコープする
| 'any_subject_country' E A country_trigger* Z
// 対象国もしくは自国にスコープする
| (ROOT|TAG) E A country_trigger* Z
// すべての国家にスコープする
| 'all_country' E A country_trigger* Z
// 条件を満たす任意の国家にスコープする
| 'any_country' E A country_trigger* Z
// 条件を満たすすべての国家にスコープする
| 'all_ally' E A country_trigger* Z
// 条件を満たすいずれかの国家にスコープする
| 'any_ally' E A country_trigger* Z
// 首都にスコープする
| 'capital_scope' E A province_trigger* Z
// すべての選帝侯にスコープする
| 'all_elector' E A country_trigger* Z
// HRE皇帝にスコープする
| 'emperor' E A country_trigger* Z
// 保有している州かつ条件にあう州にスコープする
| 'any_owned_province' E A province_trigger* Z
// すべての所有している州にスコープする
| 'all_owned_province' E A province_trigger* Z
// すべての属国にスコープする
| 'all_subject_country' E A country_trigger* Z
//  現在のスコープによって発見されたすべての国にスコープする
| 'all_known_country' E A country_trigger* Z
// すべてのプロビンスにスコープする
| 'all_province' E A province_trigger* Z
// いずれかの既知の国家にスコープする
| 'any_known_country' E A country_trigger* Z
// スーパーリージョンの各プロビンス
| super_regions E A ('type' E ('all'|'any'))? province_trigger* ('type' E ('all'|'any'))? Z
// 現在のスコープのメイン取引ポートを含む取引ノードにスコープする
| 'home_trade_node' E A province_trigger* Z
// すべての交易ノードにスコープする
| 'all_trade_node' E A province_trigger* Z
//////////////////////////////////////////////////
| 'if' E A c_limit country_trigger* Z ('else_if' E A c_limit country_trigger* Z)* ('else' E A country_trigger* Z)?
| 'AND' E A country_trigger* Z
| 'NOT' E A country_trigger* Z
| 'OR' E A country_trigger* Z
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A country_trigger* 'amount' E positive_integer country_trigger* Z ('else' E A country_trigger* Z)? ;

province_effect
: 'hidden_effect' E A province_effect* Z
| 'custom_tooltip' E key
////////////////////////////////////////////////////////
// 現在の地域スコープに地域トリガー補正を追加します。
| 'add_province_triggered_modifier' E key
// 現在のスコープをキーとして保存します。実行が終了するとクリアされます(すなわちイベントの終了)。
| 'save_event_target_as' E key
// 指定の国家がこのプロビンスに永続請求権を得る
| 'add_permanent_claim' E ROOT
//指定の数値を製造開発度に追加する
| 'add_base_production' E integer
// 指定の数値を人的開発度に追加する
| 'add_base_manpower' E integer
// 指定の数値を税開発度に追加する
| 'add_base_tax' E integer
// 指定の州補正を指定の期間だけ与える。duration -1は永続
| 'add_province_modifier' E A 'name' E key 'duration' E (positive_integer|MINT_1) Z
// 指定の交易補正を指定の期間だけ与える。duration -1は永続
| 'add_trade_modifier' E A 'who' E (ROOT|TAG) 'duration' E (positive_integer|MINT_1) 'power' E integer 'key' E key Z
// 指定の国家と同じ文化に変更するもしくは指定の文化に変更する
| 'change_culture' E (ROOT|TAG|cultures)
// 指定の国家と同じ宗教に変更するもしくは指定の宗教に変更する
| 'change_religion' E (ROOT|TAG|religions)
// HREに追加する
| 'set_in_empire' E BOOL
// 指定の建物を追加する
| 'add_building' E buildings
// 指定の数だけ自治率を加算する
| 'add_local_autonomy' E integer
// 指定の建物の建設を開始する。スピードとコストは基本値に対する割合。
| 'add_building_construction' E A 'building' E buildings 'speed' E integer 'cost' E integer Z
// 指定の建物を削除する
| 'remove_building' E key
// 指定の数のユニットの作成を開始する。スピードとコストは基本値に対する割合。
| 'add_unit_construction' E A 'type' E key 'amount' E integer 'speed' E integer 'cost' E integer  Z
// 対象の国家が請求権を得る
| 'add_claim' E (ROOT|TAG)
// CoTのレベルを上げる
| 'add_center_of_trade_level' E integer
// 指定の反乱軍を指定の規模で発生させる
| 'add_named_unrest' E A 'name' E key 'value' E positive_integer Z
// 首都移転の効果を発生させる
| 'move_capital_effect' E BOOL
// プロビンス名を変更する
| 'change_province_name' E key
// 首都名を変更する
| 'rename_capital' E key
// CoTを指定のレベルにする
| 'center_of_trade' E (INT_1|INT_2|INT_3)
// 分離主義を追加
| 'add_nationalism' E integer
////////////////////////////////////////////////
| ROOT E A country_effect* Z
| TAG E A country_effect* Z
| religions E A ('limit' E A province_trigger* Z)? province_effect* Z
| 'owner' E A country_effect* Z
// エリアの各プロビンスにスコープする
| 'area' E A ('limit' E A province_trigger* Z)? province_effect* Z
| 'area_for_scope_province' E A province_effect* Z
// 隣接するすべてのプロビンスにスコープする
| 'every_neighbor_province' E A province_effect* Z
| 'random_trade_node_member_province' E A ('limit' E A province_trigger* Z)? province_effect* Z
////////////////////////////////////////////////
| 'if' E A p_limit province_effect* Z ('else_if' E A p_limit province_effect* Z)* ('else' E A province_effect* Z)?
| 'OR' E A province_effect* Z
| 'NOT' E A province_effect* Z
| 'AND' E A province_effect* Z
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A province_effect* 'amount' E positive_integer province_effect* Z  ('else' E A province_effect* Z)?
;

province_trigger
// 条件に合えば指定のツールチップを表示する
: 'custom_trigger_tooltip' E A 'tooltip' E key province_trigger* Z
//////////////////////////////////////////////////
// shipyard_building_triggerを持っている
| 'has_shipyard_building_trigger' E BOOL
// 国が交易ノードでの非公開化によって少なくともXの取引権限を持つ場合、trueを返します。
| 'privateer_power' E A 'country' E (TAG|ROOT) 'share' E positive_integer Z
// この州に存在する建物の数が指定数以上
| 'num_of_buildings_in_province' E positive_integer
// 対象のDLCを保有しているかどうか
| 'has_dlc' E dlcs
// 州の現在の宗教が指定のものであるかどうか
| 'province_religion' E religions
// HREの構成プロビンスであるかどうか
| 'is_part_of_hre' E BOOL
// 指定の文化であるかどうか
| 'culture' E cultures
// この州が指定の場所にある場合はtrueを返します
| 'continent' E (continents|'CAPITAL'|ROOT|positive_integer)
// 対象のリージョンであるかどうか
| 'region' E regions
// 対象のエリアであるかどうか
| 'area' E areas
| 'is_claim' E ROOT
// 対象の国家もしくは自国がこの州を保有しているかどうか
| 'owned_by' E (ROOT|TAG)
// 対象のプロビンスであるかどうか
| 'province_id' E positive_integer
| 'trade_share' E A 'country' E ROOT 'share' E positive_integer Z
// 指定の国家の交易力が最大であるかどうか
| 'is_strongest_trade_power' E ROOT
// 対象の国家にとって中核州であるかどうか
| 'is_core' E (ROOT|TAG)
| 'is_state_core' E ROOT
// 州が指定された国の首都である場合はtrueを返します
| 'is_capital_of' E ROOT
// 首都であるかどうか
| 'is_capital' E BOOL
// 対象の国家が現存しているかどうか
| 'exists' E TAG
// 州が指定された国またはその朝貢国以外の属国の一部である場合はtrueを返します
| 'country_or_non_sovereign_subject_holds' E (ROOT|TAG)
// CoTがある場合にそのレベルが指定以上かどうか
| 'province_has_center_of_trade_of_level' E positive_integer
// 指定の建物が建っているかどうか
| 'has_building' E buildings
| 'hre_size' E positive_integer
// 建物の空きスロットが指定数以上かどうか
| 'num_free_building_slots' E positive_integer
// 対象の国家によって支配されている
| 'controlled_by' E (ROOT|TAG)
// 指定の州補正が存在する
| 'has_province_modifier' E key
// 指定の国家によって発見済みかどうか
| 'has_discovered' E (ROOT|TAG)
// 対象の国家が永続請求権を所有しているかどうか
| 'is_permanent_claim' E ROOT
// 国教が指定のものかどうかもしくは指定の国家と同じかどうか
| 'religion' E (ROOT|religions)
// 基本生産価値が指定以上
| 'base_production' E positive_integer
// 州の開発が 指定の回数以上実施された
| 'num_of_times_improved' E positive_integer
// 未入植地である
| 'is_empty' E BOOL
// 港建設トリガーがある
| 'has_dock_building_trigger' E BOOL
// 指定の植民地域である
| 'colonial_region' E key
// 海に面している
| 'has_port' E BOOL
// 要塞レベルが指定以上
| 'fort_level' E positive_integer
// 開発度が指定値以上もしくは指定の場所以上
| 'development' E (positive_integer|'CAPITAL')
// 交易関係の建物を建設済み？
| 'has_trade_building_trigger' E BOOL
// プロビンスが都市（入植地が完成した）
| 'is_city' E BOOL
// このプロビンスが指定の数値以上の交易力を発生させている
| 'province_trade_power' E positive_integer
// 指定の数以上の反乱軍に支配されている
| 'unrest' E positive_integer
// 荒廃度が指定の値以上である
| 'devastation' E positive_integer
// 対象が自身の一部もしくは属国である
| 'country_or_subject_holds' E (ROOT|TAG)
// スーパーリージョンが指定の地域である
| 'superregion' E super_regions
// 州の交易ノードがtrade company領域にある場合、trueを返します。
| 'is_node_in_trade_company_region' E BOOL
////////////////////////////////////////////////
// 対象国へスコープ変更move_capital_effect
| (ROOT|TAG) E A country_trigger* Z
| 'owner' E A country_trigger* Z
| 'region_for_scope_province' E A ('type' E ('all'|'any'))? province_trigger* ('type' E ('all'|'any'))? Z
| 'all_trade_node_member_province' E A province_trigger* Z
// 現在のスコープと国教を接するいずれか1つの州にスコープする
| 'any_neighbor_province' E A province_trigger* Z
// 指定の水面エリアに面している
| 'sea_zone' E A province_trigger* Z
////////////////////////////////////////////////
| 'OR' E A province_trigger* Z
| 'NOT' E A province_trigger* Z
| 'AND' E A province_trigger* Z
| 'if' E A p_limit province_trigger* Z ('else_if' E A p_limit province_trigger* Z)* ('else' E A province_trigger* Z)?
// 指定の条件に合うものが合計数以上
| 'calc_true_if' E A province_trigger* 'amount' E positive_integer province_trigger* Z ('else' E A province_trigger* Z)?
;

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

key: (WRAP_STRING|DATE_TIME|BASE|COLONIAL_X);
integer: MINT|MINT_3|MINT_2|MINT_1|INT_0|INT_1|INT_2|INT_3|INT_4|INT_5|INT_6|INT; // 整数
point_number: integer|FLOAT|FLOAT_0_1|MFLOAT;
positive_integer: INT_0|INT_1|INT_2|INT_3|INT_4|INT_5|INT_6|INT; // 正の整数
natural_number: INT_1|INT_2|INT_3|INT_4|INT_5|INT_6|INT; // 自然数
percentage_range_0_1: INT_0|INT_1|FLOAT_0_1;
percentage_range_0_inf: INT_0|INT_1|INT_2|INT_3|INT_4|INT_5|INT_6|INT|FLOAT_0_1|FLOAT;

c_limit: 'limit' E A country_trigger* Z;
p_limit: 'limit' E A province_trigger* Z;

////////////////////////////////////////////////////

regions
:'random_new_world_region'
|'france_region'
|'scandinavia_region'
|'low_countries_region'
|'italy_region'
|'north_german_region'
|'south_german_region'
|'russia_region'
|'ural_region'
|'iberia_region'
|'british_isles_region'
|'baltic_region'
|'poland_region'
|'ruthenia_region'
|'crimea_region'
|'balkan_region'
|'carpathia_region'
|'egypt_region'
|'maghreb_region'
|'mashriq_region'
|'anatolia_region'
|'persia_region'
|'khorasan_region'
|'caucasia_region'
|'arabia_region'
|'niger_region'
|'guinea_region'
|'sahel_region'
|'horn_of_africa_region'
|'east_africa_region'
|'central_africa_region'
|'kongo_region'
|'central_asia_region'
|'south_africa_region'
|'west_siberia_region'
|'east_siberia_region'
|'mongolia_region'
|'manchuria_region'
|'korea_region'
|'tibet_region'
|'hindusthan_region'
|'bengal_region'
|'west_india_region'
|'deccan_region'
|'coromandel_region'
|'burma_region'
|'japan_region'
|'australia_region'
|'south_china_region'
|'xinan_region'
|'north_china_region'
|'brazil_region'
|'la_plata_region'
|'colombia_region'
|'peru_region'
|'upper_peru_region'
|'malaya_region'
|'moluccas_region'
|'indonesia_region'
|'oceanea_region'
|'indo_china_region'
|'canada_region'
|'great_lakes_region'
|'northeast_america_region'
|'southeast_america_region'
|'mississippi_region'
|'great_plains_region'
|'california_region'
|'cascadia_region'
|'hudson_bay_region'
|'mexico_region'
|'rio_grande_region'
|'central_america_region'
|'carribeans_region'
|'baltic_sea_region'
|'north_atlantic_region'
|'american_east_coast_region'
|'mediterrenean_region'
|'caribbean_sea_region'
|'west_african_sea_region'
|'west_indian_ocean_region'
|'arabian_sea_region'
|'east_indian_ocean_region'
|'south_indian_ocean_region'
|'south_china_sea_region'
|'east_china_sea_region'
|'north_west_pacific_region'
|'south_west_pacific_region'
|'south_east_pacific_region'
|'north_east_pacific_region'
|'pacific_south_america_region'
|'atlantic_south_america_region'
|'south_atlantic_region';

areas
:'western_mediterrenean_area' |'eastern_mediterrenean_area' |'black_sea_area' |'baltic_area' |'kattegat_area' |'north_sea_area' |'norwegian_sea_area' |'white_sea_area' |'red_sea_area' |'persian_gulf_area' |'arabian_sea_area' |'andaman_sea_area' |'bay_of_bengal_area' |'eastern_indian_ocean_area' |'western_indian_ocean_area' |'south_indian_ocean_area' |'great_australian_bight_area' |'swahili_coast_sea_area' |'south_china_sea_area' |'celebes_sea_area' |'java_sea_area' |'east_china_sea_area' |'sea_of_japan_area' |'sea_of_okhotsk_area' |'berring_sea_area' |'tasman_sea_area' |'coral_sea_area' |'philipine_sea_area' |'banda_arafura_seas_area' |'gulf_of_alaska_area' |'sea_of_grau_area' |'chilean_sea_area' |'gulf_of_panama_area' |'bay_of_biscay_area' |'english_channel_area' |'caribbean_sea_area' |'gulf_of_mexico_area' |'sea_of_labrador_area' |'hudson_bay_sea_area' |'denmark_strait_area' |'gulf_of_guinea_sea_area' |'cape_of_storms_area' |'skeleton_coast_area' |'east_pacific_ocean_area' |'polynesian_triangle_area' |'south_pacific_area' |'north_pacific_area' |'north_pacific_coast_area' |'coast_of_brazil_sea_area' |'coast_of_guyana_area' |'celtic_sea_area' |'west_african_coast_sea_area' |'south_atlantic_area' |'argentine_sea_area' |'gulf_of_st_lawrence_area' |'gulf_stream_area' |'sargasso_sea_area' |'north_atlantic_area' |'bahama_channel_area' |'brittany_area' |'normandy_area' |'provence_area' |'poitou_area' |'guyenne_area' |'pyrenees_area' |'languedoc_area' |'bourgogne_area' |'west_burgundy_area' |'massif_central_area' |'savoy_dauphine_area' |'lorraine_area' |'picardy_area' |'ile_de_france_area' |'champagne_area' |'loire_area' |'orleans_area' |'wallonia_area' |'holland_area' |'flanders_area' |'frisia_area' |'brabant_area' |'north_brabant_area' |'aragon_area' |'catalonia_area' |'valencia_area' |'lower_andalucia_area' |'upper_andalucia_area' |'castille_area' |'toledo_area' |'asturias_area' |'galicia_area' |'baleares_area' |'basque_country' |'leon_area' |'extremadura_area' |'beieras_area' |'alentejo_area' |'macaronesia_area' |'venetia_area' |'lombardy_area' |'po_valley_area' |'piedmont_area' |'tuscany_area' |'liguria_area' |'corsica_sardinia_area' |'sicily_area' |'western_sicily_area' |'naples_area' |'lazio_area' |'calabria_area' |'apulia_area' |'emilia_romagna_area' |'central_italy_area' |'munster_area' |'connacht_area' |'leinster_area' |'ulster_area' |'kingdom_of_the_isles_area' |'highlands_area' |'lowlands_area' |'wales_area' |'scottish_marches_area' |'yorkshire_area' |'west_midlands_area' |'east_midlands_area' |'wessex_area' |'home_counties_area' |'east_anglia_area' |'jutland_area' |'denmark_area' |'skaneland_area' |'gotaland_area' |'vastra_gotaland_area' |'svealand_area' |'ostra_svealand_area' |'norrland_area' |'finland_area' |'bothnia_area' |'laponia_area' |'karelia_area' |'north_karelia' |'northern_norway' |'eastern_norway' |'western_norway' |'subarctic_islands_area' |'greenland_area' |'estonia_ingria_area' |'livonia_area' |'curonia_area' |'east_prussia_area' |'west_prussia_area' |'wielkopolska_area' |'malopolska_area' |'red_ruthenia_area' |'podolia_volhynia_area' |'volhynia_area' |'pripyat_area' |'podlasie_area' |'mazovia_area' |'central_poland_area' |'sandomierz_area' |'kuyavia_area' |'samogitia_area' |'lithuania_area' |'west_dniepr_area' |'east_dniepr_area' |'chernigov_area' |'sloboda_ukraine_area' |'yedisan_area' |'zaporizhia_area' |'azov_area' |'crimea_area' |'white_ruthenia_area' |'minsk_area' |'ryazan_area' |'moscow_area' |'vladimir_area' |'yaroslavl_area' |'tver_area' |'suzdal_area' |'smolensk_area' |'oka_area' |'novgorod_area' |'pskov_area' |'vologda_area' |'beloozero_area' |'astrakhan_area' |'lower_don_area' |'kazan_area' |'samara_area' |'lower_yik_area' |'nogai_area' |'ural_area' |'pomor_area' |'arkhangelsk_area' |'bashkiria_area' |'volga_area' |'galich_area' |'kama_area' |'tambov_area' |'saratov_area' |'silesia_area' |'bohemia_area' |'erzgebirge_area' |'lusatia_area' |'moravia_area' |'south_saxony_area' |'upper_bavaria_area' |'lower_bavaria_area' |'east_bavaria_area' |'lower_swabia_area' |'franconia_area' |'upper_franconia_area' |'upper_swabia_area' |'northern_saxony_area' |'thuringia_area' |'neumark_area' |'mittelmark_area' |'vorpommern_area' |'hinter_pommern_area' |'tirol_area' |'austria_proper_area' |'inner_austria_area' |'carinthia_area' |'switzerland_area' |'romandie_area' |'upper_rhineland_area' |'alsace_area' |'palatinate_area' |'north_rhine_area' |'lower_rhineland_area' |'westphalia_area' |'north_westphalia_area' |'hesse_area' |'braunschweig_area' |'weser_area' |'holstein_area' |'lower_saxony_area' |'mecklenburg_area' |'macedonia_area' |'morea_area' |'northern_greece_area' |'thrace_area' |'bulgaria_area' |'silistria_area' |'wallachia_area' |'moldavia_area' |'transylvania_area' |'southern_transylvania_area' |'slovakia_area' |'serbia_area' |'rascia_area' |'albania_area' |'bosnia_area' |'croatia_area' |'slavonia_area' |'east_adriatic_coast_area' |'alfold_area' |'transdanubia_area' |'imereti_area' |'samtskhe_area' |'kartli_kakheti_area' |'armenia_area' |'shirvan_area' |'circassia_area' |'dagestan_area' |'rum_area' |'erzurum_area' |'hudavendigar_area' |'germiyan_area' |'aydin_area' |'ankara_area' |'aegean_archipelago_area' |'kastamonu_area' |'karaman_area' |'cukurova_area' |'aleppo_area' |'syria_area' |'trans_jordan_area' |'palestine_area' |'dulkadir_area' |'iraq_arabi_area' |'basra_area' |'luristan_area' |'north_kurdistan_area' |'khuzestan_area' |'shahrizor_area' |'al_jazira_area' |'bahrain_area' |'pirate_coast_area' |'nafud_area' |'tabuk_area' |'medina_area' |'mecca_area' |'asir_area' |'tihama_al_yemen_area' |'upper_yemen_area' |'yemen_area' |'hadramut_area' |'mahra_area' |'yamamah_area' |'qasim_area' |'dhofar_area' |'oman_area' |'mascat_area' |'syrian_desert_area' |'gulf_of_arabia_area' |'al_wahat_area' |'delta_area' |'bahari_area' |'vostani_area' |'said_area' |'tripolitania_area' |'cyrenaica_area' |'fezzan_area' |'tunisia_area' |'djerba_area' |'algiers_area' |'barbary_coast_area' |'kabylia_area' |'hautes_plaines_area' |'ouled_nail_area' |'north_saharan_area' |'tafilalt_area' |'sus_area' |'southern_morocco_area' |'western_morocco_area' |'marrekesh_area' |'northern_morocco_area' |'madagascar_highlands_area' |'betsimasaraka_area' |'sakalava_area' |'southern_madagascar' |'lower_zambezi_area' |'upper_zambezi_area' |'shire_area' |'butua_area' |'zimbabwe_area' |'ruvuma_area' |'ngonde_area' |'mozambique_area' |'uticulo_makuana_area' |'quelimane_area' |'limpopo_area' |'central_swahili_coast_area' |'northern_swahili_coast_area' |'mombasa_area' |'kenya_area' |'jubba_area' |'tanzania_area' |'buha_area' |'buzinza_area' |'luba_area' |'katanga_area' |'zambia_area' |'chokwe_area' |'rwanda_area' |'uganda_area' |'bunyoro_area' |'kasai_area' |'sankuru_area' |'lower_kasai' |'ogaden_area' |'darfur_central_sahara_area' |'kurdufan_area' |'lower_nubia_area' |'dongola_area' |'upper_nubia_area' |'sennar_area' |'red_sea_coast_area' |'tigray_area' |'ifat_area' |'somaliland_area' |'southern_ethiopia_area' |'hadiya_area' |'central_ethiopia_area' |'damot_area' |'aussa_area' |'shewa_area' |'mogadishu_area' |'ajuuran_area' |'majarteen_area' |'mascarenes_area' |'indian_ocean_islands_area' |'papua_area' |'vogelkop_area' |'melanesia_area' |'fiji_area' |'micronesia_area' |'west_micronesia_area' |'western_australia_area' |'northern_australia_area' |'top_end_area' |'eastern_australia_area' |'southern_australia_area' |'murray_river_area' |'illawara_area' |'north_queensland_area' |'south_queensland_area' |'pilbara_area' |'tasmania_area' |'northern_polynesia_area' |'eastern_polynesia_area' |'polynesia_area' |'te_ika_a_maui_hauauru_area' |'te_ika_a_maui_waho_area' |'te_waipounamu_area' |'western_sahara_area' |'cap_verde_area' |'jolof_area' |'tekrur_area' |'baghena_area' |'manding_area' |'futa_jallon_area' |'massina_area' |'jenne_area' |'niger_bend_area' |'upper_volta_area' |'kong_area' |'lower_volta_area' |'lower_niger_area' |'hausa_area' |'katsina_area' |'zazzau_area' |'bornu_area' |'kanem_area' |'adamawa_plateau_area' |'dendi_area' |'azbin_area' |'east_azbin_area' |'atacora_oueme_area' |'gulf_of_guinea_area' |'benin_area' |'sao_tome_area' |'west_africa_coast_area' |'guinea_coast_area' |'south_atlantic_islands_area' |'matamba_area' |'coastal_kongo' |'kongo_area' |'angola_namibia_area' |'cape_of_good_hope_area' |'south_african_plateau_area' |'makran_area' |'sistan_area' |'kalat_area' |'ferghana_area' |'arys_area' |'kyzylkum_area' |'transoxiana_area' |'termez_area' |'khiva_area' |'kabulistan_area' |'transcaspia_area' |'mashhad_area' |'herat_area' |'birjand_area' |'ghor_area' |'merv_area' |'balkh_area' |'kerman_area' |'persian_gulf_coast' |'mogostan_area' |'farsistan_area' |'iraq_e_ajam_area' |'azerbaijan_area' |'isfahan_area' |'tabriz_area' |'tabarestan_area' |'sirhind_area' |'sind_sagar_area' |'oudh_area' |'katehar_area' |'purvanchal_area' |'upper_doab_area' |'lower_doab_area' |'lahore_area' |'multan_area' |'naga_hills_area' |'east_bengal_area' |'north_bengal_area' |'tripura_area' |'bihar_area' |'mithila_area' |'jharkhand_area' |'upper_mahanadi_area' |'gaur_area' |'west_bengal_area' |'gird_area' |'baghelkhand_area' |'bundelkhand_area' |'gondwana_area' |'orissa_area' |'garjat_area' |'telingana_area' |'golconda_area' |'andhra_area' |'raichur_doab_area' |'khandesh_area' |'rayalaseema_area' |'malabar_area' |'malwa_area' |'mewar_area' |'jangladesh_area' |'marwar_area' |'jaipur_area' |'sindh_area' |'northern_sindh_area' |'north_carnatic_area' |'south_carnatic_area' |'madura_area' |'tanjore_area' |'kongu_area' |'konkan_area' |'desh_area' |'ahmednagar_area' |'kanara_area' |'maidan_area' |'mysore_area' |'berar_area' |'assam_area' |'himalayan_hills_area' |'nepal_area' |'baisi_rajya_area' |'bhutan_area' |'kashmir_area' |'lanka_area' |'south_lanka_area' |'ahmedabad_area' |'patan_area' |'tapti_area' |'saurashtra_area' |'upper_burma_area' |'central_burma_area' |'chindwin_area' |'kachin_area' |'shan_hill_area' |'karenni_area' |'malaya_area' |'johor_area' |'malacca_area' |'khorat_area' |'champasak_area' |'champa_area' |'tay_nguyen_area' |'cambodia_area' |'angkor_area' |'lower_burma_area' |'arakan_area' |'mekong_area' |'tenasserim_area' |'north_tenasserim_area' |'north_malaya_area' |'vietnam_area' |'red_river_delta_area' |'north_laos_area' |'vientiane_area' |'central_thai_area' |'sukhothai_area' |'northern_thai_area' |'mindanao_area' |'west_mindanao_area' |'visayas_area' |'palawan_area' |'luzon_area' |'southern_luzon_area' |'north_sumatra_area' |'batak_area' |'central_sumatra_area' |'jambi_area' |'minangkabau_area' |'south_sumatra_area' |'east_java_area' |'surabaya_area' |'central_java_area' |'west_java_area' |'banten_area' |'kutai_area' |'sabah_area' |'brunei_area' |'kalimantan_area' |'banjar_area' |'molluca_area' |'spice_islands_area' |'lesser_sunda_islands_area' |'timor_area' |'makassar_area' |'sulawesi_area' |'south_sulawesi_area' |'pyongan_area' |'hamgyeong_area' |'western_korea_area' |'eastern_korea_area' |'south_korea_area' |'hokkaido_area' |'hokuriku_area' |'kanto_area' |'eastern_kanto_area' |'kyushu_area' |'northern_kyushu' |'shikoku_area' |'eastern_chubu_area' |'chubu_area' |'kinai_area' |'thohoku_area' |'sanindo_area' |'saigoku_area' |'kamchatka_area' |'kolyma_area' |'okhotsk_area' |'yakutia_area' |'sakha_area' |'buryatia_area' |'tunguska_area' |'central_siberia_area' |'kara_area' |'ob_area' |'irkutsk_area' |'perm_area' |'balchasj_area' |'kazakhstan_area' |'syr_darya_area' |'yrtesh_area' |'ishim_area' |'aqmola_area' |'heilongjiang_area' |'east_heilongjiang_area' |'central_heilongjiang_area' |'cicigar_area' |'ilan_hala_area' |'sakhalin_area' |'central_jilin_area' |'ningguta_area' |'furdan_area' |'jilin_area' |'liaoning_area' |'ordos_area' |'eastern_mongolia' |'chahar_area' |'inner_mongolia_area' |'outer_mongolia_area' |'xilin_gol_area' |'altai_sayan_area' |'tannu_uriankhai_area' |'central_mongolia_area' |'uliastai_area' |'jetysuu_area' |'kashgaria_area' |'tarim_basin_area' |'shanshan_area' |'turpan_kumul_area' |'zungaria_area' |'amdo_area' |'tsang_area' |'north_zungaria' |'kham_area' |'utsang_area' |'ngari_area' |'hebei_area' |'south_hebei_area' |'shandong_area' |'jiangsu_area' |'south_jiangsu_area' |'anhui_area' |'south_anhui_area' |'zhejiang_area' |'jiangxi_area' |'fujian_area' |'taiwan_area' |'guangdong_area' |'west_guangdong_area' |'guangxi_area' |'yun_gui_area' |'yun_gui_borderland_area' |'sichuan_area' |'chuannan_area' |'chuanbei_area' |'huguang_area' |'hunan_area' |'henan_area' |'north_henan_area' |'shanxi_area' |'shaanxi_area' |'gansu_area' |'west_gansu_area' |'rio_grande_do_sol_area' |'minas_gerais_area' |'diamantina_area' |'goias_area' |'pontal_area' |'mato_grosso_area' |'ofaie_area' |'guapore_area' |'sao_paolo_area' |'west_sao_paolo_area' |'rio_de_janeiro_area' |'bahia_area' |'pernambuco_area' |'ceara_area' |'sao_francisco_area' |'maranhao_area' |'piaui_area' |'grao_para_area' |'amapa_area' |'amazon_area' |'paraguay_area' |'patagonia_area' |'bahia_blanca_area' |'patagonian_andes' |'cuyo_area' |'nehuenken_area' |'southern_pampas_area' |'buenos_aires_area' |'misiones_area' |'tucuman_area' |'jujuy_area' |'chaco_area' |'banda_oriental_area' |'guyana_area' |'suriname_area' |'upper_guyana_area' |'quito_area' |'iquitos_area' |'venezuela_area' |'maracaibo_area' |'eastern_llanos' |'western_llanos' |'central_llanos_area' |'bogota_area' |'popayan_area' |'colombian_amazonas_area' |'cordillera_occidental_area' |'coquivacoa_area' |'northern_chile_area' |'central_chile_area' |'southern_chile_area' |'antisuyu_area' |'kuntisuyu_area' |'peruan_coast' |'chimor_area' |'ucayali_area' |'cajamarca_area' |'huanuco_area' |'beni_area' |'moxos_area' |'upper_peru' |'potosi_area' |'great_woods_area' |'maine_area' |'eastern_maine_area' |'massachusetts_bay_area' |'connecticut_valley_area' |'hudson_valley_area' |'new_york_area' |'delaware_valley_area' |'iroquoisia_area' |'south_iroquoisia_area' |'susquehanna_area' |'westsylvania_area' |'maryland_area' |'chesapeake_area' |'great_valley_area' |'piedmont_north_america_area' |'carolinas_area' |'south_carolina_area' |'south_carolina_piedmont_area' |'american_georgia_area' |'upper_american_georgia_area' |'florida_area' |'north_florida_area' |'appalachia_area' |'south_appalachia_area' |'west_florida_area' |'mississippi_area' |'choctaw_area' |'alabama_area' |'kentucky_area' |'western_kentucky_area' |'ohio_country_area' |'miami_river_area' |'illinois_country_area' |'southern_illinois_area' |'mississippi_plain_area' |'michigan_area' |'lake_superior_area' |'wisconsin_area' |'lower_louisiana_area' |'upper_louisiana_area' |'ozarks_area' |'iowa_area' |'lower_plains_area' |'central_plains_area' |'kansas_area' |'high_plains_area' |'dakota_area' |'south_dakota_area' |'minnessota_area' |'upper_missouri_area' |'badlands_area' |'llano_estacado_area' |'coastal_prarie_area' |'texas_area' |'texas_plains_area' |'oregon_area' |'columbia_river_area' |'snake_river_area' |'salish_sea_area' |'interior_plateau_area' |'hecate_strait_area' |'alaska_area' |'east_alaska_area' |'lower_acadia_area' |'straits_of_georgia_area' |'upper_acadia_area' |'st_john_valley_area' |'newfoundland_area' |'labrador_area' |'cote_nord_area' |'notre_dame_mountains_area' |'lower_canada_area' |'trois_rivieres_area' |'upper_canada_area' |'laurentian_area' |'upper_ontario_area' |'huronia_area' |'ottawa_valley_area' |'james_bay_area' |'inner_ontario_area' |'hudson_bay_area' |'red_river_area' |'manitoba_area' |'assiniboia_area' |'saskatchewan_area' |'prairies_area' |'athabasca_area' |'northeast_mexico_area' |'durango_area' |'chihuahua_area' |'pecos_area' |'rio_grande_area' |'sonora_area' |'new_mexico_area' |'apacheria_area' |'colorado_plateau_area' |'arizona_area' |'california_area' |'central_valley_area' |'northern_california_area' |'baja_california_area' |'jalisco_area' |'nayarit_area' |'michoacan_area' |'tierra_caliente_area' |'gran_chichimeca_area' |'guanajuato_area' |'zacatecas_area' |'mexico_area' |'puebla_area' |'guerrero_area' |'oaxaca_area' |'mixteca_area' |'eastern_mexico_area' |'huasteca_area' |'chiapas_area' |'yucatan_area' |'east_yucatan_area' |'campeche_area' |'guatemala_area' |'guatemala_lowlands_area' |'honduras_area' |'nicaragua_area' |'costa_rica_area' |'panama_area' |'cuba_area' |'east_cuba_area' |'hispaniola_area' |'dominica_area' |'greater_antilles_area' |'lucayan_area' |'leeward_islands_area' |'windward_islands_area' |'transvaal_area' |'pomerelia_area' |'sonora_y_sinaloa_area' |'magadan_area' |'netherlands_area' |'indonesian_islands_area' |'iceland_area' |'south_laos_area';

cb_types
:'cb_restore_personal_union'
|'cb_hundred_years_war'
|'cb_defection'
|'cb_loan_cancelled'
|'cb_spy_discovered'
|'cb_disloyal_vassal'
|'cb_hre_attacked'
|'cb_insult'
|'cb_dishonored_call'
|'cb_vassalize_mission'
|'cb_fabricated_claims'
|'cb_religious_conformance'
|'cb_border_war'
|'cb_trade_war_triggered'
|'cb_trade_conflict'
|'cb_trade_league_conflict'
|'cb_annex'
|'cb_change_government'
|'cb_change_government_great_peasants_war'
|'cb_peasants_war_for_peasants'
|'cb_humiliate'
|'cb_conquest'
|'cb_core'
|'cb_independence_war'
|'cb_colonial_independance_war'
|'cb_nationalist'
|'cb_imperial'
|'cb_hegemon'
|'cb_war_against_the_world'
|'cb_daimyo_annex'
|'cb_independent_daimyo_annex'
|'cb_shogun_annex'
|'cb_sengoku'
|'cb_revolutionary'
|'cb_colonial'
|'cb_liberation'
|'cb_crusade'
|'cb_crusade_pheasants'
|'cb_defender_of_the_faith'
|'cb_heretic'
|'cb_excommunication'
|'cb_trade_war'
|'cb_trade_league_dispute'
|'cb_imperial_ban'
|'cb_liberate_elector'
|'cb_super_badboy'
|'cb_claim_throne'
|'cb_horde_vs_civ'
|'cb_tribal_feud'
|'cb_revoke_electorate'
|'cb_privateers'
|'cb_support_rebels'
|'cb_crush_the_revolution'
|'cb_spread_the_revolution'
|'cb_religious_league'
|'cb_flower_wars'
|'cb_maya_expansion'
|'cb_humiliate_rotw'
|'cb_chinese_unification'
|'cb_take_mandate'
|'cb_forced_break_alliance'
|'cb_force_tributary'
|'cb_force_tributary_mission'
|'cb_hundred_years_union'
|'cb_force_join_hre'
|'cb_reintegrate_into_hre'
|'cb_imperial_realm_war'
|'cb_world_crusade'
|'cb_vassalize_majapahit'
|'cb_vassalize_malacca'
|'cb_sword_of_islam'
|'cb_force_migration'
|'cb_native_american_tribal_feud'
|'cb_push_back_colonizers';

technology_groups
:'western'
|'eastern'
|'ottoman'
|'muslim'
|'indian'
|'east_african'
|'central_african'
|'chinese'
|'nomad_group'
|'sub_saharan'
|'north_american'
|'mesoamerican'
|'south_american'
|'andean'
|'aboriginal_tech'
|'polynesian_tech'
|'high_american';

continents
:'europe'
|'asia'
|'africa'
|'north_america'
|'south_america'
|'oceania'
|'island_check_provinces'
|'new_world';

super_regions
: 'india_superregion'
| 'east_indies_superregion'
| 'oceania_superregion'
| 'china_superregion'
| 'europe_superregion'
| 'eastern_europe_superregion'
| 'tartary_superregion'
| 'far_east_superregion'
| 'africa_superregion'
| 'southern_africa_superregion'
| 'south_america_superregion'
| 'andes_superregion'
| 'north_america_superregion'
| 'central_america_superregion'
| 'near_east_superregion'
| 'persia_superregion'
| 'new_world_superregion'
| 'west_american_sea_superregion'
| 'east_american_sea_superregion'
| 'north_european_sea_superregion'
| 'south_european_sea_superregion'
| 'west_african_sea_superregion'
| 'east_african_sea_superregion'
| 'indian_pacific_sea_superregion'
| 'north_pacific_sea_superregion';

trade_goods
:'grain'
|'wine'
|'wool'
|'cloth'
|'fish'
|'fur'
|'salt'
|'naval_supplies'
|'copper'
|'gold'
|'iron'
|'slaves'
|'ivory'
|'tea'
|'chinaware'
|'spices'
|'coffee'
|'cotton'
|'sugar'
|'tobacco'
|'cocoa'
|'silk'
|'dyes'
|'tropical_wood'
|'livestock'
|'incense'
|'glass'
|'paper'
|'gems'
|'coal'
|'cloves'
|'unknown';

estates
: 'estate_brahmins'
| 'estate_church'
| 'estate_maratha'
| 'estate_nobles'
| 'estate_burghers'
| 'estate_vaisyas'
| 'estate_cossacks'
| 'estate_nomadic_tribes'
| 'estate_dhimmi'
| 'estate_jains'
| 'estate_rajput';

governments
: 'monarchy'
| 'republic'
| 'theocracy'
| 'tribal'
| 'stateless_society'
| 'kongo_tribal_kingdom'
| 'kongo_monarchy_kingdom'
| 'islamic_caliphate'
| 'revolutionary_peasant_republic'
| 'revolutionary_spanish_republic'
| 'revolutionary_swedish_republic'
| 'revolutionary_danish_republic'
| 'revolutionary_ottoman_republic'
| 'revolutionary_german_republic'
| 'gov_revolutionary_republic'
| 'gov_polish_republic'
| 'gov_german_empire'
| 'gov_prussian_republic'
| 'gov_admiralty'
| 'gov_english_commonwealth'
| 'savonarola_unique'
| 'military_dictatorship'
| 'greek_pirate_government'
| 'pirate_daimyo_government'
| 'pirate_government'
| 'pirate_kingdom'
| 'synthetic_nation'
| 'yuan_empire'
| 'ilkhanate_march'
| 'celestial_parliament'
| 'ottoman_marches'
| 'ottoman_vassals'
| 'march_christian_monarchy'
| 'gov_papal_government_elector'
| 'palatine_electorate'
| 'palatine_monarchy'
| 'herzegovina_monarchy'
| 'holy_roman_electors_monarchy'
| 'holy_roman_electors_bishoprics'
| 'holy_roman_electors_republic'
| 'japanese_shogunate'
| 'islamic_syncretism_kingdoms'
| 'french_kingdom'
| 'sharifs_of_mecca'
| 'avar_nutsals'
| 'georgian_monarchy'
| 'dais_of_najran'
| 'malian_monarchy'
| 'arabic_tribal'
| 'muslim_tribal'
| 'kathiawar_tribal_monarchy'
| 'sistan_monarchy'
| 'persian_monarchy'
| 'somali_monarchy'
| 'lithuanian_monarchy'
| 'cristopher_of_bavaria_monarchy'
| 'hunyadi_regent_monarchy'
| 'austrian_monarchy'
| 'turkish_monarchy'
| 'theodoro_monarchy'
| 'croatian_monarchy'
| 'finnish_monarchy'
| 'grand_duchy_of_tuscany'
| 'grand_duchy_of_baden'
| 'grand_duchy_of_luxembourg'
| 'serbian_feudal_monarchy'
| 'serbian_monarchy'
| 'byzantine_monarchy'
| 'greek_monarchy'
| 'arakanese_monarchy'
| 'pangasinan_monarchy'
| 'albanian_monarchy'
| 'qing_monarchy'
| 'egyptian_monarchy'
| 'scanian_peasant_republic'
| 'pagan_egyptian_monarchy'
| 'pagan_greek_monarchy'
| 'pagan_roman_monarchy'
| 'jurchen_monarchy'
| 'romanian_monarchy'
| 'hyderabad_state_monarchy'
| 'muslim_indian_monarchy'
| 'bharat_monarchy'
| 'hindu_rajput_monarchy'
| 'maratha_peshwas'
| 'hindu_maratha_monarchy'
| 'kaffa_monarchy'
| 'ethiopian_monarchies'
| 'nkore_monarchy'
| 'bunyoro_monarchy'
| 'lunda_monarchy'
| 'mutapa_monarchy'
| 'torwa_monarchy'
| 'rwanda_burundi_monarchy'
| 'ganda_monarchy'
| 'antemoro_monarchy'
| 'betsimisaraka_monarchy'
| 'filipino_rajanate'
| 'shan_monarchy'
| 'burman_monarchy'
| 'barangay_polity'
| 'south_slavic_monarchy'
| 'irish_peerage_monarchy'
| 'irish_clan_monarchy'
| 'hebridean_monarchy'
| 'muscovite_monarchy'
| 'russian_monarchy'
| 'russian_feudal_monarchy'
| 'inti_monarchy'
| 'mayan_monarchy'
| 'nahuatl_monarchy'
| 'chinese_monarchy'
| 'hindu_monarchy'
| 'buddhist_monarchy'
| 'muslim_monarchy'
| 'german_free_city'
| 'gov_free_city'
| 'iberian_colonial_government'
| 'dutch_colonial_government'
| 'zaporozhian_republic'
| 'ragusan_republic'
| 'dutch_republic'
| 'russian_republic'
| 'south_slavic_republic'
| 'florentine_republic'
| 'ambrosian_republic'
| 'german_republic'
| 'italian_republic'
| 'hindu_republic'
| 'buddhist_noble_republic'
| 'muslim_republic'
| 'march_eastern_christian_monarchy'
| 'gov_steppe_horde'
| 'gov_native_council'
| 'gov_colonial_government'
| 'federal_monarchy_statists'
| 'federal_monarchy_monarchists'
| 'noble_republic'
| 'gov_republican_dictatorship'
| 'gov_bureaucratic_despotism'
| 'gov_papal_government'
| 'gov_daimyo'
| 'gov_indep_daimyo'
| 'gov_shogunate'
| 'gov_tribal_kingdom'
| 'gov_tribal'
| 'gov_tribal_democracy'
| 'gov_constitutional_republic'
| 'hre_county'
| 'ikko_ikki_peasants'
| 'ikko_ikki_temple'
| 'asian_monastic_order'
| 'northerner_king_monastic_order'
| 'northerner_monastic_order'
| 'teutonic_monastic_order'
| 'livonian_monastic_order'
| 'germanic_monastic_order'
| 'brewing_order'
| 'jewish_theocracy'
| 'zoroastrian_theocracy'
| 'sikh_theocracy'
| 'hindu_theocracy'
| 'shinto_theocracy'
| 'buddhist_theocracy'
| 'confucian_theocracy'
| 'ibadi_theocracy'
| 'yemenite_theocracy'
| 'shiite_theocracy'
| 'uyghur_theocracy'
| 'sunni_theocracy'
| 'orthodox_theocracy'
| 'inti_theocracy'
| 'pagan_theocracy'
| 'gov_religious_order'
| 'sisters_crusader_state';

buildings
: 'marketplace'
| 'workshop'
| 'temple'
| 'barracks'
| 'shipyard'
| 'coastal_defence'
| 'courthouse'
| 'dock'
| 'regimental_camp'
| 'naval_battery'
| 'cathedral'
| 'university'
| 'trade_depot'
| 'grand_shipyard'
| 'training_fields'
| 'stock_exchange'
| 'counting_house'
| 'town_hall'
| 'drydock'
| 'conscription_center'
| 'manufactory'
| 'wharf'
| 'weapons'
| 'textile'
| 'plantations'
| 'tradecompany'
| 'farm_estate'
| 'mills'
| 'furnace'
| 'ramparts'
| 'soldier_households'
| 'impressment_offices'
| 'state_house'
| 'native_earthwork'
| 'native_palisade'
| 'native_fortified_house'
| 'native_ceremonial_fire_pit'
| 'native_irrigation'
| 'native_storehouse'
| 'native_longhouse'
| 'native_sweat_lodge'
| 'native_great_trail'
| 'native_three_sisters_field';

ages
: 'age_of_discovery'
| 'age_of_reformation'
| 'age_of_absolutism'
| 'age_of_revolutions';

institutions
:'feudalism'
| 'renaissance'
| 'new_world_i'
| 'printing_press'
| 'global_trade'
| 'manufactories'
| 'enlightenment'
| 'industrialization';

cultures:
  'pommeranian'
| 'prussian'
| 'lower_saxon'
| 'hannoverian'
| 'hessian'
| 'saxon'
| 'franconian'
| 'swabian'
| 'swiss'
| 'bavarian'
| 'austrian'
| 'dutch'
| 'flemish'
| 'frisian'
| 'swedish'
| 'danish'
| 'norwegian'
| 'finnish'
| 'sapmi'
| 'icelandic'
| 'english'
| 'american'
| 'welsh'
| 'cornish'
| 'scottish'
| 'irish'
| 'highland_scottish'
| 'lombard'
| 'tuscan'
| 'sardinian'
| 'romagnan'
| 'ligurian'
| 'venetian'
| 'dalmatian'
| 'neapolitan'
| 'piedmontese'
| 'umbrian'
| 'sicilian'
| 'maltese'
| 'castillian'
| 'mexican'
| 'platinean'
| 'leonese'
| 'aragonese'
| 'catalan'
| 'galician'
| 'andalucian'
| 'portugese'
| 'brazilian'
| 'basque'
| 'cosmopolitan_french'
| 'gascon'
| 'normand'
| 'aquitaine'
| 'burgundian'
| 'occitain'
| 'wallonian'
| 'louisianans'
| 'quebecois'
| 'breton'
| 'uralic'
| 'samoyed'
| 'ostyaki'
| 'ingrian'
| 'croatian'
| 'serbian'
| 'slovene'
| 'bosnian'
| 'bulgarian'
| 'albanian'
| 'czech'
| 'polish'
| 'schlesian'
| 'sorbian'
| 'slovak'
| 'transylvanian'
| 'romanian'
| 'hungarian'
| 'russian'
| 'novgorodian'
| 'ryazanian'
| 'byelorussian'
| 'ruthenian'
| 'karelian'
| 'estonian'
| 'lithuanian'
| 'latvian'
| 'greek'
| 'pontic_greek'
| 'goths'
| 'georgian'
| 'circassian'
| 'dagestani'
| 'armenian'
| 'turkish'
| 'al_misr_arabic'
| 'al_suryah_arabic'
| 'al_iraqiya_arabic'
| 'gulf_arabic'
| 'bedouin_arabic'
| 'mahri_culture'
| 'hejazi_culture'
| 'omani_culture'
| 'yemeni_culture'
| 'moroccan'
| 'tunisian'
| 'algerian'
| 'berber'
| 'persian'
| 'luri'
| 'azerbaijani'
| 'khorasani'
| 'baluchi'
| 'kurdish'
| 'mazandarani'
| 'mongol'
| 'chahar'
| 'khalkha'
| 'oirats'
| 'uzbehk'
| 'turkmeni'
| 'uyghur'
| 'khazak'
| 'kirgiz'
| 'aztek'
| 'totonac'
| 'purepecha'
| 'matlatzinca'
| 'tecos'
| 'tepic'
| 'chichimecan'
| 'guamares'
| 'otomi'
| 'yaqui'
| 'yucatec'
| 'putun'
| 'mayan'
| 'highland_mayan'
| 'lacandon'
| 'wastek'
| 'chontales'
| 'zapotek'
| 'mixtec'
| 'tlapanec'
| 'inca'
| 'aimara'
| 'diaguita'
| 'chimuan'
| 'tupinamba'
| 'guarani'
| 'charruan'
| 'ge'
| 'jivaro'
| 'chachapoyan'
| 'muisca'
| 'cara'
| 'miskito'
| 'chacoan'
| 'mapuche'
| 'patagonian'
| 'het'
| 'huarpe'
| 'arawak'
| 'maipurean'
| 'carib'
| 'guajiro'
| 'aleutian'
| 'inuit'
| 'shawnee'
| 'illini'
| 'miami'
| 'anishinabe'
| 'algonquin'
| 'cree'
| 'innu'
| 'mesquakie'
| 'cheyenne'
| 'blackfoot'
| 'arapaho'
| 'plains_cree'
| 'bungi'
| 'delaware'
| 'abenaki'
| 'mikmaq'
| 'maliseet'
| 'mahican'
| 'powhatan'
| 'pequot'
| 'massachusset'
| 'iroquois'
| 'cherokee'
| 'huron'
| 'laurentian'
| 'tionontate'
| 'susquehannock'
| 'dakota'
| 'nakota'
| 'chiwere'
| 'osage'
| 'wichita'
| 'caddo'
| 'pawnee'
| 'creek'
| 'choctaw'
| 'chickasaw'
| 'yuchi'
| 'yoron'
| 'catawba'
| 'natchez'
| 'yamasee'
| 'pueblo'
| 'piman'
| 'shoshone'
| 'kiowa'
| 'apache'
| 'mescalero'
| 'lipan'
| 'navajo'
| 'chipewyan'
| 'haida'
| 'athabascan'
| 'salish'
| 'chinook'
| 'yokuts'
| 'vietnamese_new'
| 'korean_new'
| 'tibetan_new'
| 'altaic_new'
| 'country'
| 'province'
| 'manchu_new'
| 'country'
| 'province'
| 'chihan'
| 'cantonese'
| 'jin'
| 'wu'
| 'chimin'
| 'hakka'
| 'gan'
| 'xiang'
| 'sichuanese'
| 'jianghuai'
| 'xibei'
| 'hubei'
| 'zhongyuan'
| 'shandong_culture'
| 'korean'
| 'togoku'
| 'japanese'
| 'kyushuan'
| 'tibetan'
| 'yi'
| 'bai'
| 'miao'
| 'malayan'
| 'sumatran'
| 'acehnese'
| 'javanese'
| 'sundanese'
| 'filipino'
| 'bornean'
| 'madagascan'
| 'sulawesi'
| 'moluccan'
| 'nusa_tenggara'
| 'cham'
| 'central_thai'
| 'northern_thai'
| 'lao'
| 'shan'
| 'zhuang'
| 'khmer'
| 'mon'
| 'vietnamese'
| 'burmese'
| 'chin'
| 'karen'
| 'kachin'
| 'arakanese'
| 'papuan'
| 'maori'
| 'melanesian'
| 'polynesian'
| 'aboriginal'
| 'yura'
| 'paman'
| 'gunwinyguan'
| 'palawa'
| 'kulin'
| 'gamilaraay'
| 'nyoongah'
| 'assamese'
| 'bengali'
| 'kochi'
| 'bihari'
| 'pahari'
| 'nepali'
| 'oriya'
| 'sinhala'
| 'avadhi'
| 'kanauji'
| 'vindhyan'
| 'panjabi'
| 'kashmiri'
| 'gujarati'
| 'parsi'
| 'saurashtri'
| 'marathi'
| 'sindhi'
| 'rajput'
| 'malvi'
| 'kannada'
| 'malayalam'
| 'tamil'
| 'telegu'
| 'gondi'
| 'garjati'
| 'jharkhandi'
| 'mali'
| 'songhai'
| 'soninke'
| 'bambara'
| 'bozo'
| 'dyola'
| 'hausa'
| 'kanuri'
| 'bilala'
| 'tunjur'
| 'tuareg'
| 'senegambian'
| 'fulani'
| 'yorumba'
| 'aka'
| 'nupe'
| 'fon'
| 'mossi'
| 'dagomba'
| 'makua'
| 'nguni'
| 'bemba'
| 'khoisan'
| 'shona'
| 'nyasa'
| 'lunda'
| 'luba'
| 'kongolese'
| 'yaka'
| 'kuba'
| 'mbundu'
| 'chokwe'
| 'mbangala'
| 'jukun'
| 'sawabantu'
| 'rwandan'
| 'ganda'
| 'masaba'
| 'madagasque'
| 'takama'
| 'bena'
| 'bantu'
| 'swahili'
| 'somali'
| 'harari'
| 'afar'
| 'oromo'
| 'tigray'
| 'sidamo'
| 'amhara'
| 'acholi'
| 'nubian'
| 'beja'
| 'evenk'
| 'yakut'
| 'yukagyr'
| 'buryat'
| 'tungus'
| 'manchu'
| 'country'
| 'province'
| 'ainu'
| 'kamchatkan'
| 'nivkh'
| 'astrakhani'
| 'bashkir'
| 'crimean'
| 'kazani'
| 'mishary'
| 'nogaybak'
| 'siberian'
| 'atlantean'
| 'spartan'
| 'athenian'
| 'old_egyptian'
| 'roman'
| 'jan_mayenese'
| 'pruthenian'
| 'phoenician'
| 'scanian'
| 'anglosaxon'
| 'babylonian'
| 'etrurian'
| 'parthian'
| 'aramaic'
| 'hebrew'
| 'scythian';

culture_groups
: 'germanic'
| 'scandinavian'
| 'british'
| 'gaelic'
| 'latin'
| 'iberian'
| 'french'
| 'finno_ugric'
| 'south_slavic'
| 'west_slavic'
| 'carpathian'
| 'east_slavic'
| 'baltic'
| 'byzantine'
| 'caucasian'
| 'turko_semitic'
| 'maghrebi'
| 'iranian'
| 'altaic'
| 'central_american'
| 'aridoamerican'
| 'maya'
| 'otomanguean'
| 'andean_group'
| 'je_tupi'
| 'je'
| 'maranon'
| 'chibchan'
| 'mataco'
| 'araucanian'
| 'carribean'
| 'eskaleut'
| 'central_algonquian'
| 'plains_algonquian'
| 'eastern_algonquian'
| 'iroquoian'
| 'siouan'
| 'caddoan'
| 'muskogean'
| 'sonoran'
| 'apachean'
| 'na_dene'
| 'penutian'
| 'east_asian'
| 'korean_g'
| 'japanese_g'
| 'tibetan_group'
| 'malay'
| 'thai_group'
| 'southeastasian_group'
| 'burman'
| 'pacific'
| 'aboriginal_australian'
| 'eastern_aryan'
| 'hindusthani'
| 'western_aryan'
| 'dravidian'
| 'central_indic'
| 'mande'
| 'sahelian'
| 'west_african'
| 'southern_african'
| 'kongo_group'
| 'great_lakes_group'
| 'african'
| 'cushitic'
| 'sudanese'
| 'evenks'
| 'kamchatkan_g'
| 'tartar'
| 'lost_cultures_group';

religions
: 'catholic'
| 'anglican'
| 'hussite'
| 'protestant'
| 'reformed'
| 'orthodox'
| 'coptic'
| 'sunni'
| 'shiite'
| 'ibadi'
| 'buddhism'
| 'vajrayana'
| 'mahayana'
| 'confucianism'
| 'shinto'
| 'hinduism'
| 'sikhism'
| 'animism'
| 'shamanism'
| 'totemism'
| 'inti'
| 'nahuatl'
| 'mesoamerican_religion'
| 'norse_pagan_reformed'
| 'tengri_pagan_reformed'
| 'dreamtime';

dlcs
: '"Conquest of Paradise"'
| '"Wealth of Nations"'
| '"Res Publica"'
| '"Art of War"'
| '"El Dorado"'
| '"Common Sense"'
| '"Star and Crescent"'
| '"The Cossacks"'
| '"Mare Nostrum"'
| '"Rights of Man"'
| '"Mandate of Heaven"'
| '"Third Rome"'
| '"Rule Britannia"'
| '"Cradle of Civilization"'
| '"Dharma"'
| '"Emperor"'
| '"Golden Century"'
| '"Leviathan"'
| '"Origins"'
| '"American Dream"'
| '"Purple Phoenix"';


religion_groups
: 'christian'
| 'muslim'
| 'eastern'
| 'dharmic'
| 'pagan'
| 'jewish_group'
| 'zoroastrian_group';
adm_advisor_types
: 'philosopher'
| 'natural_scientist'
| 'artist'
| 'treasurer'
| 'theologian'
| 'master_of_mint'
| 'inquisitor';
dip_advisor_types
: 'statesman'
| 'naval_reformer'
| 'trader'
| 'spymaster'
| 'colonial_governor'
| 'diplomat'
| 'navigator';
mil_advisor_types
: 'army_reformer'
| 'army_organiser'
| 'commandant'
| 'quartermaster'
| 'recruitmaster'
| 'fortification_expert'
| 'grand_captain';

