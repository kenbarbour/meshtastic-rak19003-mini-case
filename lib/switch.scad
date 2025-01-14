module pushbutton_bk1208(clearance=0) {
	color("#555555")
	intersection() {

		union() {
			cylinder(r=12/2 + clearance, h=4.3);
			cylinder(r=6.9/2 + clearance, h=6.3);
			cylinder(r=4.4/2 + clearance, h=8.2);
		}

		cube([24+(2*clearance), 7.94+(2*clearance), 100], center=true);
	}
}
