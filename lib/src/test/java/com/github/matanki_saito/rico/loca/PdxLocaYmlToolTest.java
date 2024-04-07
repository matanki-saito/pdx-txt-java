package com.github.matanki_saito.rico.loca;

import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.nio.file.Path;
import java.nio.file.Paths;

@ExtendWith(SoftAssertionsExtension.class)
class PdxLocaYmlToolTest {
    private final Path ck3jomini = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Crusader Kings III\\jomini\\localization");
    private final Path ck3Target = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization\\english");

    private final Path ck3JpMod = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization");

    private final Path vic3Target = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\game\\localization\\japanese");

    @Test
    void normalizeFile() throws Exception {
        var source = new LocalSource(ck3jomini, ck3JpMod);
        var pattern = new PdxLocaMatchPattern();

        var result = PdxLocaYmlTool.normalizeFile("core_l_english.yml", source, pattern);

        result.forEach((key, value) -> System.out.printf("KEY=%s,\nVALUE=%s%n", key, value));
    }
}