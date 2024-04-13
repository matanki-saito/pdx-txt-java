package com.github.matanki_saito.rico.loca;

import org.apache.commons.lang3.tuple.Pair;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@ExtendWith(SoftAssertionsExtension.class)
class PdxLocaYmlToolTest {
    private final Path ck3jomini = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Crusader Kings III\\jomini\\localization");
    private final Path ck3Target = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization\\english");

    private final Path ck3JpMod = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization");

    private final Path vic3Target = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\game\\localization\\japanese");

    //@Test
    void normalizeFile() throws Exception {
        var source = new LocalSource(Pair.of("ck3", ck3jomini), Pair.of("ck3", ck3JpMod));
        var pattern = new PdxLocaMatchPattern();
        var filter = PdxLocaFilter.builder()
                .fileNames(List.of("core_l_english.yml")).indecies(List.of("ck3")).build();

        var result = PdxLocaYmlTool.normalize(source, pattern, filter);

        result.forEach((key, value) -> System.out.printf("KEY=%s,\nVALUE=%s%n", key, value));
    }
}