package com.github.matanki_saito.rico;

import com.github.matanki_saito.rico.loca.PdxLocaYmlTool;
import org.assertj.core.api.SoftAssertions;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;

@ExtendWith(SoftAssertionsExtension.class)
class Vic3LocaToolTest {

//    @Test
//    void yamlToolTest(SoftAssertions softAssertions) throws Exception {
//        var yaml = PdxLocaYmlTool
//                .parse(getFromResources("core_l_japanese.yml"));
//        softAssertions
//                .assertThat(yaml.getLanguage())
//                .isEqualTo("japanese");
//
//        var no36 = yaml.getRecords().get(36);
//        softAssertions
//                .assertThat(no36.getKey())
//                .isEqualTo("INTEREST_GROUP_STATE_TOOLTIP");
//        softAssertions.assertThat(no36.getVersion()).isEqualTo(1);
//        softAssertions.assertThat(no36.getComment()).isNull();
//        softAssertions.assertThat(no36.getBody())
//                .isEqualTo("#variable [STATE.GetName]#!の#variable [INTEREST_GROUP.GetName]#!\\n[concept_political_strength]: #variable [INTEREST_GROUP.GetPoliticalStrengthInState(STATE.Self)|D]#!\\n$TOOLTIP_DELIMITER$\\n[Concept('concept_pop','$concept_population$')]: #variable [INTEREST_GROUP.GetPopulationInState(STATE.Self)|D]#!");
//    }
//
//    @Test
//    void vic3LocaTest(SoftAssertions softAssertions) throws Exception {
//        var yaml = Vic3LocaTool.validate(getFromResources("core_l_japanese.yml"));
//        softAssertions.assertThat(yaml).isNotBlank();
//    }
//
//    @Test
//    void normalize(SoftAssertions softAssertions) throws Exception {
//        var yaml = PdxLocaYmlTool
//                .parse(getFromResources("core_l_japanese.yml"));
//
//        var no36 = yaml.getRecords().get(4);
//        System.out.println(no36);
//        var v = Vic3LocaTool.normalize(no36.getBody());
//        System.out.println(v);
//        softAssertions.assertThat(v).isNotBlank();
//    }
//
//    private Path getFromResources(String name) throws URISyntaxException {
//        ClassLoader classLoader = getClass().getClassLoader();
//        var url = classLoader.getResource(name);
//        if (url == null) {
//            throw new IllegalArgumentException("url is null");
//        }
//
//        return Paths.get(url.toURI());
//    }
}