use <lib/rak19003.scad>;
use <lib/utils.scad>;
use <lib/switch.scad>;

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
	wallThickness = [5, 6, 2, 6.5]; // 0:top, 1:right, 2:bottom, 3:left
	boardOffset = [.2, 1, 0.25];
	mountHoleOffset = 3;
	mountHoleSize = 3;
	e = 0.1; // small number for rounding errors, should NOT affect geometry
	lanyardWidth = min(8, thickness);

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
		union() {
			round_rect([length, width, thickness], r=3);
			translate([
				length, 0, 0
			])
			lanyard_loop(
				width=lanyardWidth,
				length=width-20,
				overflow=length/2 // large enough to overcome the corner fillet
			);
		}

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
			bleMaxLength = 44;
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

		// antenna mount
		translate([
			length-wallThickness[0] - e,
			width-wallThickness[3] - 6,
			thickness/2
		])
		rotate([90, 0, 0])
		rotate([0, 90, 0])
			antenna_mount();
		// clearance for antenna
		antennaClearanceRadius = 7; // space for wide antenna bases
		translate([
			length,
			width-wallThickness[3] - 6,
			thickness/2
		])
		rotate([0, 90, 0])
			cylinder(r=antennaClearanceRadius, h=100);

		// usb port
		translate([
			0-e,
			boardOffset[1] + wallThickness[1] + bleWidth + 14 - 0.5,
			flange + boardOffset[2] + 1.1 - 0.5,
		])
			usb_c(width=10, h=4.25, $fn=24);

		// reset button hole
		translate([
			0-e,
			boardOffset[1] + wallThickness[1] + bleWidth + 7.75,
			flange + boardOffset[2] + 1.1,
		])
			cube([wallThickness[2]+e+e, 2.5, 2]);

		// pushbutton mount
		translate([
			length/2,
			width-5.5,
			thickness-4
		])
		rotate([-90, 0, 0])
		pushbutton_mount();

		// side texture/grip
		gripLength = length - 20;
		translate([
			(length-gripLength)/2,
			0,
			0
		])
		grip_texture(gripLength, 1, thickness+e);

	}

	// TODO: add features for grip

	// Show board for reference only
	translate([
		wallThickness[2] + boardOffset[0],
		wallThickness[1] + boardOffset[1] + bleWidth,
		flange + boardOffset[2]
		])
	%rak19003_model();
	
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

module ble_mount(length=44, height=10, wall=1.6, clearance=2.6,) {
	e = 0.01;
	antWidth = 7; // TODO: measure width of patch antenna
	antLength = 40; // TODO: measure length of patch antenna

	assert(height > antWidth, "BLE patch antenna is taller than height (z)");
	assert(length >= antLength, "BLE patch antenna is longer than length (x)");

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

module pushbutton_mount(clearance=0.2) {
	thru = 20; // large number to go through the other geometry
	// button clearance
	cylinder(r=5/2, h=thru, $fn=16);

	// slot to drop in button
	translate([(12+(2*clearance))/-2, 0-thru, 0])
	cube([12 + (2*clearance), thru, 4.3]);
	translate([(6.9+(2*clearance))/-2, 0-thru, 0])
	cube([6.9 + (2*clearance), thru, 6.3]);

	pushbutton_bk1208(clearance=clearance);

	// TODO: space for leads
	difference() {
		translate([0, 2.5-thru, -5])
		rotate([-90, 0, 0])
		cylinder(r=10, h=thru);

		// leave a tab to hold the button
		translate([-5, 5-thru, 0-thru])
		cube([10, thru, thru]);
	}
	// render button for reference only
	%pushbutton_bk1208();
}

case_frame();

