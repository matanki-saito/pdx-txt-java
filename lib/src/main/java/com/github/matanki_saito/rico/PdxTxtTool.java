/*
 * This Java source file was generated by the Gradle 'init' task.
 */
package com.github.matanki_saito.rico;

import java.io.IOException;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.matanki_saito.rico.antlr.PdxLexer;
import com.github.matanki_saito.rico.antlr.PdxParser;
import com.github.matanki_saito.rico.antlr.PdxParser.ArrayContext;
import com.github.matanki_saito.rico.antlr.PdxParser.ElementContext;
import com.github.matanki_saito.rico.antlr.PdxParser.KeyValueContext;
import com.github.matanki_saito.rico.antlr.PdxParser.PrimitiveContext;
import com.github.matanki_saito.rico.antlr.PdxParser.RootContext;
import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.MachineException;
import com.github.matanki_saito.rico.exception.PdxParseException;
import com.github.matanki_saito.rico.exception.SystemException;
import com.github.matanki_saito.rico.exception.ThrowingErrorListener;

import lombok.experimental.UtilityClass;

/**
 * Paradox txt tool
 * <p>
 * ツール
 */
@UtilityClass
public class PdxTxtTool {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * ParadoxTxtFormat to Json
     *
     * @param txtFile txt file path
     * @param pretty is pretty json
     *
     * @return Json
     *
     * @throws SystemException other system exception
     * @throws ArgumentException argument error
     */
    public static String convertTxtToJson(Path txtFile, boolean pretty)
            throws SystemException, ArgumentException {

        CharStream charStream;
        try {
            charStream = CharStreams.fromPath(txtFile);
        } catch (IOException e) {
            throw new MachineException("IO exception", e);
        }

        return innerConvertJson(charStream, pretty);
    }

    public static String convertTxtToJson(String txt, boolean pretty)
            throws ArgumentException, SystemException {
        CharStream charStream = CharStreams.fromString(txt);
        return innerConvertJson(charStream, pretty);
    }

    /**
     * Json to ParadoxTxtFormat
     *
     * @param jsonFile json file path
     *
     * @return ParadoxTxt
     *
     * @throws ArgumentException argument error
     */
    public static String convertJsonToTxt(Path jsonFile) throws ArgumentException {
        try {
            Object data = objectMapper.readValue(jsonFile.toFile(), Object.class);
            return decompile(data, 0);
        } catch (IOException e) {
            throw new ArgumentException("json error", e);
        }
    }

    /**
     * Json to ParadoxTxtFormat
     *
     * @param jsonString json string
     *
     * @return ParadoxTxt
     *
     * @throws ArgumentException argument error
     */
    public static String convertJsonToTxt(String jsonString) throws ArgumentException {
        try {
            Object data = objectMapper.readValue(jsonString, Object.class);
            return decompile(data, 0);
        } catch (IOException e) {
            throw new ArgumentException("json error", e);
        }
    }

    private static String toJson(RootContext tree, boolean prettyPrint) throws SystemException {
        var map = compile(tree);
        try {
            return prettyPrint ? objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(map)
                               : objectMapper.writeValueAsString(map);
        } catch (JsonProcessingException e) {
            throw new SystemException("json exception", e);
        }
    }

    private static String decompile(Object data, int depth) {
        final int incrementedDepth = depth + 1;
        final String indent = StringUtils.repeat(" ", depth);

        if (data instanceof List<?> arrayList) {
            var joiningListText = arrayList.stream()
                                           .map(x -> indent + decompile(x, incrementedDepth))
                                           .collect(Collectors.joining("\n"));

            if (depth == 0) { // root
                return joiningListText;
            } else {
                return "{%n%s%n%s}".formatted(joiningListText, StringUtils.repeat(" ", depth - 2));
            }

        }

        if (data instanceof String string) {
            return string;
        }

        if (data instanceof Number number) {
            return number.toString();
        }

        if (data instanceof Map<?, ?> map) {
            var first = map
                    .entrySet()
                    .stream()
                    .findFirst();

            if (first.isPresent()) {
                var key = first.get().getKey().toString();
                var sKey = key.split("\\|");

                return "%s %s %s".formatted(
                        sKey.length > 1 ? sKey[0] : key,
                        sKey.length > 1 ? sKey[1] : "=",
                        decompile(first.get().getValue(), incrementedDepth)
                );
            }
        }

        throw new IllegalArgumentException();
    }

    private static Object compile(ParseTree tree) {
        if (tree instanceof RootContext rootContext) {
            return rootContext
                    .elements
                    .stream()
                    .map(PdxTxtTool::compile)
                    .collect(Collectors.toList());
        }

        if (tree instanceof ElementContext elementContext) {
            return compile(elementContext.getChild(0));
        }

        if (tree instanceof ArrayContext arrayContext) {
            return arrayContext
                    .elements
                    .stream()
                    .map(PdxTxtTool::compile)
                    .collect(Collectors.toList());
        }

        if (tree instanceof PrimitiveContext primitiveContext) {
            return primitiveContext.getChild(0).getText();
        }

        if (tree instanceof KeyValueContext keyValueContext) {
            var key = keyValueContext.key().getChild(0).toString();
            var operator = keyValueContext.nameSeparator().getChild(0).toString();
            return Map.of(
                    operator.equals("=") ? key : "%s|%s".formatted(key, operator),
                    compile(keyValueContext.value().getChild(0))
            );
        }

        return null;
    }

    private String innerConvertJson(CharStream charStream, boolean pretty)
            throws SystemException, ArgumentException {
        var listener = new ThrowingErrorListener();

        var lexer = new PdxLexer(charStream);
        lexer.removeErrorListeners();
        lexer.addErrorListener(listener);
        var tokens = new CommonTokenStream(lexer);
        var parser = new PdxParser(tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(listener);

        var tree = parser.root();

        if (listener.getExceptions().isEmpty()) {
            return toJson(tree, pretty);
        } else {
            throw new PdxParseException("", listener.getExceptions());
        }
    }

}
