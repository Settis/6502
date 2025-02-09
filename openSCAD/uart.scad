include <common.scad>

module uart_board() {
    pcb = pcb_cut(16);
    pcb(pcb);
    
    pcb_grid(pcb, 3, 0)
    bended_pin_header_row(board_width_pins);
    
    pcb_grid(pcb, 11, 23)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 7, 37)
    chip(28, true, w=hols_step*6);
    
    pcb_grid(pcb, 14, 11)
    rotate(180)
    bended_pin_header_row(5);
    
    pcb_grid(pcb, 14, 16)
    cap();
    
    pcb_grid(pcb, 13, 19)
    rotate(-90)
    chip(16, true);
    
    pcb_grid(pcb, 14, 4)
    led_up();
    
    pcb_grid(pcb, 8, 4)
    res();
    
    pcb_grid(pcb, 11, 11)
    rotate(-90)
    chip(8, true);
}

module uart() {
    reposition_board(16)
    uart_board();
}

uart();
