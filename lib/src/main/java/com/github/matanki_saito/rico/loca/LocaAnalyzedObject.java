package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.antlr.Vic3LocaLexer;
import com.github.matanki_saito.rico.antlr.Vic3LocaParser;
import com.github.matanki_saito.rico.exception.ThrowingErrorListener;
import lombok.Getter;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

@Getter
public class LocaAnalyzedObject {

    private final Vic3LocaLexer lexer;
    private final ThrowingErrorListener listener;

    private final CommonTokenStream tokenStream;

    private final Vic3LocaParser parser;

    private final Vic3LocaParser.RootContext context;

    public LocaAnalyzedObject(String text){
        lexer = new Vic3LocaLexer(CharStreams.fromString(text));
        listener = new ThrowingErrorListener();

        lexer.removeErrorListeners();
        lexer.addErrorListener(listener);

        tokenStream = new CommonTokenStream(lexer);

        parser = new Vic3LocaParser(tokenStream);
        parser.removeErrorListeners();
        parser.addErrorListener(listener);

        context = parser.root();
    }
}
