package com.github.matanki_saito.rico.loca;

import org.assertj.core.api.SoftAssertions;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.nio.file.Path;
import java.nio.file.Paths;

@ExtendWith(SoftAssertionsExtension.class)
class PdxLocaYmlToolTest {
    private final Path ck3Target = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Crusader Kings III\\game\\localization\\english");
    private final Path vic3Target = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\game\\localization\\japanese");

    @Test
    void load(SoftAssertions softAssertions) throws Exception {
        var source = new LocalSource(vic3Target);
        softAssertions.assertThat(source).isNotNull();
    }

    @Test
    void validation() throws Exception {
        var source = new LocalSource(vic3Target);
        source.validation("core_l_japanese.yml");
    }

    @Test
    void normalize() throws Exception {
        var source = new LocalSource(vic3Target);
        var key = "acw_events.7.t";
        System.out.println(source.get(key).getBody());
        var result = PdxLocaYmlTool.normalize(key, source);
        System.out.println(result);
    }

    @Test
    void normalizeFile() throws Exception {
        var source = new LocalSource(vic3Target);
        source.normalize("companies_l_japanese.yml");
    }
}