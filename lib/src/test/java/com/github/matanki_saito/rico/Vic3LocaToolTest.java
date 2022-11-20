package com.github.matanki_saito.rico;

import org.assertj.core.api.SoftAssertions;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(SoftAssertionsExtension.class)
class Vic3LocaToolTest {

    @Test
    void yamlToolTest(SoftAssertions softAssertions) throws Exception {
        var yaml = PdxLocaYamlTool
                .parse(getFromResources("core_l_japanese.yml"));
        softAssertions
                .assertThat(yaml.getLanguage())
                .isEqualTo("japanese");

        var no36 = yaml.getRecords().get(36);
        softAssertions
                .assertThat(no36.getKey())
                .isEqualTo("INTEREST_GROUP_STATE_TOOLTIP");
        softAssertions.assertThat(no36.getVersion()).isEqualTo(1);
        softAssertions.assertThat(no36.getComment()).isNull();
        softAssertions.assertThat(no36.getBody())
                .isEqualTo("#variable [STATE.GetName]#!の#variable [INTEREST_GROUP.GetName]#!\\n[concept_political_strength]: #variable [INTEREST_GROUP.GetPoliticalStrengthInState(STATE.Self)|D]#!\\n$TOOLTIP_DELIMITER$\\n[Concept('concept_pop','$concept_population$')]: #variable [INTEREST_GROUP.GetPopulationInState(STATE.Self)|D]#!");
    }

    @Test
    void vic3LocaTest(SoftAssertions softAssertions) throws Exception {
        var yaml = PdxLocaYamlTool
                .parse(getFromResources("core_l_japanese.yml"));

        for(var r : yaml.getRecords()){
            var result = Vic3LocaTool.validate(r.getBody());
            softAssertions.assertThat(result).isEqualTo("");
        }
   }

    @Test
    void vic3LocaTestItem(SoftAssertions softAssertions) throws Exception {
        var yaml = PdxLocaYamlTool
                .parse(getFromResources("core_l_japanese.yml"));

        var no36 = yaml.getRecords().get(36);
        var v = Vic3LocaTool.convertStringToJson(no36.getBody(),true);
        softAssertions.assertThat(v).isEqualTo("");
    }

    @Test
    void vic3LocaFolderTest(SoftAssertions softAssertions) throws Exception {

        // Steam default Vic3 JP localization path
        try (Stream<Path> paths = Files.walk(Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\game\\localization\\japanese"))) {
            for(var f : paths.filter(Files::isRegularFile).toList()){
                System.out.println(f.getFileName());
                var yaml = PdxLocaYamlTool.parse(f);

                for(var r : yaml.getRecords()){
                    var result = Vic3LocaTool.validate(r.getBody());
                    softAssertions.assertThat(result).isEqualTo("");
                    if(!result.equals("")){
                        System.out.println(" " + r.getKey() + "\n" + result);
                    }
                }
            }
        }
    }

    private Path getFromResources(String name) throws URISyntaxException {
        ClassLoader classLoader = getClass().getClassLoader();
        var url = classLoader.getResource(name);
        if (url == null) {
            throw new IllegalArgumentException("url is null");
        }

        return Paths.get(url.toURI());
    }
}