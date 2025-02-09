include <NopSCADlib-21.33.0/lib.scad>
include <NopSCADlib-21.33.0/vitamins/dip.scad>

//$fa = 1;
//$fs = 0.4;

hols_step = inch(0.1);
board_width_pins = 39;

function pcb_cut(length_pins=62) = ["UP830EP", "Perfboard 160x100mm", length_pins*hols_step, 100, 1.6, 0, 2.3, 0, "green", true, [], [], [], [hols_step*0.5, hols_step*0.75]];

module chip(legs, socketed = false, w = inch(0.3)) {
    translate([w/2, -hols_step*((legs/2-1)/2), 0])
        pdip(legs, "", socketed, w);
}

module socket(legs, w = inch(0.3)) {
    translate([w/2, -hols_step*((legs/2-1)/2), 0])
        dil_socket(legs/2, w);
}

module pin_header_row(count, right_angle = false) {
    rotate([0, 0, 90])
    translate([hols_step * (count-1)/2, 0, 0])
        pin_header(pin_headers[0], count, 1, right_angle = false);
}

module bended_pin_header_row(count) {
    rotate([0, 0, 90])
    translate([hols_step * (count-1)/2, hols_step/2, hols_step*2])
        rotate([90, 0, 0]) difference() {
            pin_header(pin_headers[0], count, 1, right_angle = true);
            translate([0, -hols_step*3.8, hols_step*0.5])
            cube([hols_step*count, hols_step*1.5, hols_step], center = true);
        }
}

module pin_socket_row(count) {
    rotate([0, 0, 90])
    translate([hols_step * (count-1)/2, 0, 0])
        pin_socket(pin_headers[0], count, 1);
}

module res_small() {
    translate([hols_step, 0, 0])
        ax_res(ax_resistors[0], [1000, 47000, 8200][0], 5);
}

module res() {
    translate([hols_step*1.5, 0, 0])
        ax_res(ax_resistors[1], [1000, 47000, 8200][1], 5);
}

module res_big() {
    translate([hols_step*2.5, 0, 0])
        ax_res(ax_resistors[2], [1000, 47000, 8200][2], 5);
}

module usb_connector() {
    translate([hols_step*2.5,-hols_step*1.5,0])
        molex_usb_Ax1(cutout = false);
}

module jumper() {
    eps = 0.001;
    translate([-hols_step/2, 0, hols_step*2])
    rotate([-90, 0, 90])
    // the jumber in zero coords
    translate([-2.5/2, -2.5/2, 0])
    color(grey(40))
    difference() {
        union() {
            difference() {
                union() {
                    translate([0, (2.5-0.7)/2, 0]) cube([5.1, 0.7, 13.6]);
                    cube([5.1, 2.5, 5.97]);
                    translate([0, (2.5-1.2)/2, 13.6-1.2]) cube([5.1, 1.2, 1.2]);
                }
                translate([-eps, -eps, 5.97-1.5]) cube([5.1+2*eps, 2.5+2*eps, 1]);
            }
            translate([0.25, 0.25, 5.97-1.5-eps]) cube([5.1-0.5, 2, 1+2*eps]);
        }
        translate([(5.1-1)/2, -eps, 5.97-2]) cube([1, 3, 5]);
    }
}

module led_up() {
    rotate([-90,0,-90])
    translate([hols_step/2, -3, 5.1])
    // the led
    union() {
    difference() {
    union() {
        translate([0,0,-4])
        led(LED5mm, "green");
        color(grey(20))
        translate([0,0,-9.1/2])
        cube([6,6,9.1], center=true);
    }
        translate([0, -5, -11])
        rotate([45, 0, 0])
        cube(13, center=true);
    }
    color("silver")
        for(side = [-1, 1])
            translate([hols_step/2*side, 4.5, -5.1])
            cube([0.5, 3.5, 0.5], center=true);
    }
}

module cap() {
    i = 0;
    disc = rd_discs[i];
            pitch = rd_disc_pitch(disc);
            dx = round(pitch.x / inch(0.1)) * inch(0.1);
            dy = round(pitch.y / inch(0.1)) * inch(0.1);
            
            translate([0, hols_step, 0])
            rotate(90 - atan2(dy, dx))
                rd_disc(disc, pitch = norm([dy, dx]), z = 0.5, value = ["10nF", "470V", "1nF Y2"][i]);
}

module transistor() {
    translate([hols_step, 0, 0])
    rd_transistor(rd_transistors[1], "", lead_positions = inch(0.1) * [[-1, 0], [0, -sign(0)], [1, 0]]);
}

module reposition_board(length_pins) {
    translate([hols_step*2.6, -hols_step*board_width_pins/2 + hols_step/2, hols_step*0.2 + hols_step*length_pins/2])
    rotate([0, -90, 0])
        children(0);
}
