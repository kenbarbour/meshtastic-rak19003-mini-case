use <../cover.scad>;

width             = 50;
length            = 50;
topThickness      = 2;
batteryThickness  = 7;
thickness         = topThickness+batteryThickness;
fastenerThickness = 2.6; // thickness at the fasteners

case_cover(
	length=length,
	width=width,
	thickness=thickness,
	topThickness=topThickness,
	hex=true,
	counterboreDepth=(thickness-fastenerThickness),
	counterboreDiameter=6.5,  // wrench size of an M3 + clearance
	$fn=32
);
