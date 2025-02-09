include <common.scad>

module cpu_board() {
    pcb = pcb_cut(17);
    pcb(pcb);
    
    pcb_grid(pcb, 3, 0)
    bended_pin_header_row(board_width_pins);
    
    pcb_grid(pcb, 6, 34)
    chip(40, true, w=hols_step*6);
    
    pcb_grid(pcb, 10, 14)
    rotate(-90)
    cap();
    
    pcb_grid(pcb, 13, 34)
    res();
    
    pcb_grid(pcb, 5, 36)
    res_big();
    
    pcb_grid(pcb, 15, 19)
    rotate(90)
    res_big();
    
    pcb_grid(pcb, 15, 12)
    rotate(90)
    res_big();
    
    pcb_grid(pcb, 15, 2)
    led_up();
    
    pcb_grid(pcb, 15, 5)
    led_up();
    
    pcb_grid(pcb, 9, 2)
    res();
    
    pcb_grid(pcb, 9, 5)
    res();
    
    pcb_grid(pcb, 8, 8)
    res_big();
}

module cpu() {
    reposition_board(17)
    cpu_board();
}

cpu();
