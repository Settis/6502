include <bus.scad>
use <cpu.scad>
use <ram.scad>
use <rom.scad>
use <via1.scad>
use <via2.scad>
use <uart.scad>
use <resetAndClock.scad>

pcb_grid(bus_pcb, 1+6*9, board_width_pins-1)
    resetAndClock();
    
pcb_grid(bus_pcb, 1+6*7, board_width_pins-1)
    cpu();

pcb_grid(bus_pcb, 1+6*6, board_width_pins-1)
    ram();
    
pcb_grid(bus_pcb, 1+6*5, board_width_pins-1)
    rom();
    
pcb_grid(bus_pcb, 1+6*4, board_width_pins-1)
    uart();

pcb_grid(bus_pcb, 1+6*3, board_width_pins-1)
    via2();

pcb_grid(bus_pcb, 1+6*1, board_width_pins-1)
    via1();
