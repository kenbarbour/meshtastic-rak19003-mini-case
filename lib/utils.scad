
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

module grip_texture(length, depth, height) {
	n = floor(length/depth); // TODO: number of teeth
	e = 0.1;
	xOffset = (length - depth*n)/2;
	difference() {
		translate([0, 0-e, 0-e])
		cube([length, depth+e, height+e+e]);
		for (i = [0:n]) {
			translate([i*depth*2 - xOffset, depth, 0-e])
			cylinder(r=depth, h=height+e+e, $fn=4);
		}
	}
}

module lanyard_loop(length=30, width=8, height=10, overflow=0) {
	e=0.1;
	slotDiameter = 5;
	wall = (height - slotDiameter)/2;
	difference() {
		union() {
			translate([0-overflow, 0, 0])
			cube([height+overflow, length, width]);
			translate([0, length, 0])
				z_fillet(height/2, h=width);
		}
		translate([height, 0, 0-e])
		rotate([0, 0, 90])
		z_fillet(height/2);
		translate([height, length, 0-e])
		rotate([0, 0, 180])
		z_fillet(height/2);

		// slot
		slotLength = length - wall*3 - slotDiameter;
		translate([wall, wall, 0-e])
			round_rect(size=[slotDiameter, slotLength, width+e+e], r=slotDiameter/2);
		translate([height/2, length - slotDiameter/2 - wall, 0-e])
		cylinder(r=slotDiameter/2, h=width+e+e);
	}
}

module round_rect(size=[10, 10, 10], r=1) {
	difference() {
		cube(size);
		if (r > 0) {
			for (i = [[0,0,0], [1,0,90], [1,1,180], [0,1,270]]) {
				translate([i[0]*size[0], i[1]*size[1], -.1])
				rotate([0, 0, i[2]])
					z_fillet(r, h=size[2]+0.2);
			}
		}
	}
}

function mounting_bolts(length, width, holeOffset) = [
	[ holeOffset, holeOffset],
	[ holeOffset, width - holeOffset],
	[ length - holeOffset, holeOffset],
	[ length - holeOffset, width - holeOffset]
];
