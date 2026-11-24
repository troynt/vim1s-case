// VIM1S V11 case, measured from the supplied STEP assembly. Units: mm.
// Export part="base" and part="lid" separately; both are oriented for printing.
// PETG recommended: 0.2 mm layers, 4 perimeters. No hardware required.
// Base port openings may need supports; print lid exterior-side down.
// Insert PCB onto the four pegs, then press the lid down.
// Release the two exposed catches opposite the buttons with a blunt plastic tool.
// Lift that edge and tilt the lid to disengage the hidden button-side catches.
// The STEP has no heatsink, attached cables or plugs; check those on a test print.
// The unused 40-pin GPIO header is enclosed beneath the lid.
// The small underside opening beneath USB-C is closed.
// Front opening styles follow diy-case-210917.stp, sized for the VIM1S sockets.
// Heatsink is a generic purchased-part visualization, never part of printed exports.
// Walls/lid are raised 3 mm for a 20 x 20 x 10 mm heatsink and 0.5 mm pad.
// The rear wall is closed; the button side has only three external button holes.
// The lid has ventilation slots only; accessory connector openings are closed.
// Snap tabs join the continuous locating rim; their lower sections flex freely.
// Exterior corner fillets are formed first, then top/bottom edge chamfers.

/* [Output] */
part = "layout"; // [layout,base,lid,assembled,exploded,open]
show_pcb = false; // Preview only; requires the included pcb.stl
show_heatsink = true; // Preview only: 20 x 20 x 10 mm sink and 0.5 mm thermal pad

/* [Print fit] */
wall = 2.0;
floor_thickness = 2.0;
lid_thickness = 2.0;
fit_clearance = 0.25;
snap_interference = 0.30;
peg_diameter = 1.70;
button_hole_diameter = 4.5;
port_clearance = 0.35;

/* [Hidden] */
$fn = 48;
eps = 0.02;
pcb_thickness = 1.2;
pcb_top = floor_thickness + 5.5 + pcb_thickness;
pcb_under = pcb_top - pcb_thickness;
// The STEP includes copper/plating a few microns below the nominal laminate.
pcb_seat = pcb_under - 0.05;
lid_z = pcb_top + 14.8;
outer_top = lid_z + lid_thickness;
// Origin: minimum PCB X/Y; Z=case bottom. Ports face +Y, buttons face +X.
step_offset = [5.83999, 62.952, pcb_top];
inner_min = [-0.9, -1.0];
inner_max = [83.4, 57.4];
outer_min = [inner_min[0]-wall, inner_min[1]-wall];
outer_max = [inner_max[0]+wall, inner_max[1]+wall];
outer_size = [outer_max[0]-outer_min[0], outer_max[1]-outer_min[1]];
holes = [[2.49999,3.13419], [79.49999,3.13419],
         [16.49999,48.63420], [65.49999,48.63420]];
clip_y = [20, 46];
clip_width = 8;
clip_drop = 7;
clip_bottom = lid_z - clip_drop;
clip_bump_z = clip_bottom + 0.2;
clip_bump_height = 1.6;
rim_thickness = 1.0;
rim_depth = 2.5;
corner_radius = 3.0;
edge_chamfer = 0.8;

assert(wall >= 1.8, "Wall must be at least 1.8 mm.");
assert(fit_clearance >= 0.15 && fit_clearance <= 0.5,
       "Use 0.15 to 0.5 mm fit clearance.");
assert(snap_interference >= 0.1 && snap_interference <= 0.4,
       "Use 0.1 to 0.4 mm snap interference.");
assert(peg_diameter > 0 && peg_diameter <= 1.9,
       "The measured PCB mounting holes are 2.2 mm diameter.");
assert(button_hole_diameter >= 3 && button_hole_diameter <= 6,
       "Button access diameter must be 3 to 6 mm.");
assert(port_clearance >= 0.25 && port_clearance <= 0.5,
       "Use 0.25 to 0.5 mm connector clearance.");
assert(edge_chamfer >= 0 &&
       edge_chamfer < min(wall,floor_thickness,lid_thickness,corner_radius),
       "Chamfer must be smaller than the wall, floor, lid and corner radius.");
assert(part == "layout" || part == "base" || part == "lid" ||
       part == "assembled" || part == "exploded" || part == "open",
       "Unknown part selector.");

module rounded_box(lo, hi, z, height, radius) {
    translate([lo[0],lo[1],z])
        linear_extrude(height=height)
            hull()
                for (x=[radius,hi[0]-lo[0]-radius])
                    for (y=[radius,hi[1]-lo[1]-radius])
                        translate([x,y]) circle(r=radius);
}

module finished_exterior(z, height, bottom=0, top=0) {
    intersection() {
        rounded_box(outer_min,outer_max,z,height,corner_radius);
        union() {
            rounded_box(outer_min,outer_max,z+bottom,
                        height-bottom-top,corner_radius);
            // Extend the hull sections beyond the final faces so clipping
            // produces exact 45-degree chamfers without flat edge steps.
            if (bottom > 0)
                hull() {
                    rounded_box(outer_min+[bottom+2*eps,bottom+2*eps],
                                outer_max-[bottom+2*eps,bottom+2*eps],
                                z-2*eps,eps,corner_radius-bottom-2*eps);
                    rounded_box(outer_min,outer_max,z+bottom,eps,corner_radius);
                }
            if (top > 0)
                hull() {
                    rounded_box(outer_min,outer_max,
                                z+height-top-eps,eps,corner_radius);
                    rounded_box(outer_min+[top+2*eps,top+2*eps],
                                outer_max-[top+2*eps,top+2*eps],
                                z+height+eps,eps,corner_radius-top-2*eps);
                }
        }
    }
}

module box_between(lo, hi) {
    translate(lo) cube(hi-lo);
}

module rounded_profile(center, size, radius) {
    translate(center)
        hull()
            for (x=[-size[0]/2+radius,size[0]/2-radius])
                for (z=[-size[1]/2+radius,size[1]/2-radius])
                    translate([x,z]) circle(r=radius);
}

module connector_profile(kind) {
    if (kind == "usb_left" || kind == "usb_right")
        rounded_profile([kind == "usb_left" ? 7.25 : 74.80,3.10],
                        [13.10,5.72],0.60);
    else if (kind == "usb_c")
        rounded_profile([58.50,1.63],[8.94,3.16],1.58);
    else if (kind == "hdmi")
        // Stepped trapezoid measured across the HDMI shell's front lip.
        polygon([[36.00,2.878],[36.00,5.360],[36.798,6.158],
                 [50.205,6.158],[51.005,5.362],[51.005,2.878],
                 [50.437,2.115],[49.894,1.944],[49.757,1.856],
                 [48.891,0.877],[48.294,0.605],[38.711,0.605],
                 [38.109,0.877],[37.248,1.856],[37.111,1.944],
                 [36.563,2.115]]);
    else if (kind == "ethernet")
        // RJ45 plug aperture with a stepped latch channel opening underneath.
        polygon([[20.30,4.80],[32.10,4.80],[32.10,-2.00],
                 [29.50,-2.00],[29.50,-3.80],[28.40,-3.80],
                 [28.40,-pcb_top-1],[24.00,-pcb_top-1],
                 [24.00,-3.80],[22.90,-3.80],[22.90,-2.00],
                 [20.30,-2.00]]);
    else if (kind == "sd")
        rounded_profile([43.455,-1.8592],[13.10,1.28],0.20);
}

module profile_extrusion(y, depth, clearance) {
    translate([0,y,pcb_top])
        rotate([90,0,0])
            linear_extrude(height=depth)
                offset(r=clearance) children();
}

module front_opening(kind) {
    profile_extrusion(outer_max[1]+eps,outer_max[1]-54.0+2*eps,
                      port_clearance)
        connector_profile(kind);
    // Offset slices preserve the concave RJ45 latch steps through the edge bevel.
    for (i=[1:3])
        profile_extrusion(outer_max[1]-0.25+i*(0.25+eps)/3,
                          (0.25+eps)/3+eps,port_clearance+0.15*i/3)
            connector_profile(kind);
}

module port_cutouts() {
    for (kind=["usb_left","ethernet","hdmi","sd","usb_c","usb_right"])
        front_opening(kind);
    // A blind rear relief clears the RJ45 housing; the visible face follows its
    // smaller plug-and-latch contour, as in the reference case.
    profile_extrusion(58.575,58.575-54.0,port_clearance)
        rounded_profile([26.20,0.95],[13.80,11.30],0.50);
    // Actuators lie at y=14.434,24.134,33.834; original z=1.8.
    for (y=[14.43418,24.13419,33.83420])
        translate([80.8,y,pcb_top+1.8])
            rotate([0,90,0])
                cylinder(d=button_hole_diameter,h=outer_max[0]-80.8+eps);
}

module vents(z, height) {
    for (x=[9,31,53])
        for (y=[14:4:34])
            translate([x,y,z]) cube([18,2,height]);
}

module post_shape(index,z,height,radius=2.2) {
    // Ethernet overlaps the right edge of the front-left mounting land.
    difference() {
        translate([holes[index][0],holes[index][1],z])
            cylinder(r=radius,h=height);
        if (index == 2)
            box_between([holes[index][0]+0.90,holes[index][1]-3,z-eps],
                        [holes[index][0]+4,holes[index][1]+3,z+height+eps]);
    }
}

module snap_windows() {
    for (y=clip_y) {
        box_between([outer_min[0]-eps,y-clip_width/2-0.3,clip_bump_z-0.15],
                    [inner_min[0]+0.2,y+clip_width/2+0.3,
                     clip_bump_z+clip_bump_height+0.25]);
        box_between([inner_max[0]-0.2,y-clip_width/2-0.3,clip_bump_z-0.15],
                    // Blind pockets retain a solid 1.4 mm exterior wall.
                    [inner_max[0]+0.6,y+clip_width/2+0.3,
                     clip_bump_z+clip_bump_height+0.25]);
    }
}

module base() {
    difference() {
        union() {
            difference() {
                finished_exterior(0,lid_z,bottom=edge_chamfer);
                rounded_box(inner_min,inner_max,floor_thickness,
                            lid_z-floor_thickness+eps,1.0);
            }
            for (i=[0:3]) {
                post_shape(i,floor_thickness-eps,
                           pcb_seat-floor_thickness+eps);
                translate([holes[i][0],holes[i][1],pcb_seat-eps])
                    cylinder(d=peg_diameter,h=pcb_top-0.15-pcb_seat+eps);
            }
        }
        port_cutouts();
        snap_windows();
        vents(-eps,floor_thickness+2*eps);
    }
}

module locating_rim() {
    lo = inner_min + [fit_clearance,fit_clearance];
    hi = inner_max - [fit_clearance,fit_clearance];
    difference() {
        rounded_box(lo,hi,lid_z-rim_depth,rim_depth+eps,1.0);
        rounded_box(lo+[rim_thickness,rim_thickness],
                    hi-[rim_thickness,rim_thickness],
                    lid_z-rim_depth-eps,rim_depth+3*eps,0.5);
    }
}

module catch_bump(x,y,right=false) {
    reach = fit_clearance + snap_interference;
    translate([x,y+clip_width/2,clip_bump_z])
        rotate([90,0,0])
            linear_extrude(height=clip_width)
                polygon(right ?
                    [[-eps,0],[reach,1.0],[reach,clip_bump_height],
                     [-eps,clip_bump_height]] :
                    [[eps,0],[-reach,1.0],[-reach,clip_bump_height],
                     [eps,clip_bump_height]]);
}

module lid_assembled() {
    difference() {
        union() {
            finished_exterior(lid_z,lid_thickness,top=edge_chamfer);
            locating_rim();
            for (y=clip_y) {
                xl = inner_min[0]+fit_clearance;
                xr = inner_max[0]-fit_clearance;
                translate([xl,y-clip_width/2,clip_bottom])
                    cube([rim_thickness,clip_width,clip_drop-rim_depth+eps]);
                translate([xr-rim_thickness,y-clip_width/2,clip_bottom])
                    cube([rim_thickness,clip_width,clip_drop-rim_depth+eps]);
                catch_bump(xl,y);
                catch_bump(xr,y,true);
            }
            // Hold the board on its locating pegs, with 0.25 mm vertical play.
            for (i=[0:3])
                post_shape(i,pcb_top+0.25,lid_z-pcb_top-0.25+eps);
        }
        port_cutouts();
        vents(lid_z-eps,lid_thickness+2*eps);
    }
}

module lid_print() {
    // Exterior roof on the bed; rim, catches and hold-down posts grow upward.
    translate([0,0,outer_top]) mirror([0,0,1]) lid_assembled();
}

module pcb_reference() {
    if (show_pcb && $preview)
        color([0.12,0.55,0.30]) translate(step_offset) import("pcb.stl");
}

module heatsink_reference() {
    if (show_heatsink && $preview)
        // Centered on the 12.88 x 10.48 mm SoC; pad rests on its top face.
        translate([40.94279-10,23.455-10,pcb_top+1.27]) {
            color([0.30,0.32,0.35]) cube([20,20,0.5]);
            translate([0,0,0.5]) color([0.75,0.78,0.80]) {
                cube([20,20,1.5]);
                for (i=[0:6])
                    translate([i*19/6,0,1.5]) cube([1,20,8.5]);
            }
        }
}

if (part == "base") base();
else if (part == "lid") lid_print();
else if (part == "layout") {
    base();
    translate([outer_size[0]+8,0,0]) lid_print();
}
else {
    color([0.2,0.35,0.5]) base();
    if (part != "open")
        translate([0,0,part == "exploded" ? 18 : 0])
            color([0.7,0.8,0.88]) lid_assembled();
    pcb_reference();
    heatsink_reference();
}
