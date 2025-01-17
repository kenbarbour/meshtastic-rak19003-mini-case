use <../cover.scad>;

width             = 50;
length            = 60;
topThickness      = 2;
batteryThickness  = 6;
thickness         = topThickness+batteryThickness;
fastenerThickness = 2.6; // thickness at the fasteners

case_cover(
	length=length,
	width=width,
	thickness=thickness,
	hex=true,
	counterboreDepth=(thickness-fastenerThickness),
	counterboreDiameter=5.8,  // wrench size of an M3 + clearance
	$fn=32
);
