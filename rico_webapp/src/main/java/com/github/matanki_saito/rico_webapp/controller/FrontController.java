package com.github.matanki_saito.rico_webapp.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FrontController extends ControllerBase {
    @Value("${reCaptcha.v3.site-key}")
    private String reCaptchaV3SiteKey;

    @GetMapping
    public String index(Model model) {
        model.addAttribute("reCaptchaV3SiteKey", reCaptchaV3SiteKey);
        return "front.index.vue";
    }
}
