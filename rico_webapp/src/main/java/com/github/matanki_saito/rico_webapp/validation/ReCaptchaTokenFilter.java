package com.github.matanki_saito.rico_webapp.validation;

import static java.lang.annotation.ElementType.FIELD;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import javax.validation.Constraint;
import javax.validation.Payload;

@Target(FIELD)
@Retention(RUNTIME)
@Documented
@Constraint(validatedBy = ReCaptchaTokenFilterValidator.class)
public @interface ReCaptchaTokenFilter {
    String message() default "recaptcha";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

}
