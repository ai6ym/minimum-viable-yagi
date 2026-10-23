// Parametric tape-measure Yagi element holder.
//
// Print orientation: pipe axis vertical, with z = 0 on the build plate.
// All dimensions are millimetres. Fit-critical dimensions and tolerances are
// grouped here so the model can be tuned without hunting for magic numbers.

$fn = 48;

INCH = 25.4;

// OpenSCAD Customizer presets.
// [0.5:1/2 inch, 0.75:3/4 inch]
pipe_nominal_inches = 0.5;
// [0.75:3/4 inch, 1.0:1 inch, 1.25:1-1/4 inch]
tape_width_inches = 0.75;

function schedule_40_pipe_od_inches(nominal_inches) =
    nominal_inches == 0.5 ? 0.840
    : nominal_inches == 0.75 ? 1.050
    : assert(false, "Unsupported nominal Schedule 40 pipe size") 0;

pipe_outside_diameter =
    schedule_40_pipe_od_inches(pipe_nominal_inches) * INCH;
pipe_diametral_clearance = 0.80;
pipe_bore_diameter = pipe_outside_diameter + pipe_diametral_clearance;
pipe_bore_edge_chamfer = 0.8;

// The square housing and the tape-to-bore web grow together so the tape
// channels move outward without thinning the PVC support wall.
collar_wall = 5.5;
collar_body_size = pipe_bore_diameter + 2 * collar_wall;

// Tape blade and FDM fit adjustments.
tape_width = tape_width_inches * INCH;
tape_thickness = 0.20;
tape_width_clearance = -0.20;
tape_thickness_clearance = 1.73;
tape_slot_height = tape_width + tape_width_clearance;
tape_slot_width = tape_thickness + tape_thickness_clearance;
tape_slot_vertical_wall = 3.0;
collar_height = tape_slot_height + 2 * tape_slot_vertical_wall;
// Crown (sagitta) measured from the blade edges to the center of its face.
// This ratio preserves the proven 1.50 mm crown for the 1/2-inch tape.
tape_crown_ratio = 1.5 / (0.5 * INCH);
tape_crown_depth = tape_width * tape_crown_ratio;
tape_curve_segments = 16;

slot_bar_extension_past_housing = 12.0;
slot_bar_half_length =
    collar_body_size / 2 + slot_bar_extension_past_housing;
tape_crown_outer_wall = 2.45;
arm_width = 2 * (
    tape_crown_depth + tape_slot_width / 2 + tape_crown_outer_wall
);
slot_to_pipe_web = 3.0;

// A #6 wood screw is about 3.5 mm over the threads. The undersized pilot lets
// the wood-screw threads form directly in the printed plastic.
screw_major_diameter = 3.5;
screw_pilot_diameter = 2.7;
screw_hole_edge_chamfer = 0.6;
// Allow a typical #6 pan head to pass through the filled side extensions and
// stop at the original PVC-housing surface, preserving the required screw length.
screw_pan_head_diameter = 7.2;
pipe_screw_head_clearance = 1.3;
pipe_screw_access_diameter =
    screw_pan_head_diameter + pipe_screw_head_clearance;
pipe_screw_access_edge_chamfer = 1.0;

// Driven-element terminal hardware. A #6 screw cuts its own threads into the
// plastic backing. The wide access bore still admits the screw head, washer,
// and ring terminals so they can clamp the tape directly against the plastic.
driven_washer_outside_diameter = 7.0;
driven_washer_access_clearance = 1.6;
driven_terminal_access_diameter =
    driven_washer_outside_diameter + driven_washer_access_clearance;
driven_terminal_access_edge_chamfer = 1.2;
driven_screw_pilot_depth = 6.5;
driven_center_divider_width = 20.0;
driven_terminal_spacing = 37.0;
driven_terminal_pipe_web = 0.8;

outside_fillet = 2.0;
edge_chamfer = 0.65;
body_chamfer_steps = 3;
slot_mouth_chamfer_depth = 1.2;
slot_mouth_chamfer = 0.8;

// Small overlap prevents coincident faces in boolean operations.
boolean_margin = 0.25;
construction_layer = 0.02;

pipe_bore_radius = pipe_bore_diameter / 2;
slot_center_y = pipe_bore_radius + tape_slot_width / 2 + slot_to_pipe_web;
bar_inner_y = slot_center_y - arm_width / 2;
block_half_width = slot_center_y + arm_width / 2;
driven_terminal_x_offset = driven_terminal_spacing / 2;
tape_slot_center_z = collar_height / 2;
tape_slot_bottom_z = tape_slot_center_z - tape_slot_height / 2;
tape_slot_top_z = tape_slot_center_z + tape_slot_height / 2;

function tape_crown_at_z(z_relative) =
    tape_crown_depth
    * max(0, 1 - pow(z_relative / (tape_width / 2), 2));

function tape_profile_z(index, extra_clearance = 0) =
    -(tape_slot_height / 2 + extra_clearance)
    + (tape_slot_height + 2 * extra_clearance)
        * index / tape_curve_segments;

function tape_profile_center_y(index, y_sign, extra_clearance = 0) =
    y_sign
    * (
        slot_center_y
        + tape_crown_at_z(tape_profile_z(index, extra_clearance))
    );

assert(pipe_diametral_clearance > 0, "Pipe clearance must be positive");
assert(pipe_nominal_inches == 0.5 || pipe_nominal_inches == 0.75);
assert(
    tape_width_inches == 0.75
    || tape_width_inches == 1.0
    || tape_width_inches == 1.25,
    "Unsupported tape width"
);
assert(pipe_bore_edge_chamfer > 0);
assert(collar_wall >= 3, "Collar wall is too thin for robust FDM printing");
assert(tape_slot_vertical_wall >= 3);
assert(slot_to_pipe_web >= 3, "PVC-to-tape web is too thin");
assert(
    tape_crown_outer_wall >= 2,
    "Tape crown needs more material on its outer face"
);
assert(tape_slot_height < collar_height - 2 * edge_chamfer);
assert(screw_pilot_diameter < screw_major_diameter);
assert(screw_hole_edge_chamfer > 0);
assert(pipe_screw_access_diameter > screw_pan_head_diameter);
assert(pipe_screw_access_edge_chamfer > 0);
assert(driven_terminal_access_diameter > driven_washer_outside_diameter);
assert(driven_terminal_access_edge_chamfer > screw_hole_edge_chamfer);
assert(driven_screw_pilot_depth > 0);
assert(
    slot_center_y
        + tape_crown_depth
        - tape_slot_width / 2
        - driven_screw_pilot_depth
    > bar_inner_y,
    "Driven #6 pilot breaks through the inner slot wall"
);
assert(driven_center_divider_width > 0);
assert(
    driven_terminal_x_offset
        - screw_pilot_diameter / 2
    > driven_center_divider_width / 2,
    "Driven-element #6 pilots overlap the center divider"
);
assert(
    pow(
        driven_terminal_x_offset - screw_pilot_diameter / 2,
        2
    )
    + pow(bar_inner_y, 2)
    > pow(pipe_bore_radius + driven_terminal_pipe_web, 2),
    "Driven-element #6 pilots are too close to the PVC bore"
);
assert(tape_crown_depth > 0);
assert(tape_curve_segments >= 8);
assert(body_chamfer_steps >= 2);
assert(
    tape_crown_depth + tape_slot_width / 2 < arm_width / 2,
    "Curved tape slot leaves no outer wall for the set screw"
);
assert(
    slot_center_y - tape_slot_width / 2 > pipe_bore_radius,
    "Tape slots must clear the PVC pipe bore"
);

// A 2D rounded rectangle centered at the origin.
module rounded_rectangle_2d(size, radius) {
    assert(radius > 0);
    assert(size.x > 2 * radius && size.y > 2 * radius);

    offset(r = radius)
        square([size.x - 2 * radius, size.y - 2 * radius], center = true);
}

// The complete part has one rectangular plan-view footprint. This fills the
// former U-shaped gaps between the tape-slot arms outside the PVC housing.
module finished_body_outline_2d() {
    rounded_rectangle_2d(
        [2 * slot_bar_half_length, 2 * block_half_width],
        outside_fillet
    );
}

// Approximate a 45-degree exterior chamfer with print-layer-sized 2D offsets.
module chamfered_body() {
    chamfer_step_height = edge_chamfer / body_chamfer_steps;

    translate([0, 0, edge_chamfer])
        linear_extrude(height = collar_height - 2 * edge_chamfer)
            finished_body_outline_2d();

    for (step_index = [0 : body_chamfer_steps - 1]) {
        chamfer_inset =
            edge_chamfer
            * (body_chamfer_steps - step_index)
            / body_chamfer_steps;

        translate([0, 0, step_index * chamfer_step_height])
            linear_extrude(height = chamfer_step_height + construction_layer)
                offset(delta = -chamfer_inset)
                    finished_body_outline_2d();

        translate([
            0,
            0,
            collar_height
                - (step_index + 1) * chamfer_step_height
                - construction_layer
        ])
            linear_extrude(height = chamfer_step_height + construction_layer)
                offset(delta = -chamfer_inset)
                    finished_body_outline_2d();
    }
}

// Extrude a crowned YZ profile along X. Building the curved channel as one
// polygon keeps interactive OpenSCAD previews fast and the source transparent.
module curved_tape_slot_profile(
    x,
    length,
    y_sign,
    extra_clearance = 0
) {
    half_thickness = tape_slot_width / 2 + extra_clearance;
    lower_face = [
        for (index = [0 : tape_curve_segments])
            [
                -tape_profile_z(index, extra_clearance),
                tape_profile_center_y(index, y_sign, extra_clearance)
                    - half_thickness
            ]
    ];
    upper_face = [
        for (index = [tape_curve_segments : -1 : 0])
            [
                -tape_profile_z(index, extra_clearance),
                tape_profile_center_y(index, y_sign, extra_clearance)
                    + half_thickness
            ]
    ];

    translate([x, 0, tape_slot_center_z])
        rotate([0, 90, 0])
            linear_extrude(height = length)
                polygon(points = concat(lower_face, upper_face));
}

function tape_guide_y(
    profile_index,
    y_sign,
    face_sign,
    extra_clearance
) =
    let(half_thickness = tape_slot_width / 2 + extra_clearance)
        tape_profile_center_y(profile_index, y_sign, extra_clearance)
        + face_sign * half_thickness;

function tape_guide_z(profile_index, extra_clearance) =
    tape_slot_center_z + tape_profile_z(profile_index, extra_clearance);

module tape_guide_segment(
    profile_index,
    x_sign,
    y_sign,
    mouth_inner_x,
    mouth_outer_x
) {
    x_min = min(mouth_inner_x, mouth_outer_x);
    x_max = max(mouth_inner_x, mouth_outer_x);
    min_x_extra = x_sign < 0 ? slot_mouth_chamfer : 0;
    max_x_extra = x_sign < 0 ? 0 : slot_mouth_chamfer;

    points = [
        [x_min, tape_guide_y(profile_index, y_sign, -1, min_x_extra),
            tape_guide_z(profile_index, min_x_extra)],
        [x_min, tape_guide_y(profile_index + 1, y_sign, -1, min_x_extra),
            tape_guide_z(profile_index + 1, min_x_extra)],
        [x_min, tape_guide_y(profile_index + 1, y_sign, 1, min_x_extra),
            tape_guide_z(profile_index + 1, min_x_extra)],
        [x_min, tape_guide_y(profile_index, y_sign, 1, min_x_extra),
            tape_guide_z(profile_index, min_x_extra)],
        [x_max, tape_guide_y(profile_index, y_sign, -1, max_x_extra),
            tape_guide_z(profile_index, max_x_extra)],
        [x_max, tape_guide_y(profile_index + 1, y_sign, -1, max_x_extra),
            tape_guide_z(profile_index + 1, max_x_extra)],
        [x_max, tape_guide_y(profile_index + 1, y_sign, 1, max_x_extra),
            tape_guide_z(profile_index + 1, max_x_extra)],
        [x_max, tape_guide_y(profile_index, y_sign, 1, max_x_extra),
            tape_guide_z(profile_index, max_x_extra)]
    ];

    polyhedron(
        points = points,
        faces = [
            [0, 1, 2, 3],
            [4, 7, 6, 5],
            [0, 4, 5], [0, 5, 1],
            [1, 5, 6], [1, 6, 2],
            [2, 6, 7], [2, 7, 3],
            [3, 7, 4], [3, 4, 0]
        ],
        convexity = 4
    );
}

module tape_slot_mouth(x_sign, y_sign) {
    mouth_inner_x = x_sign * (
        slot_bar_half_length - slot_mouth_chamfer_depth
    );
    mouth_outer_x = x_sign * (slot_bar_half_length + boolean_margin);
    // Loft each curve segment separately. A single hull would bridge across
    // the crown's concave face and leave that edge without a useful lead-in.
    for (profile_index = [0 : tape_curve_segments - 1])
        tape_guide_segment(
            profile_index,
            x_sign,
            y_sign,
            mouth_inner_x,
            mouth_outer_x
        );
}

// A continuous tape channel runs across both sides of the part. It remains
// outside the pipe bore because its Y position is tangent to the collar.
module tape_slot(y_sign, center_divider_width = 0) {
    union() {
        if (center_divider_width > 0) {
            half_channel_length =
                slot_bar_half_length
                + boolean_margin
                - center_divider_width / 2;

            curved_tape_slot_profile(
                -slot_bar_half_length - boolean_margin,
                half_channel_length,
                y_sign
            );
            curved_tape_slot_profile(
                center_divider_width / 2,
                half_channel_length,
                y_sign
            );
        } else {
            curved_tape_slot_profile(
                -slot_bar_half_length - boolean_margin,
                2 * (slot_bar_half_length + boolean_margin),
                y_sign
            );
        }

        tape_slot_mouth(-1, y_sign);
        tape_slot_mouth(1, y_sign);
    }
}

module pipe_set_screw_hole(x_sign) {
    hole_start_x = x_sign * (pipe_bore_radius - boolean_margin);
    hole_length = collar_wall + 2 * boolean_margin;
    housing_half_size = collar_body_size / 2;
    access_start_x = x_sign * housing_half_size;
    access_length =
        slot_bar_half_length - housing_half_size + boolean_margin;
    chamfer_start_x = x_sign * (
        slot_bar_half_length - pipe_screw_access_edge_chamfer
    );
    chamfer_mouth_diameter =
        pipe_screw_access_diameter
        + 2 * pipe_screw_access_edge_chamfer;

    union() {
        // Preserve the original thread-forming pilot from the PVC bore to the
        // original housing surface.
        translate([hole_start_x, 0, collar_height / 2])
            rotate([0, x_sign * 90, 0])
                cylinder(h = hole_length, d = screw_pilot_diameter);

        // The added rectangular side material is clearance only. The pan head
        // slides through and seats at the original housing surface.
        translate([access_start_x, 0, collar_height / 2])
            rotate([0, x_sign * 90, 0])
                cylinder(
                    h = access_length,
                    d = pipe_screw_access_diameter
                );

        translate([chamfer_start_x, 0, collar_height / 2])
            rotate([0, x_sign * 90, 0])
                cylinder(
                    h = pipe_screw_access_edge_chamfer + boolean_margin,
                    d1 = pipe_screw_access_diameter,
                    d2 = chamfer_mouth_diameter
                );
    }
}

module tape_set_screw_hole() {
    tape_screw_y = slot_center_y + arm_width / 2 + boolean_margin;
    tape_outer_face_y =
        slot_center_y + tape_crown_depth + tape_slot_width / 2;
    tape_screw_length =
        tape_screw_y - tape_outer_face_y + boolean_margin;
    tape_screw_external_y = slot_center_y + arm_width / 2;
    chamfer_mouth_diameter =
        screw_pilot_diameter + 2 * screw_hole_edge_chamfer;

    // The screw axis is normal to the tape's broad XZ face.
    // X = 0 centers it over the PVC tube and the middle of the tape element.
    union() {
        translate([0, tape_screw_y, tape_slot_center_z])
            rotate([90, 0, 0])
                cylinder(h = tape_screw_length, d = screw_pilot_diameter);

        translate([
            0,
            tape_screw_external_y + boolean_margin,
            tape_slot_center_z
        ])
            rotate([90, 0, 0])
                cylinder(
                    h = screw_hole_edge_chamfer + boolean_margin,
                    d1 = chamfer_mouth_diameter,
                    d2 = screw_pilot_diameter
                );
    }
}

module driven_terminal_hole(x_sign) {
    terminal_x = x_sign * driven_terminal_x_offset;
    bar_external_y = slot_center_y + arm_width / 2;
    tape_inner_face_y =
        slot_center_y + tape_crown_depth - tape_slot_width / 2;
    through_hole_start_y = bar_external_y + boolean_margin;
    pilot_end_y = tape_inner_face_y - driven_screw_pilot_depth;
    pilot_hole_length = through_hole_start_y - pilot_end_y;
    access_bore_edge_z = driven_terminal_access_diameter / 2;
    access_bore_end_y =
        slot_center_y
        + tape_crown_at_z(access_bore_edge_z)
        + tape_slot_width / 2
        - boolean_margin;
    access_hole_length =
        through_hole_start_y - access_bore_end_y;
    terminal_slot_min_x =
        terminal_x - driven_terminal_access_diameter / 2;
    terminal_slot_start_z = tape_slot_center_z;
    terminal_slot_height =
        collar_height + boolean_margin - terminal_slot_start_z;
    terminal_slot_profile_segments = ceil(tape_curve_segments / 2);
    terminal_slot_outer_y = bar_external_y + boolean_margin;
    access_chamfer_diameter =
        driven_terminal_access_diameter
        + 2 * driven_terminal_access_edge_chamfer;

    assert(
        access_bore_edge_z < tape_width / 2,
        "Driven terminal access bore extends beyond the tape element width"
    );

    union() {
        // The #6 pilot crosses the tape cavity and continues into the plastic
        // backing, where the screw forms its own threads.
        translate([
            terminal_x,
            through_hole_start_y,
            tape_slot_center_z
        ])
            rotate([90, 0, 0])
                cylinder(
                    h = pilot_hole_length,
                    d = screw_pilot_diameter
                );

        // The flat-bottomed washer/head access reaches far enough to meet the
        // crowned tape cavity at every point across the bore diameter.
        translate([
            terminal_x,
            through_hole_start_y,
            tape_slot_center_z
        ])
            rotate([90, 0, 0])
                cylinder(
                    h = access_hole_length,
                    d = driven_terminal_access_diameter
                );

        // Open the circular recess upward, parallel to the PVC pipe. Each
        // segment follows the crowned tape face instead of using a fixed depth,
        // so the cut meets the tape cavity everywhere without entering the
        // plastic backing behind it.
        for (profile_segment = [0 : terminal_slot_profile_segments - 1])
            let(
                z_relative_0 = tape_slot_height / 2
                    * profile_segment / terminal_slot_profile_segments,
                z_relative_1 = tape_slot_height / 2
                    * (profile_segment + 1)
                    / terminal_slot_profile_segments,
                inner_y_0 = slot_center_y
                    + tape_crown_at_z(z_relative_0)
                    + tape_slot_width / 2
                    - construction_layer,
                inner_y_1 = slot_center_y
                    + tape_crown_at_z(z_relative_1)
                    + tape_slot_width / 2
                    - construction_layer
            )
                hull() {
                    translate([
                        terminal_slot_min_x,
                        inner_y_0,
                        tape_slot_center_z + z_relative_0
                    ])
                        cube([
                            driven_terminal_access_diameter,
                            terminal_slot_outer_y - inner_y_0,
                            construction_layer
                        ]);

                    translate([
                        terminal_slot_min_x,
                        inner_y_1,
                        tape_slot_center_z + z_relative_1
                    ])
                        cube([
                            driven_terminal_access_diameter,
                            terminal_slot_outer_y - inner_y_1,
                            construction_layer
                        ]);
                }

        // Above the tape edge, carry the final edge depth through the top face.
        terminal_slot_edge_y =
            slot_center_y + tape_slot_width / 2 - construction_layer;
        translate([
            terminal_slot_min_x,
            terminal_slot_edge_y,
            tape_slot_top_z
        ])
            cube([
                driven_terminal_access_diameter,
                terminal_slot_outer_y - terminal_slot_edge_y,
                collar_height + boolean_margin - tape_slot_top_z
            ]);

        // Match the circular access bore's entrance chamfer along the two
        // vertical slot edges and its lower end. The upper end exits the body.
        hull() {
            translate([
                terminal_slot_min_x,
                bar_external_y - driven_terminal_access_edge_chamfer,
                terminal_slot_start_z
            ])
                cube([
                    driven_terminal_access_diameter,
                    construction_layer,
                    terminal_slot_height
                ]);

            translate([
                terminal_slot_min_x
                    - driven_terminal_access_edge_chamfer,
                bar_external_y + boolean_margin,
                terminal_slot_start_z
                    - driven_terminal_access_edge_chamfer
            ])
                cube([
                    driven_terminal_access_diameter
                        + 2 * driven_terminal_access_edge_chamfer,
                    construction_layer,
                    terminal_slot_height
                        + 2 * driven_terminal_access_edge_chamfer
                ]);
        }

        translate([
            terminal_x,
            bar_external_y + boolean_margin,
            tape_slot_center_z
        ])
            rotate([90, 0, 0])
                cylinder(
                    h = driven_terminal_access_edge_chamfer + boolean_margin,
                    d1 = access_chamfer_diameter,
                    d2 = driven_terminal_access_diameter
                );
    }
}

module pipe_passthrough_hole() {
    chamfer_mouth_diameter =
        pipe_bore_diameter + 2 * pipe_bore_edge_chamfer;

    union() {
        translate([0, 0, -boolean_margin])
            cylinder(
                h = collar_height + 2 * boolean_margin,
                d = pipe_bore_diameter
            );

        // Wider at the print-bed face, narrowing to the nominal sliding bore.
        translate([0, 0, -boolean_margin])
            cylinder(
                h = pipe_bore_edge_chamfer + boolean_margin,
                d1 = chamfer_mouth_diameter,
                d2 = pipe_bore_diameter
            );

        // Mirror the same lead-in at the top face.
        translate([0, 0, collar_height - pipe_bore_edge_chamfer])
            cylinder(
                h = pipe_bore_edge_chamfer + boolean_margin,
                d1 = pipe_bore_diameter,
                d2 = chamfer_mouth_diameter
            );
    }
}

module tape_yagi_element_holder(driven = false) {
    difference() {
        chamfered_body();

        pipe_passthrough_hole();

        tape_slot(
            1,
            driven ? driven_center_divider_width : 0
        );
        tape_slot(-1);
        if (driven) {
            driven_terminal_hole(-1);
            driven_terminal_hole(1);
        } else {
            tape_set_screw_hole();
        }
        // The +/-X collar quadrants sit between the offset tape pockets.
        pipe_set_screw_hole(-1);
        pipe_set_screw_hole(1);
    }
}

driven_variant =
    is_undef($driven_element_holder) ? false : $driven_element_holder;
render_top_level =
    is_undef($suppress_top_level_render) || !$suppress_top_level_render;
if (render_top_level)
    tape_yagi_element_holder(driven = driven_variant);
