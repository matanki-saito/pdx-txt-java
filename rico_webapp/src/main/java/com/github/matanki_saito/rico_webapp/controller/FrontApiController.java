package com.github.matanki_saito.rico_webapp.controller;

import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.SystemException;
import com.github.matanki_saito.rico.txt.PdxTxtTool;
import com.github.matanki_saito.rico_webapp.model.ConvertJsonToTxtForm;
import com.github.matanki_saito.rico_webapp.model.ConvertJsonToTxtFormResponse;
import com.github.matanki_saito.rico_webapp.model.ConvertTxtToJsonForm;
import com.github.matanki_saito.rico_webapp.model.ConvertTxtToJsonFormResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

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
}
