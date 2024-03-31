package com.github.settis.uart6502.commands;

import com.fazecast.jSerialComm.SerialPort;
import picocli.CommandLine;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.Callable;

public abstract class Base  implements Callable<Integer> {
    @CommandLine.Option(names = "--dev", description = "UART device", defaultValue = "/dev/ttyUSB0")
    private String device;

    protected IOPort getPort() throws IOException {
        var commPort = SerialPort.getCommPort(device);
        if (commPort.isOpen()) throw new IOException("Port is opened already");
        commPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_BLOCKING | SerialPort.TIMEOUT_WRITE_BLOCKING, 1_000, 1_000);
        commPort.setFlowControl(SerialPort.FLOW_CONTROL_DISABLED);
        commPort.setBaudRate(9600);
        commPort.setNumDataBits(8);
        commPort.setNumStopBits(1);
        commPort.setParity(SerialPort.EVEN_PARITY);
        if (!commPort.openPort()) throw new IOException("Can't open the port");
        return new IOPort(commPort);
    }

    public static class IOPort implements AutoCloseable {
        public final OutputStream outputStream;
        public final InputStream inputStream;
        private final SerialPort serialPort;

        public IOPort(SerialPort serialPort) {
            this.serialPort = serialPort;
            inputStream = serialPort.getInputStream();
            outputStream = serialPort.getOutputStream();
        }

        @Override
        public void close() throws Exception {
            serialPort.closePort();
        }
    }
}
