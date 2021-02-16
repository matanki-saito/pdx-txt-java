package com.github.matanki_saito.rico_webapp.validation;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import com.github.matanki_saito.rico_webapp.model.ReCaptchaResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@RequiredArgsConstructor
public class ReCaptchaTokenFilterValidator implements ConstraintValidator<ReCaptchaTokenFilter, String> {

    //@Value("${reCaptcha.v3.secret}")
    private String secret;

    //@Value("${reCaptcha.v3.threshold}")
    private float threshold;

    @Override
    public boolean isValid(String token, ConstraintValidatorContext context) {
        final String url = String.format(
                "https://www.google.com/recaptcha/api/siteverify?secret=%s&response=%s",
                secret, token);
        RestTemplate restTemplate = new RestTemplate();
        ReCaptchaResponse result = restTemplate.getForObject(url, ReCaptchaResponse.class);

        if (result.isSuccess()) {
            if (threshold >= result.getScore()) {
                context.buildConstraintViolationWithTemplate("bot access")
                       .addConstraintViolation();
                return false;
            }
        } else {
            context.buildConstraintViolationWithTemplate("reCaptcha server error")
                   .addConstraintViolation();
            return false;
        }

        return true;
    }
}
