package com.github.settis.uart6502.commands;

import picocli.CommandLine;

import java.util.Random;

@CommandLine.Command(name = "ping")
public class Ping extends Base {
    @Override
    public Integer call() {
        try(var port = getPort()) {
            var random = (byte) new Random().nextInt(5, 200);
            port.outputStream.write(new byte[]{1, random});
            port.outputStream.flush();
            var response = (byte) port.inputStream.read();
            if (response - random != 1) {
                System.out.println("Wrong response");
                return 1;
            }
        } catch (Throwable e) {
            System.out.println("Ping failed");
            return 1;
        }
        System.out.println("Ping is OK");
        return 0;
    }
}
