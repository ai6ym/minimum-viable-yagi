# Misc Printables

A parametric OpenSCAD workspace for small 3D-printable models.

## Prerequisites

- [OpenSCAD](https://openscad.org/downloads.html) 2021.01 or newer
- `make` (already included with the macOS developer command-line tools)

On macOS, install OpenSCAD by dragging the app to `/Applications`. The included
wrapper recognizes both the command-line executable and the standard app bundle,
so changing `PATH` is optional.

## Layout

- `models/` contains printable top-level models. Each `.scad` file is built.
- `lib/` contains reusable modules and functions.
- `build/stl/` contains generated meshes.
- `build/preview/` contains generated PNG previews.
- `scripts/openscad` finds and launches the OpenSCAD CLI.

Generated files under `build/` are ignored by Git.

## Commands

```sh
make check       # confirm OpenSCAD is available
make test        # compile and validate every SCAD model
make stl         # export every model as STL
make stl-presets # export all supported sizes at standard resolution
make highres     # export high-resolution element-holder STLs for printing
make highres-presets # export all supported sizes at high resolution
make preview     # render a PNG for every model
make all         # export STL files and PNG previews
make clean       # remove generated files
```

## Tape-measure Yagi element holder

`models/tape_yagi_element_holder.scad` is the complete parametric model. Its
dimensions and tolerances are grouped together near the top of the file. The
default fit-critical values are:

- 21.336 mm actual pipe OD for the default 1/2-inch nominal pipe
- 22.136 mm pipe bore, including 0.80 mm diametral FDM clearance
- 19.85 x 1.43 mm tape slots for the default 3/4-inch blade; the thickness
  clearance accommodates a coating on the blade end
- 25.85 mm default height, derived from the slot plus 3.00 mm top/bottom walls
- 2.25 mm default tape-blade crown depth
- 2.70 mm self-tapping pilot holes for #6 wood screws
- 5.50 mm rectangular PVC-housing wall around the round bore
- 8.50 mm side access bores for typical #6 pan heads
- 3.00 mm minimum web between the PVC bore and each tape channel
- 0.80 mm lead-in chamfers on both PVC-bore edges

The model exposes `pipe_nominal_inches` and `tape_width_inches` in OpenSCAD's
Customizer. Supported presets are:

| Nominal PVC | Actual Schedule 40 OD | Tape widths |
| --- | ---: | --- |
| 1/2 inch | 0.840 inch | 3/4, 1, and 1-1/4 inch |
| 3/4 inch | 1.050 inch | 3/4, 1, and 1-1/4 inch |

Tape crown depth, slot-bar thickness, terminal position, housing size, bar
length, and overall height derive from those selections.

The part is designed to print upright on its flat rectangular base with
no supports. The horizontal tape pockets bridge only 1.43 mm, and the radial
screw pilots are small enough to bridge cleanly on a typical FDM printer.
Both tape channels pass completely through their bars, allowing tape to extend
in both directions. The retained channel has one face-bearing screw centered
over the pipe; the opposite channel is left free so its two tape ends can fold
back for storage.
Each channel entrance has a curve-following guide that opens both the concave
and convex blade faces instead of flattening the crowned profile at the mouth.
The body has a single rounded-rectangle footprint rather than U-shaped side
gaps. Each PVC set-screw passage retains its original 2.70 mm thread-forming
length from the old housing surface to the pipe, while an 8.50 mm counterbore
through the newly filled side material admits a #6 pan head. The screw head
therefore seats at the original depth and uses the same screw length. The round
pipe bore and all set-screw passages remain separate subtractions.
Curve and circle resolution are intentionally moderate so OpenSCAD previews
remain responsive and exported meshes suit FDM resolution.

Open `models/tape_yagi_element_holder.scad` to inspect, edit, and collaborate
on the standalone model. It contains the geometry directly and imports no mesh.

## Driven-element holder

`models/tape_yagi_driven_element_holder.scad` selects the driven variant of the
same parametric OpenSCAD geometry. Its retained tape channel is split into two
halves by a 20.00 mm central divider. The two #6 terminal-screw locations have a
fixed 37.00 mm center-to-center spacing for every pipe and tape preset.

Each terminal uses the same 2.70 mm self-tapping pilot as the other #6 mounting
screws. The pilot extends 6.50 mm into the plastic backing behind the tape; no
heat-set insert is required. An 8.60 mm washer/head access bore through the
outer wall retains its pronounced 1.20 mm entrance chamfer and joins the
crowned tape cavity across its full diameter. It admits the screw head, washer,
and ring terminals so they clamp the tape directly against the plastic for a
solid electrical and mechanical connection. An 8.60 mm-wide rectangular
continuation runs upward from each circular access bore, parallel to the PVC
pipe and through the top of the block. Both slots use the same direction and
carry the access bore's 1.20 mm entrance chamfer, providing an open path for the
ring-terminal neck and wire. The slot depth follows the crowned tape face for
its full length, meeting the tape cavity without cutting into the plastic
backing or leaving an internal bridge. The opposite folding channel and both
PVC set screws are unchanged.

Open `models/calibration_tag.scad` in the OpenSCAD desktop app for interactive
editing. Press **F5** for a quick preview and **F6** for a full render.

To add a model, create another `.scad` file in `models/`. The Makefile discovers
it automatically. Shared modules can be imported with, for example:

```scad
use <../lib/shapes.scad>
```
