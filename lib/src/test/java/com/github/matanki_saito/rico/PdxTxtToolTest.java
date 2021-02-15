package com.github.matanki_saito.rico;

import java.nio.file.Paths;

import org.assertj.core.api.SoftAssertions;
import org.assertj.core.api.junit.jupiter.SoftAssertionsExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

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
}
