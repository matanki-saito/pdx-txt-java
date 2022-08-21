package com.github.matanki_saito.rico.exception;

/**
 * 引数エラー
 */
public class ArgumentException extends Exception {
    /**
     * 引数エラー
     * @param message 詳細メッセージ
     */
    public ArgumentException(String message) {
        super(message);
    }

    /**
     * 引数エラー
     * @param message 詳細メッセージ
     * @param throwable 例外
     */
    public ArgumentException(String message, Throwable throwable) {
        super(message, throwable);
    }
}
