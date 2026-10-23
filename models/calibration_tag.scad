use <../lib/shapes.scad>

// A small first model that exercises shared modules and common print features.
$fn = 64;

tag_size = [50, 25, 3];
corner_radius = 4;
hole_diameter = 5;
hole_inset = 7;

difference() {
    rounded_box(tag_size, corner_radius);

    translate([-(tag_size.x / 2) + hole_inset, 0, -0.5])
        cylinder(h = tag_size.z + 1, d = hole_diameter);
}

