package com.github.matanki_saito.rico.exception;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Value;

@EqualsAndHashCode(callSuper = true)
@Builder
@Value
public class PdxParseException extends RuntimeException {
    int line;
    int charPosition;
    String message;
}
