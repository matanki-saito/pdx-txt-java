package com.github.matanki_saito.rico;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.matanki_saito.rico.antlr.Vic3LocaLexer;
import com.github.matanki_saito.rico.antlr.Vic3LocaParser;
import com.github.matanki_saito.rico.exception.*;
import com.ibm.icu.impl.Pair;
import lombok.experimental.UtilityClass;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Vic3のlocalizationのためのツール
 */
@UtilityClass
public class Vic3LocaTool {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 対象のフォルダルートを再帰的に辿ってエラーを標準出力に出力
     *
     * @param root 対象のフォルダルート
     * @param matchPathPattern 一致例外
     * @throws SystemException システム例外
     */
    public static void validateAllToSystemOut(Path root, Pattern matchPathPattern)
            throws SystemException {
        ToolBase.validateAllToSystemOut(root, matchPathPattern, path -> {
            try {
                return validate(path);
            } catch (SystemException e) {
                throw new RuntimeException(e);
            }
        });
    }

    /**
     * Validate file
     *
     * @param ymlFilePath path
     * @return %f:%l:%c: %m\n
     * @throws SystemException err
     */
    public String validate(Path ymlFilePath) throws SystemException, MachineException {
        var file = PdxLocaYamlTool.parse(ymlFilePath);

        return file
                .getRecords()
                .stream()
                .map(record-> Pair.of(generateContext(CharStreams.fromString(record.getBody())),record))
                .filter(pair -> !pair.first.listener.getExceptions().isEmpty())
                .map(pair -> pair.first
                            .listener
                            .getExceptions()
                            .stream()
                            .map(x->String.format("%s:%s:%s: %s",
                                    Paths.get("").toAbsolutePath().relativize(ymlFilePath.toAbsolutePath()),
                                    pair.second.getLine(),
                                    x.charPositionInLine()
                                            + 1 // head space : 1,
                                            + pair.second.getKey().length()
                                            + pair.second.getVersion().toString().length()
                                            + 1 // space
                                            + 1 // "
                                    ,
                                    x.message()))
                            .collect(Collectors.joining("\n"))
                )
                .collect(Collectors.joining("\n"));
    }

    /**
     * Validate txt
     *
     * @param text source
     * @return %f:%l:%c: %m\n
     * @throws SystemException err
     */
    public String validate(String text) throws SystemException, MachineException {
        var charStream = CharStreams.fromString(text);
        var context = generateContext(charStream);

        if (context.listener.getExceptions().isEmpty()) {
            return "";
        } else {
            return context
                    .listener
                    .getExceptions()
                    .stream()
                    .map(x->String.format("%s:%s:%s: %s",
                            "-",
                            x.line(),
                            x.charPositionInLine(),
                            x.message()))
                    .collect(Collectors.joining("\n"));
        }
    }

    /**
     * ParadoxVic3LocaFormat to Json
     *
     * @param text text data
     * @param pretty is pretty json
     *
     * @return Json
     *
     * @throws SystemException other system exception
     * @throws ArgumentException argument error
     */
    public static String convertStringToJson(String text, boolean pretty)
            throws SystemException, ArgumentException {

        var charStream = CharStreams.fromString(text);

        return innerConvertJson(charStream, pretty);
    }

    /**
     * Context record
     * @param tree ツリー
     * @param listener リスナー
     */
    public record TxtContext(Vic3LocaParser.RootContext tree, ThrowingErrorListener listener) { }

    private Vic3LocaTool.TxtContext generateContext(CharStream charStream){
        var listener = new ThrowingErrorListener();

        var lexer = new Vic3LocaLexer(charStream);
        lexer.removeErrorListeners();
        lexer.addErrorListener(listener);
        var tokens = new CommonTokenStream(lexer);
        var parser = new Vic3LocaParser(tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(listener);

        return new Vic3LocaTool.TxtContext(parser.root(),listener);
    }

    private String innerConvertJson(CharStream charStream, boolean pretty)
            throws SystemException, ArgumentException {

        var context = generateContext(charStream);

        if (context.listener.getExceptions().isEmpty()) {
            return toJson(context.tree, pretty);
        } else {
            throw new PdxParseException("", context.listener.getExceptions());
        }
    }

    private static Object compile(ParseTree tree) {
        if (tree instanceof Vic3LocaParser.RootContext rootContext) {
            return compile(rootContext.sections());
        }

        if (tree instanceof Vic3LocaParser.SectionsContext sectionsContext) {
            return sectionsContext
                    .section()
                    .stream()
                    .map(Vic3LocaTool::compile)
                    .toList()
                    .stream()
                    .map(List::of)
                    .reduce((u, v) -> v.get(0) instanceof String vvs && u.get(u.size()-1) instanceof String uls
                            ? Stream.concat(u.subList(0,u.size()-1).stream(),Stream.of(uls + vvs)).toList()
                            : Stream.concat(u.stream(),v.stream()).toList())
                    .stream()
                    .findAny()
                    .orElse(List.of());
        }

        if (tree instanceof Vic3LocaParser.SectionContext sectionContext) {
            return compile(sectionContext.getChild(0));
        }

        // id : Alphabet + Number + _
        if(tree instanceof Vic3LocaParser.IdContext idContext){
            return idContext.getText();
        }

        // tag: #xxx ~~~ #!
        if(tree instanceof Vic3LocaParser.TagContext tagContext){
            return Map.of(
                    "type", "tag",
                    "id", compile(tagContext.id()),
                    "contents", compile(tagContext.sections())
            );
        }

        // format : |xxx
        if(tree instanceof Vic3LocaParser.Variable_formatContext variable_formatContext){
            var len = variable_formatContext.children.size();
            return variable_formatContext
                        .children
                        .subList(1,len)
                        .stream()
                        .map(ParseTree::getText)
                        .toList();
        }

        // アイコン：@xxx!
        if (tree instanceof Vic3LocaParser.IconContext iconContext) {
            return Map.of(
                    "type", "icon",
                    "id",iconContext.getChild(1).getText()
            );
        }

        // argument
        if (tree instanceof Vic3LocaParser.Argument_dContext argument_dContext) {
            return compile(argument_dContext.getChild(0));
        }

        // 関数：xxxx(yyy, zzzz)
        if (tree instanceof Vic3LocaParser.FunctionContext functionContext) {

            var childResult= new ArrayList<>();
            if(functionContext.arguments() != null) {
                childResult.add(compile(functionContext.arguments().argument_d()));
                if (functionContext.arguments() != null) {
                    functionContext.arguments().arguments_second().forEach(x -> childResult.add(compile(x.argument_d())));
                }
            }

            return Map.of(
                    "type", "function",
                    "id",functionContext.id().getText(),
                    "arguments",childResult
            );
        }

        // #tooltip_target_tag
        if (tree instanceof Vic3LocaParser.Tooltip_target_tagContext tooltip_target_tagContext) {
            return compile(tooltip_target_tagContext.children.get(0));
        }

        // #tooltip_tag_1
        if (tree instanceof Vic3LocaParser.Tooltip_tag_1Context tooltip_tag_1Context) {
            return Map.of(
                    "type", "tag",
                    "id","tooltip1",
                    "targetTag",tooltip_tag_1Context.tooltip_target_tag().stream().map(Vic3LocaTool::compile).toList(),
                    "contents",compile(tooltip_tag_1Context.sections())
            );
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_2Context tooltip_tag_2Context) {
            return Map.of(
                    "type", "tag",
                    "id","tooltip2",
                    "targetTag",tooltip_tag_2Context.tooltip_target_tag().stream().map(Vic3LocaTool::compile).toList(),
                    "breakdown",tooltip_tag_2Context.tooltip_target_tag().stream().map(Vic3LocaTool::compile).findFirst(),
                    "contents",compile(tooltip_tag_2Context.sections())
            );
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_3Context tooltip_tag_3Context) {
            return Map.of(
                    "type", "tag",
                    "id","tooltip3",
                    "tag",tooltip_tag_3Context.tooltip_target_tag().stream().map(Vic3LocaTool::compile).toList(),
                    "breakdown",tooltip_tag_3Context.tooltip_target_tag().stream().map(Vic3LocaTool::compile).findFirst(),
                    "x",compile(tooltip_tag_3Context.id()),
                    "contents",compile(tooltip_tag_3Context.sections())
            );
        }

        // tooltippable_1
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_1Context tooltippable_tag_1Context) {
            return Map.of(
                    "type", "tag",
                    "id","tooltippable",
                    "x",compile(tooltippable_tag_1Context.id(0)),
                    "y",compile(tooltippable_tag_1Context.id(1)),
                    "z",compile(tooltippable_tag_1Context.id(2)),
                    "contents",compile(tooltippable_tag_1Context.sections())
            );
        }

        // tooltippable_2
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_2Context tooltippable_tag_2Context) {
            return Map.of(
                    "type", "tag",
                    "id","tooltippable",
                    "y",compile(tooltippable_tag_2Context.id(0)),
                    "z",compile(tooltippable_tag_2Context.id(1)),
                    "contents",compile(tooltippable_tag_2Context.sections())
            );
        }

        // scope
        if (tree instanceof Vic3LocaParser.Scope_dContext scope_dContext) {
            return compile(scope_dContext.getChild(0));
        }

        // scopeオブジェクト
        if (tree instanceof Vic3LocaParser.ScopeContext scopeContext) {
            var result = new HashMap<>();
            result.put("type", "scope");

            var childResult= new ArrayList<>();
            childResult.add(compile(scopeContext.scope_d()));
            if(scopeContext.scope_second() != null){
                scopeContext.scope_second().forEach(x-> childResult.add(compile(x.scope_d())));
            }

            result.put("contents", childResult);

            return result;
        }

        // 実行処理：[xxx]
        if (tree instanceof Vic3LocaParser.ShellContext shellContext) {
            var result = new HashMap<>();
            result.put("type", "shell");
            result.put("content", compile(shellContext.shell_target().children.get(0)));
            result.put("format", Optional.ofNullable(shellContext.variable_format())
                    .map(Vic3LocaTool::compile)
                    .orElse(null));

            return result;
        }

        // 変数：$xxx$
        if (tree instanceof Vic3LocaParser.VariableContext variableContext) {
            var result = new HashMap<>();
            result.put("type", "variable");
            result.put("id",variableContext.getChild(1).getText());
            result.put("format", Optional.ofNullable(variableContext.variable_format())
                    .map(Vic3LocaTool::compile)
                    .orElse(null));

            return result;
        }

        // 'xxx'
        if (tree instanceof Vic3LocaParser.WtextContext wtextContext) {
            return compile(wtextContext.sections());
        }

        // テキスト
        if (tree instanceof Vic3LocaParser.TextContext textContext) {
            return textContext.getText();
        }

        return null;
    }

    private static String toJson(Vic3LocaParser.RootContext tree, boolean prettyPrint) throws SystemException {
        var map = compile(tree);
        try {
            return prettyPrint ? objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(map)
                    : objectMapper.writeValueAsString(map);
        } catch (JsonProcessingException e) {
            throw new SystemException("json exception", e);
        }
    }
}
