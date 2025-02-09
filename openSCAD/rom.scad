include <common.scad>

module rom_board() {
    pcb = pcb_cut(16);
    pcb(pcb);
    
    pcb_grid(pcb, 3, 0)
    bended_pin_header_row(board_width_pins);
    
    pcb_grid(pcb, 14, 38)
    rotate(180) {
        bended_pin_header_row(3);
        jumper();
    }
    
    pcb_grid(pcb, 9, 34)
    res_big();
    
    pcb_grid(pcb, 12, 31)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 8, 30)
    chip(28, true, w=hols_step*6);
    
    pcb_grid(pcb, 15, 14)
    rotate(180) {
        bended_pin_header_row(3);
        jumper();
    }
    
    pcb_grid(pcb, 9, 12)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 8, 11)
    chip(14, true);
    
    pcb_grid(pcb, 14, 3)
    led_up();
    
    pcb_grid(pcb, 8, 3)
    res();
}

module rom() {
    reposition_board(16)
    rom_board();
}

rom();
