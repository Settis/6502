import board
import time

board = board.Board()

while True:
    time.sleep(0.5)
    board.clock.write(0)
    time.sleep(0.5)
    board.clock.write(1)
