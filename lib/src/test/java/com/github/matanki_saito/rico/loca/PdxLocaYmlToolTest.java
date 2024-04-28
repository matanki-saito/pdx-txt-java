package com.github.matanki_saito.rico.loca;

import org.apache.commons.lang3.tuple.Pair;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.extension.ExtendWith;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

@ExtendWith(SoftAssertionsExtension.class)
class PdxLocaYmlToolTest {
    private final Path ck3jomini = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Crusader Kings III\\jomini\\localization");
    private final Path ck3Target = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization\\english");

    private final Path eu4JpModLocaTarget = Paths.get("C:\\repo\\EU4JPModAppendixI\\source\\localisation");

    private final Path ck3JpMod = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization");

    private final Path vic3Target = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\game\\localization\\japanese");

    //@Test
    void normalizeFile() throws Exception {
        var source = new LocalSource(Pair.of("ck3", ck3jomini), Pair.of("ck3", ck3JpMod));
        var pattern = new PdxLocaMatchPattern();
        var filter = PdxLocaFilter.builder()
                .fileNames(List.of("core_l_english.yml")).indecies(List.of("ck3")).build();

        var result = PdxLocaYmlTool.builder().build().normalize(source, pattern, filter);

        result.forEach((key, value) -> System.out.printf("KEY=%s,\nVALUE=%s%n", key, value));
    }

    //@Test
    void extractIconTextOnEu4JpMod() throws Exception {
        var source = new LocalSource(Pair.of("eu4", eu4JpModLocaTarget));
        var filter = PdxLocaFilter.builder().indecies(List.of("eu4")).build();
        var pattern = new PdxLocaMatchPattern(true);
        var tool = PdxLocaYmlTool.builder().debug(true).build();
        var result = tool.normalize(source, pattern, filter);

//        tool.getScopes().entrySet().stream()
//                .sorted(Map.Entry.comparingByValue(Comparator.reverseOrder()))
//                .toList()
//                .stream()
//                .filter(item -> !pattern.matchPattern(List.of("eu4"), item.getKey().replace(".", "=")))
//                .forEach(item -> System.out.printf("%s:%d%n",
//                        item.getKey(),
//                        item.getValue()));

        tool.getIcon2s().entrySet().stream()
                .sorted(Map.Entry.comparingByValue(Comparator.reverseOrder()))
                .toList()
                .forEach(item -> System.out.printf("%s:%d%n",
                        item.getKey(),
                        item.getValue()));

    }

    //@Test
    void extractIconTextOnEu4JpMod1() throws Exception {
        LocalSource source = new LocalSource(Pair.of("eu4", eu4JpModLocaTarget));
        var filter = PdxLocaFilter.builder().indecies(List.of("eu4")).build();
        PdxLocaMatchPattern pattern = new PdxLocaMatchPattern();
        var tool = PdxLocaYmlTool.builder().debug(true).build();
        var result = tool.normalize("CONFIRM_CENTRALIZE_STATE_TEXT", source, pattern, filter);
        System.out.print(result);
        //tool.getIcons().forEach(key -> System.out.printf("%s%n", key));
        //tool.getSegments().forEach(key -> System.out.printf("%s%n", key));
        //tool.getVars().forEach(key -> System.out.printf("%s%n", key));

    }

}