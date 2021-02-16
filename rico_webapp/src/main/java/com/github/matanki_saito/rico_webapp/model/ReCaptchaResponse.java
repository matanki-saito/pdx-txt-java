package com.github.matanki_saito.rico_webapp.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class ReCaptchaResponse {
    private boolean success;
    @JsonProperty("challenge_ts")
    private String challengeTs;
    private String hostname;
    private float score;
    private String action;
}
