package com.github.matanki_saito.rico.exception;

/**
 * 自分が悪い時
 *  - IOExceptionなど
 */
public class SystemException extends Exception {
    public SystemException(String message, Throwable cause) {
        super(message, cause);
    }
}
