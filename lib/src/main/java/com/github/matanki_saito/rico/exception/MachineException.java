package com.github.matanki_saito.rico.exception;

/**
 * 一致例外
 */
public class MachineException extends SystemException {
    /**
     * 一致例外
     * @param message 詳細メッセージ
     * @param cause 原因
     */
    public MachineException(String message, Throwable cause) {
        super(message, cause);
    }
}
