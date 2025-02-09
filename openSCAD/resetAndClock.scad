include <common.scad>

module resetAndClock_board() {
    pcb = pcb_cut(9);
    pcb(pcb);
    
    pcb_grid(pcb, 3, 31)
    bended_pin_header_row(8);
    
    pcb_grid(pcb, 3, 0)
    bended_pin_header_row(20);
    
    pcb_grid(pcb, 5, 38)
    chip(8, true);
    
    pcb_grid(pcb, 5, 24)
    chip(8, true);
    
    pcb_grid(pcb, 6, 25)
    cap();
    pcb_grid(pcb, 8, 25)
    cap();
    
    pcb_grid(pcb, 4, 4)
    res();
    
    translate([7.5, -26 , 2])
    square_button(buttons[2]);
    
    pcb_grid(pcb, 5, 10)
    rotate(90)
    res_big();
    
    pcb_grid(pcb, 6, 31)
    rd_electrolytic(rd_electrolytics[0], "220uF35V", z = 3, pitch = inch(0.2));
}

module resetAndClock() {
    reposition_board(9)
    resetAndClock_board();
}

resetAndClock();
