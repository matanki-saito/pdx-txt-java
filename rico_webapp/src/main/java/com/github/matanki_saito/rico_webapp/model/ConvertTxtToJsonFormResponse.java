package com.github.matanki_saito.rico_webapp.model;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ConvertTxtToJsonFormResponse {
    private String json;
}
