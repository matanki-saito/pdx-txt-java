package com.github.matanki_saito.rico;

import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class PatchObject {
    private Map<String, Map<String, Object>> patch;
}
