package com.github.matanki_saito.rico;

import static com.jayway.jsonpath.JsonPath.using;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

import org.yaml.snakeyaml.Yaml;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.util.DefaultIndenter;
import com.fasterxml.jackson.core.util.DefaultPrettyPrinter;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.MachineException;
import com.github.matanki_saito.rico.exception.SystemException;
import com.jayway.jsonpath.Configuration;
import com.jayway.jsonpath.JsonPath;
import com.jayway.jsonpath.Option;

import lombok.experimental.UtilityClass;

@UtilityClass
public class PatchTool {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public Object patchByYaml(Path targetGameDirectoryRootPath,
                              Path patchYamlFilePath,
                              Path exportDirectoryPath) throws IOException {
        // yaml to POJO
        Yaml yaml = new Yaml();

        var data = yaml.loadAs(
                Files.newBufferedReader(patchYamlFilePath), PatchObject.class);

        // seek game directory
        data.getPatch()
            .forEach((filePath, value) -> {
                patchFor(targetGameDirectoryRootPath.toAbsolutePath(),
                         filePath,
                         exportDirectoryPath,
                         value);
            });

        return data;
    }

    private void patchFor(Path rootPath, String filePath, Path exportDirectoryPath,
                          Map<String, Object> data) {
        try {
            var txtData = PdxTxtTool.convertTxtToJson(Paths.get(rootPath.toString(), filePath), false);
            var dst = JsonPath.parse(txtData);

            data.forEach((jsonPath, value) -> {
                String patchData;
                try {
                    patchData = objectMapper.writeValueAsString(value);
                } catch (JsonProcessingException e) {
                    throw new IllegalArgumentException(e);
                }
                dst.set(jsonPath, patchData);
            });

            var patchedFile = Paths.get(exportDirectoryPath.toString(), filePath);

            Files.createDirectories(patchedFile.getParent());
            Files.writeString(patchedFile, PdxTxtTool.convertJsonToTxt(dst.jsonString()));

        } catch (IOException | SystemException | ArgumentException e) {
            throw new IllegalArgumentException(e);
        }
    }

    public String extract(Path targetGameDirectoryRootPath,
                          Pattern matchPathPattern,
                          String jsonPath) throws MachineException {

        Map<String, Object> map = new HashMap<>();

        try {
            Files.walkFileTree(targetGameDirectoryRootPath, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult visitFile(Path filePath, BasicFileAttributes attrs) {
                    var pathStr = filePath.toAbsolutePath().toString();

                    var relativePath = targetGameDirectoryRootPath.relativize(filePath);

                    var m = matchPathPattern.matcher(pathStr);
                    if (m.find()) {
                        try {
                            step(filePath, jsonPath).ifPresent(x -> map.put(relativePath.toString(), x));
                        } catch (ArgumentException e) {
                            throw new IllegalArgumentException(e);
                        } catch (SystemException e) {
                            throw new IllegalStateException(e);
                        }
                    }
                    return FileVisitResult.CONTINUE;
                }
            });

            DefaultPrettyPrinter prettyPrinter = new DefaultPrettyPrinter();
            prettyPrinter.indentArraysWith(DefaultIndenter.SYSTEM_LINEFEED_INSTANCE);

            Yaml yaml = new Yaml();
            return yaml.dump(Map.of("patch", map));

        } catch (IOException e) {
            throw new MachineException("", e);
        }
    }

    private Optional<Object> step(Path path, String jsonPath) throws SystemException, ArgumentException {
        var result = new HashMap<>();

        var json = PdxTxtTool.convertTxtToJson(path.toAbsolutePath(), false);

        List<Object> data = using(Configuration.builder()
                                               .options(Option.SUPPRESS_EXCEPTIONS, Option.ALWAYS_RETURN_LIST)
                                               .build()).parse(json)
                                                        .read(jsonPath);

        if (data == null || data.isEmpty()) {
            return Optional.empty();
        }

        List<String> meta = using(Configuration.builder()
                                               .options(Option.AS_PATH_LIST)
                                               .build()).parse(json)
                                                        .read(jsonPath);

        for (var index = 0; index < meta.size(); index++) {
            result.put(meta.get(index), data.get(index));
        }

        return Optional.of(result);
    }
}
