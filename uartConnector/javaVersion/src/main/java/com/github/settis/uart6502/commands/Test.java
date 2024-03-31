package com.github.settis.uart6502.commands;

import picocli.CommandLine;

import java.util.concurrent.Callable;

@CommandLine.Command(name = "test")
public class Test implements Callable<Integer> {
    @Override
    public Integer call() throws Exception {
        return null;
    }
}
