package com.github.matanki_saito.rico;

import com.github.matanki_saito.rico.exception.PdxParseException;
import com.jayway.jsonpath.JsonPath;
import org.assertj.core.api.SoftAssertions;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Pattern;

import static org.junit.jupiter.api.Assertions.assertThrows;

@ExtendWith(SoftAssertionsExtension.class)
class PdxTxtToolTest {
    @Test
    void validate(SoftAssertions softAssertions) throws Exception {
        var src = getFromResources("error.txt");
        var result= PdxTxtTool.validate(src);
        var ex = """
            build\\resources\\test\\error.txt:2:17: no viable alternative at input '{expiration_days!'
            build\\resources\\test\\error.txt:2:17: extraneous input '!' expecting {WRAP_STRING, NUMBER, DATE_TIME, 'false', 'true', 'null', 'yes', 'no', KEY_LEVEL_STRING, '{', '}'}""";
        softAssertions.assertThat(result).isEqualTo(ex);
    }
    @Test
    void validateAll(SoftAssertions softAssertions) throws Exception {
        var src = getFromResources("error.txt");
        PdxTxtTool.validateAllToSystemOut(Path.of("C:\\repo\\linttest"),Pattern.compile("\\.txt"));
    }
    @Test
    void convertJson(SoftAssertions softAssertions) throws Exception {
        var src = getFromResources("test.txt");
        var json = PdxTxtTool.convertTxtToJson(src, true);
        // Files.writeString(Paths.get("test.json"), json);
        softAssertions.assertThat(json).isNotNull();
    }

    @Test
    void convertJson2(SoftAssertions softAssertions) throws Exception {
        var src = getFromResources("test2.txt");
        var json = PdxTxtTool.convertTxtToJson(src, true);
        softAssertions.assertThat(json).isNotNull();
    }
    @Test
    void convertTxt(SoftAssertions softAssertions) throws Exception {
        var src = getFromResources("test.json");
        var txt = PdxTxtTool.convertJsonToTxt(src);
        // Files.writeString(Paths.get("test.reverse.txt"), txt);
        softAssertions.assertThat(txt).isNotNull();
    }

    @Test
    void convertJsonThrowsException(SoftAssertions softAssertions) throws Exception {
        var src = getFromResources("errortest.txt");

        var exp = assertThrows(PdxParseException.class, () -> {
            PdxTxtTool.convertTxtToJson(src, true);
        });

        softAssertions.assertThat(exp.getExceptions().get(0).line()).isEqualTo(5);
        softAssertions.assertThat(exp.getExceptions().get(0).charPositionInLine()).isEqualTo(8);
        softAssertions.assertThat(exp.getMessage()).isNotNull();
    }

    @Test
    void setJson(SoftAssertions softAssertions) throws Exception {
        ClassLoader classLoader = getClass().getClassLoader();
        var url = classLoader.getResource("test.json");
        if (url == null) {
            return;
        }

        String newJson = JsonPath
                .parse(Paths.get(url.toURI()).toFile())
                .set("$..color", "[1,2,4]")
                .jsonString();

        softAssertions.assertThat(newJson).isEqualTo("[{\"activity_feast\":[{\"expiration_days\":\"300\"},{\"has_activity_window\":\"yes\"},{\"days_until_auto_start\":\"20\"},{\"frame\":\"2\"},{\"color\":\"[1,2,4]\"},{\"valid\":[{\"activity_owner\":[{\"is_alive\":\"yes\"},{\"is_imprisoned\":\"no\"}]}]}]}]");
    }

    //@Test
    void extract(SoftAssertions softAssertions) throws Exception {
        Path root = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Crusader Kings III\\game");
        Pattern pattern = Pattern.compile("[^\\\\]*common\\\\culture\\\\cultures\\\\[^\\\\]*\\.txt$");

        var result = PatchTool.extract(root, pattern, "$..female_names");
        Files.writeString(Paths.get("extract.yaml"), result);

        softAssertions.assertThat(result).isNotNull();
    }

    //@Test
    void patch(SoftAssertions softAssertions) throws Exception {
        Path root = Paths.get("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Crusader Kings III\\game");
        Path patch = getFromResources("extract.yaml");
        Path export = Paths.get("./export");

        PatchTool.patchByYaml(root, patch, export);
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
