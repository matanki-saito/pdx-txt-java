package com.github.matanki_saito.rico_webapp.controller;

import com.github.matanki_saito.rico.Vic3LocaTool;
import com.github.matanki_saito.rico_webapp.model.*;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.github.matanki_saito.rico.PdxTxtTool;
import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.SystemException;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor
@Validated
public class FrontApiController extends ControllerBase {
    @PostMapping("/convertTxtToJson")
    public ConvertTxtToJsonFormResponse convertTxtToJson(@RequestBody @Validated ConvertTxtToJsonForm form)
            throws SystemException, ArgumentException {
        var json = PdxTxtTool.convertTxtToJson(form.getTxt(), true);

        return ConvertTxtToJsonFormResponse.builder()
                                           .json(json)
                                           .build();
    }

    @PostMapping("/convertJsonToTxt")
    public ConvertJsonToTxtFormResponse convertJsonToTxt(@RequestBody @Validated ConvertJsonToTxtForm form)
            throws ArgumentException {
        var txt = PdxTxtTool.convertJsonToTxt(form.getJson());

        return ConvertJsonToTxtFormResponse.builder()
                                           .txt(txt)
                                           .build();
    }

    @PostMapping("/convertLocaToJson")
    public ConvertLocaToJsonFormResponse convertLocaToJson(@RequestBody @Validated ConvertLocaToJsonForm form)
            throws SystemException, ArgumentException {
        var json = Vic3LocaTool.convertStringToJson(form.getLoca(), true);

        return ConvertLocaToJsonFormResponse.builder()
                .json(json)
                .build();
    }
}
