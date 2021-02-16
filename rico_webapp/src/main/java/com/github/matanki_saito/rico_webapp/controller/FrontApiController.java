package com.github.matanki_saito.rico_webapp.controller;

import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.github.matanki_saito.rico.PdxTxtTool;
import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.SystemException;
import com.github.matanki_saito.rico_webapp.model.ConvertPdxTxtForm;
import com.github.matanki_saito.rico_webapp.model.ConvertPdxTxtFormResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor
@Validated
public class FrontApiController extends ControllerBase {
    @PostMapping("/convert")
    public ConvertPdxTxtFormResponse convertPdxTxtForm(@RequestBody @Validated ConvertPdxTxtForm form)
            throws SystemException, ArgumentException {
        var json = PdxTxtTool.convertJson(form.getTxt(), true);

        return ConvertPdxTxtFormResponse.builder()
                                        .json(json)
                                        .build();
    }
}
