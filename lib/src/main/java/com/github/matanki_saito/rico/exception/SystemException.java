package com.github.matanki_saito.rico.exception;

/**
 * システム例外
 */
public class SystemException extends Exception {
    /**
     * システム例外
     *
     * @param message エラー詳細
     * @param cause 原因
     */
    public SystemException(String message, Throwable cause) {
        super(message, cause);
    }
}
