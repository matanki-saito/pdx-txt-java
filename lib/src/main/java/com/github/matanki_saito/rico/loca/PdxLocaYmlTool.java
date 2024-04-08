package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.antlr.Vic3LocaParser;
import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.PdxParseException;
import com.github.matanki_saito.rico.exception.SystemException;
import lombok.experimental.UtilityClass;
import org.antlr.v4.runtime.tree.ParseTree;
import org.apache.commons.lang3.StringEscapeUtils;

import java.util.ArrayList;
import java.util.Map;
import java.util.stream.Collectors;

@UtilityClass
public class PdxLocaYmlTool {
    public static String normalize(String key,
                                   PdxLocaSource source,
                                   PdxLocaMatchPattern pattern)
            throws ArgumentException, SystemException {
        try {
            var record = source.get(key);

            var object = new LocaAnalyzedObject(record.getBody());

            if (object.getListener().getExceptions().isEmpty()) {
                return sweep(object.getContext(), source, pattern);
            } else {
                throw new PdxParseException("不正なローカライズテキストです. key=%s, err=%s"
                        .formatted(record.getKey(), object.getListener().getExceptions()), object.getListener().getExceptions());
            }
        } catch (ArgumentException e) {
            return e.getMessage();
        }

    }

    public static Map<String, String> normalize(PdxLocaSource source, PdxLocaMatchPattern pattern)
            throws ArgumentException, SystemException {
        return source.getKeys().stream().collect(Collectors.toMap(key -> key,
                key -> {
                    try {
                        return normalize(key, source, pattern);
                    } catch (ArgumentException | SystemException e) {
                        return "";
                    }
                }));
    }

    private static String sweep(ParseTree tree, PdxLocaSource source, PdxLocaMatchPattern pattern) {
        if (tree instanceof Vic3LocaParser.RootContext rootContext) {
            return sweep(rootContext.sections(), source, pattern);
        }

        if (tree instanceof Vic3LocaParser.SectionsContext sectionsContext) {
            return sectionsContext
                    .section()
                    .stream()
                    .map(x -> sweep(x, source, pattern))
                    .collect(Collectors.joining(""));
        }

        if (tree instanceof Vic3LocaParser.SectionContext sectionContext) {
            return sweep(sectionContext.getChild(0), source, pattern);
        }

        // id : Alphabet + Number + _
        if (tree instanceof Vic3LocaParser.IdContext idContext) {
            return idContext.getText();
        }

        // tag: #xxx ~~~ #!
        if (tree instanceof Vic3LocaParser.TagContext tagContext) {
            return sweep(tagContext.sections(), source, pattern);
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

        // アイコン：@xxx!
        if (tree instanceof Vic3LocaParser.IconContext iconContext) {
            return "⛩️";
        }

        // argument
        if (tree instanceof Vic3LocaParser.Argument_dContext argument_dContext) {
            return sweep(argument_dContext.getChild(0), source, pattern);
        }

        // 関数：xxxx(yyy, zzzz)
        if (tree instanceof Vic3LocaParser.FunctionContext functionContext) {

            var id = functionContext.id().getText();

            return switch (id) {
                case "Concept" -> sweep(functionContext.arguments().argument_d(), source, pattern);
                case "AddLocalizationIf" -> sweep(
                        functionContext.arguments().arguments_second(0).argument_d(), source, pattern);
                case "GetFeatureText", "Custom" ->
                        "%s<%s>".formatted(id, sweep(functionContext.arguments().argument_d(), source, pattern));
                default -> id;
            };
        }

        // #tooltip_target_tag
        if (tree instanceof Vic3LocaParser.Tooltip_target_tagContext tooltip_target_tagContext) {
            return sweep(tooltip_target_tagContext.children.get(0), source, pattern);
        }

        // #tooltip_tag_1
        if (tree instanceof Vic3LocaParser.Tooltip_tag_1Context tooltip_tag_1Context) {
            return sweep(tooltip_tag_1Context.sections(), source, pattern);
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_2Context tooltip_tag_2Context) {
            return sweep(tooltip_tag_2Context.sections(), source, pattern);
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_3Context tooltip_tag_3Context) {
            return sweep(tooltip_tag_3Context.sections(), source, pattern);
        }

        // tooltippable_1
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_1Context tooltippable_tag_1Context) {
            return sweep(tooltippable_tag_1Context.sections(), source, pattern);
        }

        // tooltippable_2
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_2Context tooltippable_tag_2Context) {
            return sweep(tooltippable_tag_2Context.sections(), source, pattern);
        }

        // scope
        if (tree instanceof Vic3LocaParser.Scope_dContext scope_dContext) {
            return sweep(scope_dContext.getChild(0), source, pattern);
        }

        // scopeオブジェクト
        if (tree instanceof Vic3LocaParser.ScopeContext scopeContext) {
            var result = new ArrayList<String>();
            result.add(sweep(scopeContext.scope_d(), source, pattern));
            if (scopeContext.scope_second() != null) {
                result.addAll(scopeContext.scope_second().stream().map(x -> sweep(x.scope_d(), source, pattern)).toList());
            }

            var x = String.join("=", result);
            var keyX = "game_concept_" + x;
            if (source.exists(keyX)) {
                try {
                    return normalize(keyX, source, pattern);
                } catch (ArgumentException | SystemException e) {
                    throw new RuntimeException("予期せぬエラー");
                }
            } else if (source.exists(x)) {
                try {
                    return normalize(x, source, pattern);
                } catch (ArgumentException | SystemException e) {
                    throw new RuntimeException("予期せぬエラー");
                }
            }

            //tmp2.add(result.get(result.size()-1));

            for (var pt : pattern.getScopePattern().entrySet()) {
                var m = pt.getKey().matcher(x);
                if (m.find()) {
                    return pt.getValue();
                }
            }

            return x;
        }

        // 実行処理：[xxx]
        if (tree instanceof Vic3LocaParser.ShellContext shellContext) {
            return sweep(shellContext.shell_target().children.get(0), source, pattern);
        }

        // 変数：$xxx$
        if (tree instanceof Vic3LocaParser.VariableContext variableContext) {
            var id = variableContext.id().getText();
            if (source.exists(id)) {
                try {
                    return normalize(id, source, pattern);
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
            return sweep(wtextContext.sections(), source, pattern);
        }

        // テキスト
        if (tree instanceof Vic3LocaParser.TextContext textContext) {
            return StringEscapeUtils.unescapeJava(textContext.getText());
        }

        return null;
    }
}
