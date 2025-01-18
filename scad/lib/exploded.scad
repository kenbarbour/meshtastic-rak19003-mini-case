use <../case-frame.scad>;
use <../cover.scad>;

/**
 * This is a simple exploded view of the assembly
 */
$fn = 64;
gap = 50; // distance between parts
length = 48; // length of the case
width = 50; // width of the case
battery_thickness = 5;

case_frame(length, width);

translate([0, 0, gap])
case_cover(length, width);

// bottom cover
translate([0, width, -gap])
rotate([180, 0, 0])
case_cover(length, width, hex=true, thickness=battery_thickness+2);
