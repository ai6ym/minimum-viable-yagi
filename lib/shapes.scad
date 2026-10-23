// Reusable primitives shared by models in this workspace.

// A box with rounded vertical corners, centered on the XY plane.
module rounded_box(size = [40, 24, 3], radius = 3) {
    assert(radius > 0, "radius must be positive");
    assert(size.x > radius * 2 && size.y > radius * 2,
           "radius must fit within the box");

    linear_extrude(height = size.z)
        offset(r = radius)
            square([size.x - radius * 2, size.y - radius * 2], center = true);
}

