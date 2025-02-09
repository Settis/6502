include <common.scad>

module via2_board() {
    pcb = pcb_cut(21);
    pcb(pcb);
    
    pcb_grid(pcb, 3, 1)
    bended_pin_header_row(board_width_pins-1);
    
    pcb_grid(pcb, 5, 2)
    rotate(90)
    socket(14);
    
    pcb_grid(pcb, 4, 3)
    cap();
    
    pcb_grid(pcb, 14, 2)
    rotate(90)
    socket(14);
    
    pcb_grid(pcb, 13, 3)
    cap();
    
    pcb_grid(pcb, 7, 10)
    rotate(90)
    chip(16, true);
    
    pcb_grid(pcb, 15, 10)
    cap();
    
    pcb_grid(pcb, 6, 36)
    chip(40, true, w=hols_step*6);
    
    pcb_grid(pcb, 6, 16)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 19, 9)
    led_up();
    
    pcb_grid(pcb, 17, 10)
    res();
    
    pcb_grid(pcb, 15, 17)
    rotate(90)
    transistor();
}

module via2() {
    reposition_board(21)
    via2_board();
}

via2();
