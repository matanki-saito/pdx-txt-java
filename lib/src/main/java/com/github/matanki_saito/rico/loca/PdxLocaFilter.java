package com.github.matanki_saito.rico.loca;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder(toBuilder = true)
public class PdxLocaFilter {
    @Builder.Default
    private List<String> fileNames = new ArrayList<>();
    @Builder.Default
    private List<String> indecies = new ArrayList<>();
}
