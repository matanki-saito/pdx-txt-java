package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.antlr.Vic3LocaParser;
import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.PdxParseException;
import lombok.experimental.UtilityClass;
import org.antlr.v4.runtime.tree.ParseTree;
import org.apache.commons.lang3.StringEscapeUtils;

import java.util.ArrayList;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@UtilityClass
public class PdxLocaYmlTool {

    private final Map<Pattern, String> scopePattern = Map.ofEntries(
            Map.entry(Pattern.compile("(.+\\.)?STATE\\.GetName"), "幻想郷"),
            Map.entry(Pattern.compile("(.+\\.)?COUNTRY\\.(GetNameNoFormatting|GetAdjectiveNoFormatting)"), "日本"),
            Map.entry(Pattern.compile("(.+\\.)?Party\\.GetName"), "国民党"),
            Map.entry(Pattern.compile("(.+\\.)?GetPopType\\.GetName"), "農民"),
            Map.entry(Pattern.compile("(.+\\.)?GetPopType\\(\\)\\.GetName"), "農民"),
            Map.entry(Pattern.compile("(.+\\.)?GetNextElectionDate"), "平成10年"),
            Map.entry(Pattern.compile("(.+\\.)?GetCombatUnitProduction"), "戦艦"),
            Map.entry(Pattern.compile("(.+\\.)?(GetHerHis|GetHerHim|GetSheHe)"), "彼"),
            Map.entry(Pattern.compile("(.+\\.)?(GetFullName|GetLastName)"), "博麗霊夢"),
            Map.entry(Pattern.compile("(.+\\.)?GetPlayer\\.GetNameNoFlag"), "日本"),
            Map.entry(Pattern.compile("(.+\\.)?GetGovernment\\.GetName"), "神権政"),
            Map.entry(Pattern.compile("(.+\\.)?GetGoalProgressValue"), "200"),
            Map.entry(Pattern.compile("(.+\\.)?GetGoalAddValue"), "20"),
            Map.entry(Pattern.compile("(.+\\.)?sCountry\\(\\).(GetName|GetNameNoFlag|GetAdjective)"), "地霊殿"),
            Map.entry(Pattern.compile("(.+\\.)?gsInterestGroup\\(\\).GetName"), "妖怪"),
            Map.entry(Pattern.compile("(.+\\.)?GetCountry(\\(\\)\\))?.(GetCustom|GetName|GetAdjective)(\\(\\)\\))?"), "日本"),
            Map.entry(Pattern.compile("(.+\\.)?sState\\(\\)\\.GetName"), "幻想郷"),
            Map.entry(Pattern.compile("(.+\\.)?GetPortHubName"), "函館"),
            Map.entry(Pattern.compile("(.+\\.)?sCulture\\(\\)\\.GetName"), "西日本"),
            Map.entry(Pattern.compile("(.+\\.)?GetLawType\\(\\)\\.GetName"), "軍事法"),
            Map.entry(Pattern.compile("(.+\\.)?GetBattleCondition\\(\\)\\.GetName"), "勝利"),
            Map.entry(Pattern.compile("(.+\\.)?CompanyType(\\(\\)\\))?.GetName(\\(\\)\\))?"), "電機機器"),
            Map.entry(Pattern.compile("(.+\\.)?GetBuildingType\\(\\)\\.GetName"), "兵舎"),
            Map.entry(Pattern.compile("(.+\\.)?GetInterestGroupVariant\\(\\)\\.GetNameWithCountryVariant"), "商人")
    );

    static String normalize(String key, PdxLocaSource source) throws ArgumentException {
        var loca = source.get(key);

        var object = new LocaAnalyzedObject(loca.getBody());

        if (object.getListener().getExceptions().isEmpty()) {
            return sweep(object.getContext(), source);
        } else {
            throw new PdxParseException("不正なローカライズテキストです. key=%s, err=%s".formatted(key, object.getListener().getExceptions()), object.getListener().getExceptions());
        }
    }

    private static String sweep(ParseTree tree, PdxLocaSource source) {
        if (tree instanceof Vic3LocaParser.RootContext rootContext) {
            return sweep(rootContext.sections(), source);
        }

        if (tree instanceof Vic3LocaParser.SectionsContext sectionsContext) {
            return sectionsContext
                    .section()
                    .stream()
                    .map(x -> sweep(x, source))
                    .collect(Collectors.joining(""));
        }

        if (tree instanceof Vic3LocaParser.SectionContext sectionContext) {
            return sweep(sectionContext.getChild(0), source);
        }

        // id : Alphabet + Number + _
        if (tree instanceof Vic3LocaParser.IdContext idContext) {
            return idContext.getText();
        }

        // tag: #xxx ~~~ #!
        if (tree instanceof Vic3LocaParser.TagContext tagContext) {
            return sweep(tagContext.sections(), source);
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
            return sweep(argument_dContext.getChild(0), source);
        }

        // 関数：xxxx(yyy, zzzz)
        if (tree instanceof Vic3LocaParser.FunctionContext functionContext) {
            var id = functionContext.id().getText();

            return switch (id) {
                case "Concept" -> sweep(functionContext.arguments().argument_d(), source);
                case "AddLocalizationIf" -> sweep(functionContext.arguments().arguments_second(0).argument_d(), source);
                default -> id + "()";
            };
        }

        // #tooltip_target_tag
        if (tree instanceof Vic3LocaParser.Tooltip_target_tagContext tooltip_target_tagContext) {
            return sweep(tooltip_target_tagContext.children.get(0), source);
        }

        // #tooltip_tag_1
        if (tree instanceof Vic3LocaParser.Tooltip_tag_1Context tooltip_tag_1Context) {
            return sweep(tooltip_tag_1Context.sections(), source);
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_2Context tooltip_tag_2Context) {
            return sweep(tooltip_tag_2Context.sections(), source);
        }
        if (tree instanceof Vic3LocaParser.Tooltip_tag_3Context tooltip_tag_3Context) {
            return sweep(tooltip_tag_3Context.sections(), source);
        }

        // tooltippable_1
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_1Context tooltippable_tag_1Context) {
            return sweep(tooltippable_tag_1Context.sections(), source);
        }

        // tooltippable_2
        if (tree instanceof Vic3LocaParser.Tooltippable_tag_2Context tooltippable_tag_2Context) {
            return sweep(tooltippable_tag_2Context.sections(), source);
        }

        // scope
        if (tree instanceof Vic3LocaParser.Scope_dContext scope_dContext) {
            return sweep(scope_dContext.getChild(0), source);
        }

        // scopeオブジェクト
        if (tree instanceof Vic3LocaParser.ScopeContext scopeContext) {
            var result = new ArrayList<String>();
            result.add(sweep(scopeContext.scope_d(), source));
            if (scopeContext.scope_second() != null) {
                result.addAll(scopeContext.scope_second().stream().map(x -> sweep(x.scope_d(), source)).toList());
            }

            var x = String.join(".", result);

            if (source.exists(x)) {
                try {
                    return normalize(x, source);
                } catch (ArgumentException e) {
                    throw new RuntimeException("予期せぬエラー");
                }
            }

            for (var pattern : scopePattern.entrySet()) {
                var m = pattern.getKey().matcher(x);
                if (m.find()) {
                    return pattern.getValue();
                }
            }

            return x;
        }

        // 実行処理：[xxx]
        if (tree instanceof Vic3LocaParser.ShellContext shellContext) {
            return sweep(shellContext.shell_target().children.get(0), source);
        }

        // 変数：$xxx$
        if (tree instanceof Vic3LocaParser.VariableContext variableContext) {
            var id = variableContext.id().getText();
            if (source.exists(id)) {
                try {
                    return normalize(id, source);
                } catch (ArgumentException e) {
                    throw new RuntimeException("予期せぬエラー", e);
                }
            } else {
                return id;
            }
        }

        // 'xxx'
        if (tree instanceof Vic3LocaParser.WtextContext wtextContext) {
            return sweep(wtextContext.sections(), source);
        }

        // テキスト
        if (tree instanceof Vic3LocaParser.TextContext textContext) {
            return StringEscapeUtils.unescapeJava(textContext.getText());
        }

        return null;
    }
}
