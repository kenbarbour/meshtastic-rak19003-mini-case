use <lib/rak19003.scad>;
use <lib/utils.scad>;

module case_frame(
	length=47,      // x-length; excludes lanyard loop
	width=50,       // y-width
	thickness=10    // z-height; overall height of this part
) {
	/*
	 * TODO: refactor this so that the width and length are configurable
	 * directly, and the bolt pattern is purely functional
	 */
	flange = 1.25; // Thickness of the mounting flange for board
	wallThickness = [5, 6, 2, 6]; // 0:top, 1:right, 2:bottom, 3:left
	boardOffset = [.2, 1, 0.25];
	mountHoleOffset = 3;
	mountHoleSize = 3;
	e = 0.1; // some additional length 

	// TODO: add BLE antenna
	bleAntClearance = 2.6; // clearance for the thickness of the BLE antenna
	bleWall = 1.6;
	bleWidth = bleWall + bleAntClearance;

	cavityLength = length - wallThickness[2] - wallThickness[0];
	cavityWidth = width - wallThickness[1] - wallThickness[3] - bleWidth;


	// DESIGN CHECK: ensure that the inner cavity is large enough
	minCavityLength = 40;
	minCavityWidth = 32;
	assert(cavityLength >= minCavityLength, "case-frame inner cavity is not long enough");
	assert(cavityWidth >= minCavityWidth, "case-frame inner cavity is not wide enough");

	
	difference() {
		cube([
			length,
			width,
			thickness
		]);

		// Remove main cavity
		difference() {
			translate([
				wallThickness[2],
				wallThickness[1],
				0-e
			]) cube([
				cavityLength,
				cavityWidth + bleWidth,
				thickness+2*e
				]);

			// board mount - offset to match board
			translate([
				wallThickness[2] + boardOffset[0],
				wallThickness[1] + boardOffset[1] + bleWidth,
				0
			])
				board_mount(thickness=flange, zOffset=boardOffset[2]);

			// BLE Mount
			bleMaxLength = 37;
			translate([
				wallThickness[2],
				wallThickness[1],
				0
			]) ble_mount(
				height=thickness,
				length=min(bleMaxLength, cavityLength),
				wall=bleWall,
				clearance=bleAntClearance);
		}

		// Case cover mounting holes
		for ( position = mounting_bolts(length, width, mountHoleOffset)) {
			translate([position[0], position[1], 0])
			clearance_hole(mountHoleSize);
		}

		// Corner Radiuses
		translate([0, 0, 0-e])          rotate([0, 0, 0])    z_fillet(3);
		translate([length, 0, 0-e])     rotate([0, 0, 90])   z_fillet(3);
		translate([0, width, 0-e])      rotate([0, 0, 270])  z_fillet(3);
		translate([length, width, 0-e]) rotate([0, 0, 180])  z_fillet(3);

		// antenna mount
		translate([
			length-wallThickness[0] - e,
			width-wallThickness[3] - 6,
			thickness/2
		])
		rotate([90, 0, 0])
		rotate([0, 90, 0])
			antenna_mount();

		// usb port
		translate([
			0-e,
			boardOffset[1] + wallThickness[1] + bleWidth + 14 - 0.5,
			flange + boardOffset[2] + 1.1 - 0.5,
		])
			usb_c(width=10, h=4.25, $fn=24);

	}

	// TODO: add features for grip
	// TODO: add a lanyard attachment

	// Show board for reference only
	translate([
		wallThickness[2] + boardOffset[0],
		wallThickness[1] + boardOffset[1] + bleWidth,
		flange + boardOffset[2]
		])
	%rak19003_model();
	
	// TODO: Show BTLE antenna for reference only
}

module board_mount(thickness=1.2, zOffset=1, overflow=[10,10]) {
	e = 0.1;
	difference() {
		union() {
			translate([0-overflow[0], 0-overflow[1], 0])
			cube([
				7 + overflow[0],
				30 + overflow[1],
				thickness,
			]);
			rak19003_mounting_holes(diameter=4, h=(thickness + zOffset),
			includePartial=false, $fn=16);
		}

		// mount holes - interference for self threading
		translate([0,0,0-e]) {
		rak19003_mounting_holes(diameter=2.4, $fn=16);
		}

		// clearance for large components
		translate([ 2, 7, 0-e ])
			cube([ 10, 15, thickness+2*e ]);
	}
	// simple tab to help stabilize the board
	translate([ 10.5, 0-overflow[1], 0-e ])
		cube([ 5, 2+overflow[1], thickness+2*e ]);
}

module antenna_mount(hex_depth=3) {
	hexagonal_prism(d_flat=8, h=hex_depth);
	clearance_hole(6, e=0.1);
}

module ble_mount(length=40, height=10, wall=1.6, clearance=2.6,) {
	e = 0.01;
	antWidth = 4; // TODO: measure width of patch antenna
	antLength = 35; // TODO: measure length of patch antenna

	assert(height > antWidth, "BLE patch antenna is taller than height (z)");
	assert(length > antLength, "BLE patch antenna is longer than length (x)");

	difference() {
		cube([
			length,
			wall+clearance,
			height
		]);

		// slot for patch antenna
		translate([ 0, 0-e, height - antWidth])
		cube([
			antLength,
			clearance+e,
			antWidth + e
		]);

		// slot for feed line (centered)
		feedLine = 3.5;
		translate([ (antLength-feedLine)/2, clearance-e, 0-e])
			cube([
				feedLine,
				wall + e + e,
				height + e + e
			]);
	}

}

case_frame();
