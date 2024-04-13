package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.SystemException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

public interface PdxLocaSource {
    PdxLocaYamlRecord get(String key, PdxLocaFilter filter) throws ArgumentException, SystemException;

    List<String> getKeys(PdxLocaFilter filter) throws ArgumentException, SystemException;

    boolean exists(String key, PdxLocaFilter filter);

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
        private String indexName = "";
    }
}
