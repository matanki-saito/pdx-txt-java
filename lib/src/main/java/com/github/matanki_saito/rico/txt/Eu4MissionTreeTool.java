package com.github.matanki_saito.rico.txt;

//import com.github.matanki_saito.rico.antlr.Eu4MissionTreeLexer;
//import com.github.matanki_saito.rico.antlr.Eu4MissionTreeParser;
import com.github.matanki_saito.rico.exception.*;
import lombok.experimental.UtilityClass;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonTokenStream;

import java.nio.file.*;
import java.util.stream.Collectors;

/**
 * EU4のミッションのためのツール
 */
@UtilityClass
public class Eu4MissionTreeTool {

//    /**
//     * Validate txt
//     *
//     * @param txtFilePath path
//     * @return %f:%l:%c: %m\n
//     * @throws SystemException err
//     */
//    public String validate(Path txtFilePath) throws SystemException,MachineException {
//        var charStream = ToolBase.charStreamUtil(txtFilePath);
//
//        var context = generateContext(charStream);
//
//        if (context.listener.getExceptions().isEmpty()) {
//            return "";
//        } else {
//            return context
//                    .listener
//                    .getExceptions()
//                    .stream()
//                    .map(x->String.format("%s:%s:%s: %s",
//                            Paths.get("").toAbsolutePath().relativize(txtFilePath.toAbsolutePath()),
//                            x.line(),
//                            x.charPositionInLine(),
//                            x.message()))
//                    .collect(Collectors.joining("\n"));
//        }
//    }
//
//    /**
//     * Context record
//     * @param tree ツリー
//     * @param listener リスナー
//     */
//    public record TxtContext(Eu4MissionTreeParser.RootContext tree, ThrowingErrorListener listener) { }
//
//    private Eu4MissionTreeTool.TxtContext generateContext(CharStream charStream){
//        var listener = new ThrowingErrorListener();
//
//        var lexer = new Eu4MissionTreeLexer(charStream);
//        lexer.removeErrorListeners();
//        lexer.addErrorListener(listener);
//        var tokens = new CommonTokenStream(lexer);
//        var parser = new Eu4MissionTreeParser(tokens);
//        parser.removeErrorListeners();
//        parser.addErrorListener(listener);
//
//        return new Eu4MissionTreeTool.TxtContext(parser.root(),listener);
//    }
}
