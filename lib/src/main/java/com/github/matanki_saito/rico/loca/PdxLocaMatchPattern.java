package com.github.matanki_saito.rico.loca;

import com.github.matanki_saito.rico.exception.ArgumentException;
import com.github.matanki_saito.rico.exception.MachineException;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.sheets.v4.Sheets;
import com.google.api.services.sheets.v4.SheetsScopes;
import com.google.api.services.sheets.v4.model.Sheet;
import com.google.api.services.sheets.v4.model.Spreadsheet;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ServiceAccountCredentials;
import lombok.Builder;
import lombok.Data;
import org.apache.commons.lang3.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class PdxLocaMatchPattern {

    private final static String defaultSpreadSheetId = "1hvO4Z4m_zMjhHPGH-BhKcmiHgfbPo7hY4xfpPWwKH6E";

    private final static String defaultSecretEnvName = "GSUITE_CREDENTIAL";

    // eu4
    // - variable
    //  - Pattern1: Str1
    //  - Pattern2: Str2
    // - scope
    //  - Pattern1: Str1
    //  - Pattern2: Str2
    // ck2
    // - variable
    // ...
    private Table0 data = Table0.builder().build();

    public PdxLocaMatchPattern(boolean... debug) throws MachineException, ArgumentException {
        if (debug.length == 0) {
            reload();
        }
    }

    public Optional<String> findScopePattern(List<String> indices, String target) {
        var map = getScopeMap(indices);

        for (var pt : map.entrySet()) {
            var m = pt.getKey().matcher(target);
            if (m.find()) {
                return Optional.of(pt.getValue());
            }
        }

        return Optional.empty();
    }

    public Optional<String> findVariablePattern(List<String> indices, String target) {
        var map = getVariableMap(indices);

        for (var pt : map.entrySet()) {
            var m = pt.getKey().matcher(target);
            if (m.find()) {
                return Optional.of(pt.getValue());
            }
        }

        return Optional.empty();
    }

    public Boolean matchScopePattern(List<String> indices, String target) {
        return findScopePattern(indices, target).isPresent();
    }

    public Boolean matchVariablePattern(List<String> indices, String target) {
        return findVariablePattern(indices, target).isPresent();
    }

    public PdxLocaMatchPattern(String spreadSheetId) throws MachineException, ArgumentException {
        reload(spreadSheetId);
    }

    public void reload() throws MachineException, ArgumentException {
        reload(defaultSpreadSheetId);
    }

    public void reload(String spreadSheetId) throws MachineException, ArgumentException {
        var spreadSheets = getSpreadsheets();
        data = getTable0(spreadSheets, spreadSheetId);
    }

    private HashMap<Pattern, String> getScopeMap(List<String> indices) {
        var result = new HashMap<Pattern, String>();
        for (var idx : indices) {
            if (data.getMap().containsKey(idx)) {
                result.putAll(data.getMap().get(idx).getScope().getMap());
            }
        }
        return result;
    }

    private HashMap<Pattern, String> getVariableMap(List<String> indices) {
        var result = new HashMap<Pattern, String>();
        for (var idx : indices) {
            if (data.getMap().containsKey(idx)) {
                result.putAll(data.getMap().get(idx).getVariable().getMap());
            }
        }
        return result;
    }

    private Sheets.Spreadsheets getSpreadsheets() throws ArgumentException, MachineException {
        var credential = System.getenv(defaultSecretEnvName);
        if (StringUtils.isEmpty(credential)) {
            throw new ArgumentException("GSuiteクレデンシャル未定義");
        }

        GoogleCredentials gCredential;
        try (var stream = new ByteArrayInputStream(credential.getBytes(StandardCharsets.UTF_8))) {
            gCredential = ServiceAccountCredentials
                    .fromStream(stream)
                    .createScoped(List.of(SheetsScopes.SPREADSHEETS));
        } catch (IOException e) {
            throw new MachineException("GSuiteクレデンシャル読み取り異常", e);
        }

        HttpTransport transport;
        try {
            transport = GoogleNetHttpTransport.newTrustedTransport();
        } catch (GeneralSecurityException | IOException e) {
            throw new MachineException("通信設定異常", e);
        }

        Sheets service = new Sheets.Builder(
                transport,
                GsonFactory.getDefaultInstance(),
                new HttpCredentialsAdapter(gCredential)).build();

        return service.spreadsheets();
    }

    private Table0 getTable0(Sheets.Spreadsheets spreadsheets,
                             String spreadSheetId) throws ArgumentException {

        var result = Table0.builder().build();

        Spreadsheet spreadsheet;
        try {
            spreadsheet = spreadsheets.get(spreadSheetId)
                    .setFields("sheets.properties(sheetId,title),sheets.data.rowData.values(userEnteredValue)")                                    //取得するField
                    .execute();
        } catch (IOException e) {
            throw new ArgumentException("シート取得ミス", e);
        }

        for (var sheet : spreadsheet.getSheets()) {
            var table1 = getTable1(sheet);
            result.getMap().put(sheet.getProperties().getTitle(), table1);
        }

        return result;
    }

    private Table1 getTable1(Sheet sheet) {
        var result = Table1.builder().build();

        var scopeMap = new HashMap<String, String>();
        var variableMap = new HashMap<String, String>();

        if (sheet.getData().isEmpty() || sheet.getData().get(0).getRowData() == null)
            return result;

        for (var row : sheet.getData().get(0).getRowData()) {
            var cell = row.getValues();
            // | (a or b) | (c or d) | (e or f)

            String key = null, value = null;
            boolean isVariable = false;
            if (!cell.isEmpty()) {
                String a = cell.get(0).getUserEnteredValue().getStringValue();
                Double b = cell.get(0).getUserEnteredValue().getNumberValue();
                key = a != null ? a : b.toString();
            }
            if (cell.size() > 1) {
                String c = cell.get(1).getUserEnteredValue().getStringValue();
                Double d = cell.get(1).getUserEnteredValue().getNumberValue();
                value = c != null ? c : d.toString();
            }
            if (cell.size() > 2) {
                String e = cell.get(2).getUserEnteredValue().getStringValue();
                Double f = cell.get(2).getUserEnteredValue().getNumberValue();
                isVariable = (e != null ? e : f.toString()).equals("variable");
            }
            if (key != null && value != null) {
                if (isVariable) {
                    variableMap.put(key, value);
                } else {
                    scopeMap.put(key, value);
                }
            }
        }

        result.getScope().getMap().putAll(convertPatterns(scopeMap));
        result.getVariable().getMap().putAll(convertPatterns(variableMap));

        return result;
    }

    private Map<Pattern, String> convertPatterns(Map<String, String> map) {
        return map.entrySet().stream().collect(Collectors.toMap(x -> Pattern.compile(x.getKey()), Map.Entry::getValue));
    }

    @Data
    @Builder
    private static class Table0 {
        @Builder.Default
        private Map<String, Table1> map = new HashMap<>();
    }

    @Data
    @Builder
    private static class Table1 {
        @Builder.Default
        private Table2 scope = Table2.builder().build();
        @Builder.Default
        private Table2 variable = Table2.builder().build();
    }

    @Data
    @Builder
    private static class Table2 {
        @Builder.Default
        private Map<Pattern, String> map = new HashMap<>();
    }
}
