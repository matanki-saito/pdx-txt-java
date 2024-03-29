package com.github.matanki_saito.rico_webapp.model;

import com.github.matanki_saito.rico_webapp.validation.ReCaptchaTokenFilter;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.Size;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConvertLocaToJsonForm {
    @Size(max = 10000, message = "10000文字までにしてください")
    private String loca;

    @ReCaptchaTokenFilter
    private String reCaptchaToken;
}
