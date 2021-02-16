package com.github.matanki_saito.rico.exception;

public class ArgumentException extends Exception {
    public ArgumentException(String message) {
        super(message);
    }

    public ArgumentException(String message, Throwable throwable) {
        super(message, throwable);
    }
}
