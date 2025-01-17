use <../cover.scad>;

width=50;
length=60;
thickness=4;
fastenerThickness=2.6; // thickness at the fasteners

case_cover(
	length=length,
	width=width,
	hex=false,
	counterboreDepth=(thickness-fastenerThickness),
	counterboreDiameter=6.2,
	$fn=32,
);
