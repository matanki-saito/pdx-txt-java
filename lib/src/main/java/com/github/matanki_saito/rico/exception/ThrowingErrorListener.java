package com.github.matanki_saito.rico.exception;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

import lombok.Getter;

/**
 * 基本エラー
 */
public class ThrowingErrorListener extends BaseErrorListener {
    @Getter
    private final List<Data> exceptions = new ArrayList<>();

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer,
                            Object offendingSymbol,
                            int line,
                            int charPositionInLine,
                            String msg,
                            RecognitionException e) {
        exceptions.add(new Data(line, charPositionInLine, msg));
    }

    /**
     * エラー位置と内容
     * @param line 行
     * @param charPositionInLine 列
     * @param message エラー詳細
     */
    public record Data(int line, int charPositionInLine, String message) {}
}
