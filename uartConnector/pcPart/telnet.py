import telnetlib
import random
import sys

host = "192.168.0.168"
port = 23
timeout = 100

with telnetlib.Telnet(host, port, timeout) as session:
    data = random.randint(5, 200)
    session.write(bytes([1, data]))
    response_raw = session.read_some()
    if len(response_raw) == 0:
        print('No response for ping.')
        sys.exit(1)
    response = response_raw[0]
    if response != data + 1:
        print(f"Ping response is wrong. Expected: {data + 1}, but received {response}.")
        sys.exit(1)
    print("Ping is OK")
