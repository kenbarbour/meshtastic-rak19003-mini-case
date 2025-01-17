use <lib/utils.scad>;

module case_cover(
	length=47,
	width=50,
	thickness=4,
	hex=false,
	counterboreDepth=3,
	counterboreDiameter=8) {

	bottomThickness = 1;
	topThickness = 2;
	mountHoleOffset = 3; // must match the value in case_frame
	mountHoleSize = 3;
	draftOffset = 1;
	wallThickness = 2;
	wrenchSize = hexWrenchSize(counterboreDiameter);
	echo("Counterbore size: ", counterboreDiameter, "\n");
	echo("Wrench size: ", wrenchSize, "\n");
	e = 0.1; // small waste number; not for final geometry

	assert(thickness >= (counterboreDepth+bottomThickness), "case_cover thickness is too small");

	difference() {
		union() {
			cube([
				length,
				width,
				bottomThickness
			]);
			translate([0, 0, bottomThickness])
				truncated_pyramid(length=length, width=width, height=thickness-bottomThickness, inset=draftOffset);

			// Feet - for stability
			footWidth = 5;
			translate([0, (width - footWidth)/2, 0])
				cube([ length/2, footWidth, thickness]);

		}

		for (
			position = mounting_bolts(length, width, mountHoleOffset)
		) {
			translate([position[0], position[1], 0]) {
				clearance_hole(mountHoleSize);
				translate([0,0, thickness - counterboreDepth])
				if (hex) {
					cylinder(r=wrenchSize/2, h=counterboreDepth+e+e, $fn=6);
				} else {
					clearance_hole(counterboreDiameter, counterboreDepth+e);
				}
			}
		}
		if (hex) { // remove extra material in corners if hex is used
			positions = mounting_bolts(length, width, mountHoleOffset);
			zOffset = thickness - counterboreDepth;
			xCornerOffset = 0 + counterboreDiameter/6 + mountHoleOffset - counterboreDiameter/2;
			yCornerOffset = 0;
			// bottom left
			translate([0, 0, zOffset])
			cube([positions[0][0] + xCornerOffset, positions[0][1]+yCornerOffset, thickness]);
			// TODO: remove material to the corners of the hex
		}
		// Corner Radiuses
		translate([0, 0, 0-e])          rotate([0, 0, 0])    z_fillet(3);
		translate([length, 0, 0-e])     rotate([0, 0, 90])   z_fillet(3);
		translate([0, width, 0-e])      rotate([0, 0, 270])  z_fillet(3);
		translate([length, width, 0-e]) rotate([0, 0, 180])  z_fillet(3);

		// Inner cavity
		difference() {
			translate([
				wallThickness,
				wallThickness,
				0-e
			])
			cube([
				length - 2*wallThickness,
				width - 2*wallThickness,
				thickness - topThickness + e
			]);

			for (position = mounting_bolts(length, width, mountHoleOffset)) {
				translate([position[0], position[1], 0-e]) {
					innerCavityRadius = max((counterboreDiameter/2)+topThickness,wallThickness);
					cylinder(r=innerCavityRadius, h=thickness-topThickness+e+e);
				}
			}
		}
	}

}

module truncated_pyramid(length, width, height, inset=5) {
	polyhedron(
		points=[
			[0      , 0     , 0]      , // 0
			[length , 0     , 0]      , // 1
			[length , width , 0]      , // 2
			[0      , width , 0]      , // 3

			[inset        , inset       , height] , // 4
			[length-inset , inset       , height] , // 5
			[length-inset , width-inset , height] , // 6
			[inset        , width-inset , height] , // 7
		],
		faces=[
			[1, 0, 4],
			[4, 5, 1],
			[2, 1, 5],
			[5, 6, 2],
			[3, 2, 6],
			[6, 7, 3],
			[0, 3, 7],
			[7, 4, 0],
			[7, 6, 5],
			[4, 7, 5],
			[0, 1, 3],
			[1, 2, 3],
		],
		convexity=1
	);
}

case_cover($fn=32);
