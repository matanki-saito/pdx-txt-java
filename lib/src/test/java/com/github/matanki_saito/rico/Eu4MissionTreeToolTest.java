package com.github.matanki_saito.rico;

import org.assertj.core.api.SoftAssertions;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(SoftAssertionsExtension.class)
class Eu4MissionTreeToolTest {

//    @Test
//    void validate(SoftAssertions softAssertions) throws Exception {
//        var src = getFromResources("DH_Timurid_Missions.txt");
//        var result= Eu4MissionTreeTool.validate(src);
//        var ex = "";
//        softAssertions.assertThat(result).isEqualTo(ex);
//    }
//
//    // ブルゴーニュのミッションはelseのカッコが間違っているのと数字がダブルクオーテーションで囲まれているミスがある。
//    @Test
//    void validateError(SoftAssertions softAssertions) throws Exception {
//        var src = getFromResources("EMP_Burgundian_Missions.txt");
//        var result= Eu4MissionTreeTool.validate(src);
//        var ex = """
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:144:4: extraneous input 'else' expecting {'potential', 'desc', 'tooltip', 'custom_tooltip', 'hidden_effect', 'country_event', 'add_country_modifier', 'add_accepted_culture', 'add_adm_power', 'add_dip_power', 'add_mil_power', 'set_government_rank', 'add_prestige', 'add_stability_or_adm_power', 'add_stability', 'change_estate_land_share', 'add_estate_loyalty_modifier', 'add_liberty_desire', 'free_vassal', 'vassalize', 'add_legitimacy', 'add_imperial_influence', 'set_in_empire', 'add_power_projection', 'add_sailors', 'add_treasury', 'add_navy_tradition', 'add_years_of_income', 'change_innovativeness', 'unlock_estate_privilege', 'change_government_reform_progress', 'add_army_professionalism', 'add_church_power', 'add_piety', 'create_colony_mission_reward', 'add_permanent_claim', 'set_country_flag', 'add_core', 'add_army_tradition', 'add_opinion', 'reverse_add_opinion', 'add_papal_influence', 'increase_legitimacy_small_effect', 'define_general', 'create_general', 'add_mercantilism', 'add_casus_belli', 'add_yearly_sailors', 'define_advisor', 'unlock_merc_company', 'add_years_of_owned_provinces_production_income', 'unlock_cult_through_selection', 'enable_cult_switching_mission', 'every_subject_country', 'capital_scope', 'random_owned_province', 'every_province', 'every_country', 'any_owned_province', 'any_province', 'every_owned_province', 'if', 'AND', 'NOT', 'OR', 'calc_true_if', '0', '1', '2', '3', '4', '5', '6', INT, TAG, '}', ROOT, REGION_X, AREA_X}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:148:3: extraneous input 'add_country_modifier' expecting {'icon', 'required_missions', 'provinces_to_highlight', 'trigger', 'effect', 'position', 'completed_by', 'ai_weight', 'ai_priority', '}'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:150:4: extraneous input 'duration' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:150:15: mismatched input '"7300"' expecting '{'
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:151:3: mismatched input '}' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:153:4: mismatched input 'limit' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:160:4: mismatched input 'limit' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:167:4: mismatched input 'limit' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:176:2: mismatched input 'icon' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:177:2: extraneous input 'required_missions' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:177:24: mismatched input 'emp_bur_cisjurania' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:177:43: mismatched input '}' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:183:6: extraneous input 'area' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:183:13: mismatched input 'lombardy_area' expecting '{'
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:184:6: extraneous input 'area' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:184:13: mismatched input 'po_valley_area' expecting '{'
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:185:5: mismatched input '}' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:192:9: extraneous input 'area' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:192:16: mismatched input 'lombardy_area' expecting '{'
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:193:9: extraneous input 'area' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:193:16: mismatched input 'po_valley_area' expecting '{'
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:194:8: mismatched input '}' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:210:5: extraneous input 'area' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:210:12: mismatched input 'lombardy_area' expecting '{'
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:211:5: extraneous input 'area' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:211:12: mismatched input 'po_valley_area' expecting '{'
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:212:4: mismatched input '}' expecting '='
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:218:4: mismatched input 'limit' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:225:4: mismatched input 'limit' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:232:4: mismatched input 'limit' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}
//                build\\resources\\test\\EMP_Burgundian_Missions.txt:239:4: mismatched input 'limit' expecting {'slot', 'generic', 'ai', 'potential_on_load', 'potential', 'has_country_shield'}""";
//        softAssertions.assertThat(result).isEqualTo(ex);
//    }

    private Path getFromResources(String name) throws URISyntaxException {
        ClassLoader classLoader = getClass().getClassLoader();
        var url = classLoader.getResource(name);
        if (url == null) {
            throw new IllegalArgumentException("url is null");
        }

        return Paths.get(url.toURI());
    }
}