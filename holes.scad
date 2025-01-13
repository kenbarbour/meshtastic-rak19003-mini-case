
module clearance_hole(d, h=100, clearance=0.2, e=0.1) {
	cylinder(r=(d+clearance)/2, h=h+e, $fn=min(64, 4 + 3*d));
}

module z_fillet(r=5, h=100, e=0.1) {
	difference() {
	translate([0-e, 0-e, 0])
		cube([r+e, r+e, h]);
	translate([r, r, 0-e])
		cylinder(r=r, h=h+e+e, $fn=$fn*4);
	}
}

module hexagonal_prism(d_flat=8, h=10) {
    r = d_flat / sqrt(3); // Circumradius
    cylinder(h=h, r=r, $fn=6);
}

function mounting_bolts(length, width, holeOffset) = [
	[ holeOffset, holeOffset],
	[ holeOffset, width - holeOffset],
	[ length - holeOffset, holeOffset],
	[ length - holeOffset, width - holeOffset]
];
