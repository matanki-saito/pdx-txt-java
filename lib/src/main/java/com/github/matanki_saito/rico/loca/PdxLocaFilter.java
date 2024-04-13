package com.github.matanki_saito.rico.loca;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder(toBuilder = true)
public class PdxLocaFilter {
    private List<String> fileNames;
    private List<String> indecies;
}
