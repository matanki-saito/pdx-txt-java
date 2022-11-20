package com.github.matanki_saito.rico;

import com.github.matanki_saito.rico.exception.MachineException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.UtilityClass;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

@UtilityClass
public class PdxLocaYamlTool {
    static Pattern language = Pattern.compile("l_(\\w+):$");
    static Pattern record = Pattern.compile("^\\s*([\\w-.$]+):(\\d+)\\s+\"(.*)(?<!\\\\)\"(\\s*#\\s*(.*))?$");

    @AllArgsConstructor
    @NoArgsConstructor
    @Data
    static class PdxLocaYaml{
        private String language = "";
        private List<PdxLocaYamlRecord> records = new ArrayList<>();

        @AllArgsConstructor
        @NoArgsConstructor
        @Data
        static class PdxLocaYamlRecord{
            private String key = "";
            private Integer version = 0;
            private String body = "";
            private String comment = "";
            private Integer line = 0;
        }
    }

    public PdxLocaYaml parse(Path path) throws MachineException {
        var result = new PdxLocaYaml();
        try {
            var allLines = Files.readAllLines(path);
            for (var col = 0; col<allLines.size(); col++ ){
                var line = allLines.get(col);
                var m = language.matcher(line);
                if(m.find()){
                    result.setLanguage(m.group(1));
                    continue;
                }
                m = record.matcher(line);
                if(m.find()){
                    result.records.add(new PdxLocaYaml.PdxLocaYamlRecord(
                            m.group(1),
                            Integer.parseInt(m.group(2)),
                            m.group(3),
                            m.group(5),
                            col + 1
                    ));
                }
            }
        } catch (IOException e) {
            throw new MachineException("IO exception", e);
        }

        return result;
    }
}
