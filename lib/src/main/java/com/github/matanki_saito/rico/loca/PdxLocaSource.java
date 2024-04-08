package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.SystemException;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

public interface PdxLocaSource {
    PdxLocaYamlRecord get(String key) throws ArgumentException, SystemException;

    List<String> getKeys() throws ArgumentException, SystemException;

    boolean exists(String key);

    void apply(PdxLocaSourceFilter filter);

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

    @AllArgsConstructor
    @NoArgsConstructor
    @Data
    @Builder(toBuilder = true)
    class PdxLocaSourceFilter {
        private List<String> fileNames;
        private List<String> indecies;
    }
}
