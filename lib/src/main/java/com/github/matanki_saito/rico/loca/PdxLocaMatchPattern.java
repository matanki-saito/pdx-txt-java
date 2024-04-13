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
import lombok.Getter;
import org.apache.commons.lang3.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Getter
public class PdxLocaMatchPattern {

    private final static String defaultSpreadSheetId = "1hvO4Z4m_zMjhHPGH-BhKcmiHgfbPo7hY4xfpPWwKH6E";

    private final static String defaultSecretEnvName = "GSUITE_CREDENTIAL";

    private Map<String, Map<Pattern, String>> pattern = new HashMap<>();

    public PdxLocaMatchPattern() throws MachineException, ArgumentException {
        reload();
    }

    public Map<Pattern, String> getPattern(List<String> indices) {
        var result = new HashMap<Pattern, String>();
        for (var idx : indices) {
            if (pattern.containsKey(idx)) {
                result.putAll(pattern.get(idx));
            }
        }
        return result;
    }

    public PdxLocaMatchPattern(String spreadSheetId) throws MachineException, ArgumentException {
        reload(spreadSheetId);
    }

    public void reload() throws MachineException, ArgumentException {
        reload(defaultSpreadSheetId);
    }

    public void reload(String spreadSheetId) throws MachineException, ArgumentException {
        var spreadSheets = getSpreadsheets();
        var map = getMapping(spreadSheets, spreadSheetId);
        pattern = map
                .entrySet()
                .stream()
                .collect(Collectors.toMap(Map.Entry::getKey, v -> convertPatterns(v.getValue())));
    }

    private Map<Pattern, String> convertPatterns(Map<String, String> map) {
        return map.entrySet().stream().collect(Collectors.toMap(x -> Pattern.compile(x.getKey()), Map.Entry::getValue));
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

    private Map<String, Map<String, String>> getMapping(Sheets.Spreadsheets spreadsheets,
                                                        String spreadSheetId) throws ArgumentException {

        var result = new HashMap<String, Map<String, String>>();

        Spreadsheet spreadsheet;
        try {
            spreadsheet = spreadsheets.get(spreadSheetId)
                    .setFields("sheets.properties(sheetId,title),sheets.data.rowData.values(userEnteredValue,effectiveValue)")                                    //取得するField
                    .execute();
        } catch (IOException e) {
            throw new ArgumentException("シート取得ミス", e);
        }

        for (var sheet : spreadsheet.getSheets()) {
            var elem = getStringStringHashMap(sheet);
            result.put(sheet.getProperties().getTitle(), elem);
        }

        return result;
    }

    private static HashMap<String, String> getStringStringHashMap(Sheet sheet) {
        var elem = new HashMap<String, String>();

        if (sheet.getData().isEmpty() || sheet.getData().get(0).getRowData() == null)
            return elem;

        for (var row : sheet.getData().get(0).getRowData()) {
            var cell = row.getValues();
            var a = cell.get(0).getUserEnteredValue().getStringValue();
            var b = cell.get(0).getUserEnteredValue().getNumberValue();
            var c = cell.get(1).getUserEnteredValue().getStringValue();
            var d = cell.get(1).getUserEnteredValue().getNumberValue();

            elem.put(a != null ? a : b.toString(), c != null ? c : d.toString());
        }
        return elem;
    }
}
