use <../cover.scad>;

width=50;
length=60;
topThickness=2;
cavityClearance=5; // space for cables
fastenerThickness=2.6; // thickness at the fasteners

thickness = topThickness + cavityClearance;

case_cover(
	length=length,
	width=width,
	hex=false,
	thickness=thickness,
	topThickness=topThickness,
	counterboreDepth=(thickness-fastenerThickness),
	counterboreDiameter=6.2,
	$fn=32
);
