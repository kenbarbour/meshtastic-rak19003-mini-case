module rak19003_mounting_holes(diameter=2.70, h=5, includePartial=true) {
	positions = [
		[4.00, 4.00],
		[4.00, 26.00],
		/* [35.00, 15.00], */
	];
	for (position = positions) {
		translate(position) {
			cylinder(d=diameter, h=h);
		}
	}
	if (includePartial) {
		translate([35, 15]) {
			cylinder(d=diameter, h=h);
		}
	}
}

module rak19003_board() {
	thickness = 1.1;
	e = 0.1;
	difference() {
		color("#555555")
			cube([35, 30, thickness]); // TODO: verify board thickness
		
		translate([15.5, 0-e, -1*e])
		cube([28.5-15.5, 8+e, thickness+(2*e)]);
		translate([0,0,-0.1]) rak19003_mounting_holes($fn=8);
	}


	translate([-0.9, 14, thickness]) usb_c_port();
	translate([0, 8, thickness]) reset_button();
	translate([0.5, 1, thickness]) led();
	translate([0.5, 5, thickness]) led();
	
	// various large components
	color("#CC9900")
		translate([3.5, 8.25, -2.25])
		cube([3, 3.6, 2.25]);
	color("#333333")
		translate([3.9, 17.3, -0.9])
		cube([1.5, 2.9, 0.9]);
		
	translate([12, 0, thickness + 0.8]) rak_core_board();
}

module rak_core_board() {
	color("#555555")
		cube([20, 30, 1.1]);
	color("#119933")
	translate([2.5, (30-23.5)/2, 1.1])
		cube([15, 23.5, 0.9]);
	color("#CCCCCC")
	translate([3, 8.6, 2])
		cube([9.9, 17, 2]);
	color("#CCCCCC")
	translate([7, 4.3, 2])
		cube([9.6, 17, 2]);
}

module usb_c_port() {
	color("#CCCCCC")
		usb_c();
		/* cube([7.7, 9.0, 3.25]); */
}

module usb_c(width=9, h=3.25, depth=7.7) {
	thickness=h;
	r=thickness/2;
	rotate([90, 0, 90]) {
		translate([r, r, 0])
			cylinder(r=r, h=depth);
		translate([width-r, r, 0])
		cylinder(r=r, h=depth);
		translate([r, 0, 0])
			cube([width-thickness, thickness, depth]);
	}
}



module reset_button() {
	majThickness = 1.85;
	btnThickness = 0.9;
	majWidth = 4.5;
	btnWidth = 1.9;
	btnProud = 1.2;
	color("#FFEEEE") // cream color in hex
		translate([btnProud, 0, 0])
		cube([2.6, majWidth, majThickness]);
	color("#777777")
		translate([0, (majWidth - btnWidth)/2, (majThickness - btnThickness)/2])
		cube([btnProud, btnWidth, btnThickness]);
}

module led() {
	cube([0.9, 2, 0.5]);
}

module rak19003_model() {
	rak19003_board();

}

rak19003_model();
