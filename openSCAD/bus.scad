include <common.scad>

bus_pcb = pcb_cut();

module bus() {    
    pcb(bus_pcb);
    for(i = [1 : 6 : 60]) {
        pcb_grid(bus_pcb, i, 0)
        pin_socket_row(board_width_pins);
    }
    pcb_grid(bus_pcb, 59, 36)
    usb_connector();
}

bus();
