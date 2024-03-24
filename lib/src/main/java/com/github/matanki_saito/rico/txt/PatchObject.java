package com.github.matanki_saito.rico.txt;

import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * パッチcontext
 */
@AllArgsConstructor
@NoArgsConstructor
@Data
public class PatchObject {
    private Map<String, Map<String, Object>> patch;
}
