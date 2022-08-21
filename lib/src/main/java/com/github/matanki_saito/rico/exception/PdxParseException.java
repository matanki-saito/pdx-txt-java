package com.github.matanki_saito.rico.exception;

import java.util.List;

import com.github.matanki_saito.rico.exception.ThrowingErrorListener.Data;

import lombok.Getter;

/**
 * パース例外
 */
public class PdxParseException extends ArgumentException {
    /**
     * 例外一覧
     */
    @Getter
    private List<Data> exceptions;

    /**
     * パース例外
     *
     * @param message 詳細メッセージ
     */
    public PdxParseException(String message) {
        super(message);
    }

    /**
     * パース例外
     *
     * @param message 詳細メッセージ
     * @param throwable 直接的な例外
     */
    public PdxParseException(String message, Throwable throwable) {
        super(message, throwable);
    }

    /**
     * パース例外
     *
     * @param message 詳細メッセージ
     * @param data 格納データ
     */
    public PdxParseException(String message, List<Data> data) {
        super(message);
        exceptions = data;
    }
}
