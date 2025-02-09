include <common.scad>

module via1_board() {
    pcb = pcb_cut(23);
    pcb(pcb);
    
    pcb_grid(pcb, 3, 0)
    bended_pin_header_row(board_width_pins);
    
    pcb_grid(pcb, 6, 3)
    rotate(90)
    socket(14);
    
    pcb_grid(pcb, 5, 4)
    cap();
    
    pcb_grid(pcb, 16, 3)
    rotate(90)
    socket(14);
    
    pcb_grid(pcb, 15, 4)
    cap();
    
    pcb_grid(pcb, 10, 10)
    rotate(90)
    chip(16, true);
    
    pcb_grid(pcb, 9, 36)
    chip(40, true, w=hols_step*6);
    
    pcb_grid(pcb, 9, 37)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 21, 18)
    led_up();
    
    pcb_grid(pcb, 21, 19)
    rotate(90)
    res();
    
    pcb_grid(pcb, 21, 29)
    rotate(180) {
        bended_pin_header_row(3);
        jumper();
    }
    
    pcb_grid(pcb, 21, 33)
    rotate(90)
    transistor();
}

module via1() {
    reposition_board(23)
    via1_board();
}

via1();
