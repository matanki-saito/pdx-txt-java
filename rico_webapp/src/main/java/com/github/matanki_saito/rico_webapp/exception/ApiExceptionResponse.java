package com.github.matanki_saito.rico_webapp.exception;

import java.util.List;
import java.util.Map;

import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class ApiExceptionResponse {
    private int statusCode;
    private String simpleMessage;
    private Map<String, List<String>> exceptionDetails;
}
