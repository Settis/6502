include <common.scad>

module ram_board() {
    pcb = pcb_cut(12);
    pcb(pcb);
    
    pcb_grid(pcb, 2, 0)
    bended_pin_header_row(board_width_pins);
    
    pcb_grid(pcb, 7, 35)
    chip(28, true);
    
    pcb_grid(pcb, 8, 36)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 7, 15)
    chip(14, true);
    
    pcb_grid(pcb, 8, 16)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 10, 3)
    led_up();
    
    pcb_grid(pcb, 5, 3)
    rotate(90)
    res();
}

module ram() {
    reposition_board(13)
    ram_board();
}

ram();
