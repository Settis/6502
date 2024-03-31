///usr/bin/env jbang "$0" "$@" ; exit $?
//DEPS info.picocli:picocli:4.7.5
//DEPS com.github.settis:uart6502:1.0-SNAPSHOT

package com.github.settis.uart6502;

import com.github.settis.uart6502.commands.*;
import picocli.CommandLine;

import java.util.concurrent.Callable;

@CommandLine.Command(name = "uart6502", mixinStandardHelpOptions = true, version = "1.0-SNAPSHOT",
        description = "Sends commands to 6502 via UART.",
        subcommands = {CompileAndRun.class, Ping.class, Read.class, Run.class, Test.class, Write.class})
public class uart6502 implements Callable<Integer> {
    @CommandLine.Option(names = { "-h", "--help" }, usageHelp = true, description = "display a help message")
    private boolean helpRequested = false;

    public static void main(String... args) {
        int exitCode = new CommandLine(new uart6502()).execute(args);
        System.exit(exitCode);
    }

    @Override
    public Integer call() {
        System.out.println("You must use one of subcommands");
        return 1;
    }
}
