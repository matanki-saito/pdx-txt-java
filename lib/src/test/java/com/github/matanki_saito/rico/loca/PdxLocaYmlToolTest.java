package com.github.matanki_saito.rico.loca;

import org.apache.commons.lang3.tuple.Pair;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

@ExtendWith(SoftAssertionsExtension.class)
class PdxLocaYmlToolTest {

    //@Test
    void eu4JpMod() throws Exception {
        var index = "eu4";
        Path eu4JpMod = Paths.get("C:\\repo\\EU4JPModAppendixI\\source\\localisation");

        var source = new LocalSource(Pair.of(index, eu4JpMod));
        var filter = PdxLocaFilter.builder().indecies(List.of(index)).fileNames(List.of("dharma_l_english.yml")).build();

        internal(index, source, filter);
    }

    //@Test
    void ck3JpMod() throws Exception {
        var index = "ck3";
        Path ck3JpMod = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization");
        Path ck3jomini = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Crusader Kings III\\jomini\\localization");
        Path ck3English = Paths.get("C:\\repo\\Ck3JpMod\\source\\localization\\english");

        var source = new LocalSource(Pair.of(index, ck3jomini), Pair.of(index, ck3JpMod));
        var filter = PdxLocaFilter.builder().indecies(List.of(index)).fileNames(List.of("court_positions_l_english.yml")).build();

        internal(index, source, filter);
    }

    //@Test
    void vic3JpMod() throws Exception {
        var index = "vic3";
        Path common = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\game\\localization\\jomini\\script_system");
        Path vic3jomini = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\jomini\\localization");
        Path vic3Japanese = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Victoria 3\\game\\localization\\japanese");

        var source = new LocalSource(Pair.of(index, common), Pair.of(index, vic3jomini), Pair.of(index, vic3Japanese));
        var filter = PdxLocaFilter.builder().indecies(List.of(index)).fileNames(List.of("content_101_l_japanese.yml")).build();

        internal(index, source, filter);
    }


    private void internal(String index, LocalSource source, PdxLocaFilter filter) throws Exception {

        var pattern = new PdxLocaMatchPattern();
        var tool = PdxLocaYmlTool.builder().debug(true).build();
        var result = tool.normalize(source, pattern, filter);

        result.forEach((key, value) -> {
            System.out.printf("<%s>%n", key);
            System.out.println(value);
            System.out.println("------");
        });

        List.of(Pair.of("variable", tool.getVars()),
                Pair.of("scope", tool.getScopes()),
                Pair.of("segment", tool.getSegments())
        ).forEach(x -> {
            System.out.printf("<%s>%n", x.getLeft());
            x.getRight().entrySet().stream()
                    .sorted(Map.Entry.comparingByValue(Comparator.reverseOrder()))
                    .toList()
                    .stream()
                    .filter(item -> switch (x.getLeft()) {
                        case "variable" ->
                                !pattern.matchVariablePattern(List.of(index), item.getKey().replace(".", "="));
                        case "scope" -> !pattern.matchScopePattern(List.of(index), item.getKey().replace(".", "="));
                        default -> true;
                    })
                    .forEach(item -> System.out.printf("%s:%d%n",
                            item.getKey(),
                            item.getValue()));
        });
    }

}