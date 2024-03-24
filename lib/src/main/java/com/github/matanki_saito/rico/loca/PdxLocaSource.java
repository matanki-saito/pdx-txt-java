package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.exception.ArgumentException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

public interface PdxLocaSource {
    PdxLocaYamlRecord get(String key) throws ArgumentException;

    boolean exists(String key);

    @AllArgsConstructor
    @NoArgsConstructor
    @Data
    class PdxLocaYamlRecord {
        private String key = "";
        private Integer version = 0;
        private String body = "";
        private String comment = "";
        private Integer line = 0;
        private String fileName = "";
    }
}
