package com.github.matanki_saito.rico_webapp.model;

import javax.validation.constraints.Size;

import com.github.matanki_saito.rico_webapp.validation.ReCaptchaTokenFilter;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConvertJsonToTxtForm {
    @Size(max = 50000)
    private String json;

    @ReCaptchaTokenFilter
    private String reCaptchaToken;
}
