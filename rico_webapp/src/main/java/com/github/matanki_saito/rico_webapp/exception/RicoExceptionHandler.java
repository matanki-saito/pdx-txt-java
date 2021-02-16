package com.github.matanki_saito.rico_webapp.exception;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import com.github.matanki_saito.rico.exception.SystemException;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@ControllerAdvice
public class RicoExceptionHandler {
    @ResponseStatus(HttpStatus.BAD_GATEWAY)
    @ExceptionHandler({ SystemException.class })
    @ResponseBody
    public Map<String, Object> handleErrorOtherServiceException(SystemException e) {
        Map<String, Object> errorMap = new HashMap<>();
        errorMap.put("title", "Other system is down");
        errorMap.put("status", HttpStatus.BAD_GATEWAY);

        log.warn("OtherSystemException={}", e);

        return errorMap;
    }
}
