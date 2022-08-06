package com.github.matanki_saito.rico_console;

import com.github.matanki_saito.rico.PdxTxtTool;
import com.github.matanki_saito.rico.exception.SystemException;
import picocli.CommandLine;
import picocli.CommandLine.Option;
import java.io.File;
import java.util.regex.Pattern;

@CommandLine.Command(name = "example", mixinStandardHelpOptions = true, version = "Picocli example 4.0")
public class RicoConsole implements Runnable {

    @Option(names = { "-r", "--root" }, paramLabel = "DIRECTORY", description = "Target root directory")
    File rootDir;

    public void run() {
        try {
            PdxTxtTool.validateAllToSystemOut(rootDir.toPath(), Pattern.compile("\\.txt"));
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