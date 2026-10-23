// Driven-element variant of the shared tape-measure Yagi holder geometry.
// This is actual OpenSCAD geometry, not a mesh import. The shared source keeps
// all pipe fits, tape curvature, fillets, and chamfers identical between the
// parasitic and driven holders.

$driven_element_holder = true;
include <tape_yagi_element_holder.scad>
