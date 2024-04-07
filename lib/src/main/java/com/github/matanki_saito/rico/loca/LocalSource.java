package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.MachineException;
import com.github.matanki_saito.rico.exception.SystemException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class LocalSource implements PdxLocaSource {
    private static final Pattern language = Pattern.compile("l_(\\w+):$");

    // 拡張子は必ずyml
    private static final Pattern fileYml = Pattern.compile(".*\\.yml$");

    private static final Pattern record = Pattern.compile("^\\s*([\\w-.$]+):(\\d*)\\s+\"(.*)(?<!\\\\)\"(\\s*#\\s*(.*))?$");

    private final Map<String, PdxLocaYamlRecord> data = new HashMap<>();

    public LocalSource(Path... locaRootDirs) throws MachineException {
        for (var locaRootDir : locaRootDirs) {
            try (Stream<Path> paths = Files.walk(locaRootDir)) {
                for (var file : paths.filter(target -> {
                    // locaDirにはReadMe.txtがあったりするのでそれを除去
                    return Files.isRegularFile(target) && fileYml.matcher(target.toString()).matches();
                }).toList()) {
                    // locaファイルの拡張子はymlだがyamlの定義には従っていないので自分でparseする必要がある
                    for (var record : parse(file)) {
                        // keyの重複は原則ないがもし存在した場合はversionを基準とする
                        // versionが存在しない場合は上書き
                        data.computeIfPresent(record.getKey(), (k, v) ->
                                record.getVersion() != null && v.getVersion() != null && record.getVersion() > v.getVersion() ? record : v
                        );
                        data.putIfAbsent(record.getKey(), record);
                    }
                }
            } catch (IOException e) {
                throw new MachineException("ファイルの列挙途中で異常が発生", e);
            }
        }
    }

    private static List<PdxLocaYamlRecord> parse(Path path) throws MachineException {
        var result = new ArrayList<PdxLocaYamlRecord>();
        try {
            var allLines = Files.readAllLines(path);
            for (var col = 0; col < allLines.size(); col++) {
                var line = allLines.get(col);
                var m = language.matcher(line);
                if (m.find()) {
                    continue;
                }
                m = record.matcher(line);
                if (m.find()) {
                    result.add(new LocalSource.PdxLocaYamlRecord(
                            m.group(1),
                            m.group(2).isBlank() ? null : Integer.parseInt(m.group(2)),
                            m.group(3),
                            m.group(5),
                            col + 1,
                            path.getFileName().toString()
                    ));
                }
            }
        } catch (IOException e) {
            throw new MachineException("ファイルの読み込み途中で異常が発生", e);
        }

        return result;
    }

    @Override
    public PdxLocaYamlRecord get(String key) throws ArgumentException {
        if (!data.containsKey(key)) {
            throw new ArgumentException("keyは存在しません");
        }

        return data.get(key);
    }

    @Override
    public List<String> getKeys(String fileName) throws ArgumentException {
        return data.values()
                .stream()
                .filter(pdxLocaYamlRecord -> pdxLocaYamlRecord.getFileName().equals(fileName))
                .map(PdxLocaYamlRecord::getKey)
                .toList();
    }

    @Override
    public boolean exists(String key) {
        return data.containsKey(key);
    }

    public void validation() throws SystemException {
        validation(null);
    }

    /**
     * エラーを標準出力に出力
     *
     * @throws SystemException システム例外
     */
    public void validation(String fileName) {
        data.entrySet()
                .stream()
                .filter(record -> fileName == null || record.getValue().getFileName().equals(fileName))
                .forEach(record -> {
                    var object = new LocaAnalyzedObject(record.getValue().getBody());
                    if (object.getListener().getExceptions().isEmpty()) {
                        return;
                    }

                    var errorMessage = object.getListener().getExceptions().stream().map(exception ->
                            String.format("%s:%s:%s: %s",
                                    record.getValue().getFileName(),
                                    record.getValue().getLine(),

                                    exception.charPositionInLine()
                                            // key:1 "xxxx
                                            //^^^^^^^^ offset
                                            + 1 // head space
                                            + record.getKey().length()
                                            + (record.getValue().getVersion() == null
                                            ? 0
                                            : record.getValue().getVersion().toString().length())
                                            + 1 // space
                                            + 1, // "
                                    exception.message())
                    ).collect(Collectors.joining("\n"));

                    System.out.println(errorMessage);
                });
    }
}
