package com.github.matanki_saito.rico_webapp.exception;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import com.github.matanki_saito.rico.exception.PdxParseException;

@ControllerAdvice
public class ApiExceptionHandler {
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(Exception.class)
    @ResponseBody
    public ApiExceptionResponse handleError(Exception exception) {
        return ApiExceptionResponse.builder()
                                   .statusCode(0)
                                   .simpleMessage("何らかのエラー")
                                   .build();
    }

    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(BindException.class)
    @ResponseBody
    public ApiExceptionResponse handleError(BindException exception) {
        var q = exception
                .getFieldErrors()
                .stream()
                .collect(Collectors.groupingBy(
                        FieldError::getField,
                        Collectors.mapping(DefaultMessageSourceResolvable::getDefaultMessage,
                                           Collectors.toList())));

        return ApiExceptionResponse.builder()
                                   .statusCode(400)
                                   .simpleMessage("値に不正があります")
                                   .exceptionDetails(q)
                                   .build();
    }

    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(PdxParseException.class)
    @ResponseBody
    public ApiExceptionResponse handleError(PdxParseException exception) {
        var result = new HashMap<String, List<String>>();
        for (var i = 0; i < exception.getExceptions().size(); i++) {
            var q = exception.getExceptions().get(i);
            result.put("箇所:%d".formatted(i + 1),
                       List.of("%d行目の%d文字目を確認してください".formatted(q.line(), q.charPositionInLine())));
        }

        return ApiExceptionResponse.builder()
                                   .statusCode(400)
                                   .simpleMessage("パースに失敗")
                                   .exceptionDetails(result)
                                   .build();
    }
}
