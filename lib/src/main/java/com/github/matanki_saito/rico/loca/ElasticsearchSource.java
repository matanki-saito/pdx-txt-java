package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.exception.ArgumentException;

public class ElasticsearchSource implements PdxLocaSource{
    @Override
    public PdxLocaYamlRecord get(String key) throws ArgumentException {
        return null;
    }

    @Override
    public boolean exists(String key) {
        return false;
    }
}
