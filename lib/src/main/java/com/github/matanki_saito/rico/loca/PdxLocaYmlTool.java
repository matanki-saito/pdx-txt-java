package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.antlr.Vic3LocaParser;
import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.PdxParseException;
import com.github.matanki_saito.rico.exception.SystemException;
import lombok.Builder;
import lombok.Getter;
import org.antlr.v4.runtime.tree.ParseTree;
import org.apache.commons.lang3.StringEscapeUtils;

import java.util.*;
import java.util.stream.Collectors;

@Getter
@Builder
public class PdxLocaYmlTool {


    @Builder.Default
    private Boolean debug = false;

    @Builder.Default
    private Set<String> circularReferenceCheckSet = new HashSet<>();

    @Builder.Default
    private Map<String, Integer> icons = new HashMap<>();

    @Builder.Default
    private Map<String, Integer> segments = new HashMap<>();

    @Builder.Default
    private Map<String, Integer> vars = new HashMap<>();

    @Builder.Default
    private Map<String, Integer> scopes = new HashMap<>();

    public String normalize(String key,
                            PdxLocaSource source,
                            PdxLocaMatchPattern pattern,
                            PdxLocaFilter filter)
            throws ArgumentException, SystemException {

        if (circularReferenceCheckSet.contains(key)) {
            return "circular reference!!";
        } else {
            circularReferenceCheckSet.add(key);
        }

        try {
            var record = source.get(key, filter);

            var object = new LocaAnalyzedObject(record.getBody());

            if (object.getListener().getExceptions().isEmpty()) {
                return sweep(object.getContext(), source, pattern, filter);
            } else {
                throw new PdxParseException("不正なローカライズテキストです. key=%s, err=%s"
                        .formatted(record.getKey(), object.getListener().getExceptions()), object.getListener().getExceptions());
            }
        } catch (ArgumentException e) {
            return e.getMessage();
        }

    }

    public Map<String, String> normalize(PdxLocaSource source, PdxLocaMatchPattern pattern, PdxLocaFilter filter)
            throws ArgumentException, SystemException {
        return source.getKeys(filter).stream().collect(Collectors.toMap(key -> key,
                key -> {
                    try {
                        circularReferenceCheckSet = new HashSet<>();
                        return normalize(key, source, pattern, filter);
                    } catch (ArgumentException | SystemException e) {
                        return "";
                    }
                }));
    }

    private String sweep(ParseTree tree, PdxLocaSource source, PdxLocaMatchPattern pattern, PdxLocaFilter filter) {
        if (tree instanceof Vic3LocaParser.RootContext rootContext) {
            return sweep(rootContext.sections(), source, pattern, filter);
        }

        if (tree instanceof Vic3LocaParser.SectionsContext sectionsContext) {
            return sectionsContext
                    .section()
                    .stream()
                    .map(x -> sweep(x, source, pattern, filter))
                    .collect(Collectors.joining(""));
        }

        if (tree instanceof Vic3LocaParser.SectionContext sectionContext) {
            return sweep(sectionContext.getChild(0), source, pattern, filter);
        }

        // id : Alphabet + Number + _
        if (tree instanceof Vic3LocaParser.IdContext idContext) {
            return idContext.getText();
        }

        // tag: #xxx ~~~ #!
        if (tree instanceof Vic3LocaParser.TagContext tagContext) {
            return sweep(tagContext.sections(), source, pattern, filter);
        }

        // format : |xxx
        if (tree instanceof Vic3LocaParser.Variable_formatContext variable_formatContext) {
            var len = variable_formatContext.children.size();
            return variable_formatContext
                    .children
                    .subList(1, len)
                    .stream()
                    .map(ParseTree::getText)
                    .collect(Collectors.joining());
        }

        // segment : §R ~~~~ §!
        if (tree instanceof Vic3LocaParser.SegmentContext segmentContext) {
            if (debug) {
                var k = segmentContext.ALPHABET().getText();
                segments.putIfAbsent(k, 0);
                segments.computeIfPresent(k, (z, v) -> v + 1);
            }

            return sweep(segmentContext.sections(), source, pattern, filter);
        }

        // アイコン：@xxx
        if (tree instanceof Vic3LocaParser.IconContext icon) {
            if (debug) {
                var k = icon.section().getText();
                icons.putIfAbsent(k, 0);
                icons.computeIfPresent(k, (z, v) -> v + 1);
            }

            return "⛩️";
        }

        // argument
        if (tree instanceof Vic3LocaParser.Argument_dContext argument_dContext) {
            return sweep(argument_dContext.getChild(0), source, pattern, filter);
        }

        // 関数：xxxx(yyy, zzzz)
        if (tree instanceof Vic3LocaParser.FunctionContext functionContext) {

            var id = functionContext.id().getText();

            return switch (id) {
                case "Concept" -> sweep(functionContext.arguments().argument_d(), source, pattern, filter);
                case "AddLocalizationIf" -> sweep(
                        functionContext.arguments().arguments_second(0).argument_d(), source, pattern, filter);
                case "GetFeatureText", "Custom" ->
                        "%s<%s>".formatted(id, sweep(functionContext.arguments().argument_d(), source, pattern, filter));
                default -> id;
            };
        }

        // #tooltip_target_tag
        if (tree instanceof Vic3LocaParser.Tooltip_target_tagContext tooltip_target_tagContext) {
            return sweep(tooltip_target_tagContext.children.get(0), source, pattern, filter);
        }

        // #tooltip_tag_1
        if (tree instanceof Vic3LocaParser.Tooltip_tag_1Context tooltip_tag_1Context) {
            return sweep(tooltip_tag_1Context.sections(), source, pattern, filter);
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_2Context tooltip_tag_2Context) {
            return sweep(tooltip_tag_2Context.sections(), source, pattern, filter);
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_3Context tooltip_tag_3Context) {
            return sweep(tooltip_tag_3Context.sections(), source, pattern, filter);
        }

        // tooltippable_1
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_1Context tooltippable_tag_1Context) {
            return sweep(tooltippable_tag_1Context.sections(), source, pattern, filter);
        }

        // tooltippable_2
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_2Context tooltippable_tag_2Context) {
            return sweep(tooltippable_tag_2Context.sections(), source, pattern, filter);
        }

        // scope
        if (tree instanceof Vic3LocaParser.Scope_dContext scope_dContext) {
            return sweep(scope_dContext.getChild(0), source, pattern, filter);
        }

        // scopeオブジェクト
        if (tree instanceof Vic3LocaParser.ScopeContext scopeContext) {
            if (debug) {
                var k = scopeContext.getText();
                scopes.putIfAbsent(k, 0);
                scopes.computeIfPresent(k, (z, v) -> v + 1);
            }
            var result = new ArrayList<String>();
            result.add(sweep(scopeContext.scope_d(), source, pattern, filter));
            if (scopeContext.scope_second() != null) {
                result.addAll(scopeContext.scope_second().stream().map(x -> sweep(x.scope_d(), source, pattern, filter)).toList());
            }

            var x = String.join("=", result);
            var keyX = "game_concept_" + x;
            if (source.exists(keyX, filter)) {
                try {
                    return normalize(keyX, source, pattern, filter);
                } catch (ArgumentException | SystemException e) {
                    throw new RuntimeException("予期せぬエラー");
                }
            } else if (source.exists(x, filter)) {
                try {
                    return normalize(x, source, pattern, filter);
                } catch (ArgumentException | SystemException e) {
                    throw new RuntimeException("予期せぬエラー");
                }
            }

            for (var pt : pattern.getPattern(filter.getIndecies()).entrySet()) {
                var m = pt.getKey().matcher(x);
                if (m.find()) {
                    return pt.getValue();
                }
            }

            return x;
        }

        // 実行処理：[xxx]
        if (tree instanceof Vic3LocaParser.ShellContext shellContext) {
            return sweep(shellContext.shell_target().children.get(0), source, pattern, filter);
        }

        // 変数：$xxx$
        if (tree instanceof Vic3LocaParser.VariableContext variableContext) {
            var id = variableContext.id().getText();

            if (debug) {
                vars.putIfAbsent(id, 0);
                vars.computeIfPresent(id, (z, v) -> v + 1);
            }

            if (source.exists(id, filter)) {
                try {
                    return normalize(id, source, pattern, filter);
                } catch (ArgumentException | SystemException e) {
                    throw new RuntimeException("予期せぬエラー", e);
                }
            } else {
                //tmp.add(id);
                return switch (id) {
                    case "VALUE" -> "+50";
                    case "COSTS", "COST", "YEARS" -> "100";
                    case "PRESET_NAME" -> "プリセット１";
                    case "COURT_POSITION" -> "家令";
                    case "EFFECT" -> "<<<<効果>>>>";
                    case "RESOURCES", "MONTHS" -> "3";
                    default -> id;
                };
            }
        }

        // 'xxx'
        if (tree instanceof Vic3LocaParser.WtextContext wtextContext) {
            return sweep(wtextContext.sections(), source, pattern, filter);
        }

        // テキスト
        if (tree instanceof Vic3LocaParser.TextContext textContext) {
            return StringEscapeUtils.unescapeJava(textContext.getText());
        }

        return null;
    }
}
