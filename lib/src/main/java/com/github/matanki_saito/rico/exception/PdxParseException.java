package com.github.matanki_saito.rico.exception;

import java.util.List;

import com.github.matanki_saito.rico.exception.ThrowingErrorListener.Data;

import lombok.Getter;

public class PdxParseException extends ArgumentException {
    @Getter
    private List<Data> exceptions;

    public PdxParseException(String message) {
        super(message);
    }

    public PdxParseException(String message, Throwable throwable) {
        super(message, throwable);
    }

    public PdxParseException(String message, List<Data> data) {
        super(message);
        exceptions = data;
    }
}
