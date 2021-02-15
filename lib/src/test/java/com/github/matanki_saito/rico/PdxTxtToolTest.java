package com.github.matanki_saito.rico;

import static org.junit.jupiter.api.Assertions.assertThrows;

import java.nio.file.Files;
import java.nio.file.Paths;

import org.assertj.core.api.SoftAssertions;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.github.matanki_saito.rico.exception.PdxParseException;

@ExtendWith(SoftAssertionsExtension.class)
class PdxTxtToolTest {

    @Test
    void convertJson(SoftAssertions softAssertions) throws Exception {
        ClassLoader classLoader = getClass().getClassLoader();
        var url = classLoader.getResource("test.txt");
        if (url == null) {
            return;
        }

        var json = PdxTxtTool.convertJson(Paths.get(url.toURI()), true);

        // Files.writeString(Paths.get("test.json"), json);

        softAssertions.assertThat(json).isNotNull();
    }

    @Test
    void convertTxt(SoftAssertions softAssertions) throws Exception {
        ClassLoader classLoader = getClass().getClassLoader();
        var url = classLoader.getResource("test.json");
        if (url == null) {
            return;
        }

        var txt = PdxTxtTool.convertTxt(Paths.get(url.toURI()));

        // Files.writeString(Paths.get("test.reverse.txt"), txt);

        softAssertions.assertThat(txt).isNotNull();
    }

    @Test
    void convertJsonThrowsException(SoftAssertions softAssertions) throws Exception {
        ClassLoader classLoader = getClass().getClassLoader();
        var url = classLoader.getResource("errortest.txt");
        if (url == null) {
            return;
        }

        var exp = assertThrows(PdxParseException.class, () -> {
            PdxTxtTool.convertJson(Paths.get(url.toURI()), true);
        });

        softAssertions.assertThat(exp.getLine()).isEqualTo(5);
        softAssertions.assertThat(exp.getCharPosition()).isEqualTo(8);
        softAssertions.assertThat(exp.getMessage()).isNotNull();
    }

}
