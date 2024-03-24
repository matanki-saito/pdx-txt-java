package com.github.matanki_saito.rico.txt;

import com.github.matanki_saito.rico.exception.MachineException;
import com.github.matanki_saito.rico.exception.SystemException;
import lombok.experimental.UtilityClass;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.misc.Interval;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.function.Function;
import java.util.regex.Pattern;

@UtilityClass
public class ToolBase {





    /**
     * UTF-8 BOM
     */
    public static final String UTF8_BOM = "\uFEFF";

    /**
     * 対象のフォルダから開始して再帰的にエラーチェック
     * @param root 対象のフォルダルート
     * @param matchPathPattern ファイルマッチ規則
     * @throws SystemException システム例外
     */
    public static void validateAllToSystemOut(Path root, Pattern matchPathPattern, Function<Path,String> fn)
            throws SystemException {
        try {
            Files.walkFileTree(root, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult visitFile(Path filePath, BasicFileAttributes attrs) {
                    var pathStr = filePath.toAbsolutePath().toString();

                    var m = matchPathPattern.matcher(pathStr);
                    if (m.find()) {
                        var result = fn.apply(filePath);
                        if(!result.isEmpty()){
                            System.out.println(result);
                        }
                    }
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            throw new MachineException("", e);
        }
    }

    public CharStream charStreamUtil(Path path) throws MachineException{
        CharStream charStream;
        try {
            charStream = CharStreams.fromPath(path);
            var textHead = charStream.getText(Interval.of(0, 1));
            if (textHead.startsWith(UTF8_BOM)) {
                charStream.seek(1);
            }

            return charStream;
        } catch (IOException e) {
            throw new MachineException("IO exception", e);
        }
    }
}
