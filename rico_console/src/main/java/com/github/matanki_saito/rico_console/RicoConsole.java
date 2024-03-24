package com.github.matanki_saito.rico_console;

import com.github.matanki_saito.rico.txt.PdxTxtTool;
import com.github.matanki_saito.rico.exception.SystemException;
import picocli.CommandLine;
import picocli.CommandLine.Option;
import java.io.File;
import java.util.regex.Pattern;

@CommandLine.Command(name = "rico", mixinStandardHelpOptions = true, version = "rico dev version")
public class RicoConsole implements Runnable {

    @Option(names = { "-r", "--root" }, paramLabel = "DIRECTORY", description = "Target root directory")
    File rootDir;

    @Option(names = {"-t", "--type"}, description = "vic3loca, txt")
    String type = "txt";

    public void run() {
        try {
            switch (type){
                case "txt" -> PdxTxtTool.validateAllToSystemOut(rootDir.toPath(), Pattern.compile("\\.txt"));
                //case "vic3loca" -> PdxLocaYmlToolTest.validateAllToSystemOut(rootDir.toPath(), Pattern.compile("\\.yml"));
            }

        } catch (SystemException e) {
            System.out.println(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public static void main(String[] args) {
        // By implementing Runnable or Callable, parsing, error handling and handling user
        // requests for usage help or version help can be done with one line of code.

        int exitCode = new CommandLine(new RicoConsole()).execute(args);
        System.exit(exitCode);
    }
}