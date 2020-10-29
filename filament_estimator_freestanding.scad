/*

Filament Estimator - Dip down version.

Copyright Thomas Axelsson 2020.

License: CC BY-SA 4.0

*/

/* [Filament Calculations] */
// Spool distances
// Radius from the spool center to where the filament starts
empty_radius = 53;
// Radius from the spool center to sample point on filament
sample_radius = 89;
// Weight of the filament at sample point.
sample_weight = 750; // g
// Radius of the spool outer edge. Used as reference point when measuring.
spool_radius = 99.5;

/* [Scale] */
// Filament type label
filament_type = "PLA";

// Maximum weight to show on the scale. Determines the length of the scale.
///scale_max_weight = 850;
/// will be calculated

// How much weight each line on the scale represents.
scale_step = 50;

// How often too label the lines, in weight.
scale_label_step = 100;

/* [Test] */
show_spool = 0; // [0:no, 1:yes]

/* [Hidden] */

// Not used in current calculations. Just for rendering.
// The width of the spool
spool_inner_width = 45.5;

// Smooth arcs
$fn = 50;

// Font size
FONT_MM = 0.85;

// Overlap for cuts, so OpenSCAD does not intersect surfaces
intersect_margin = 0.01;

if (show_spool) {
    filament();
    spool();
}
// Translate the measure to align it with the test spool & filament
translate([sample_radius - empty_radius, 0, 0])
measure();

module filament() {
    color("blue", alpha=0.2)
    difference() {
        cylinder(h=spool_inner_width, r=sample_radius);
        translate([0, 0, -spool_inner_width/2])
        cylinder(h=2*spool_inner_width, r=empty_radius);
    }
}

module spool() {
    thickness = 1;
    color("black", alpha=0.2)
    translate([0, 0, -thickness - intersect_margin])
    difference() {
        cylinder(h=thickness, r=spool_radius);
        translate([0, 0, -thickness/2])
        cylinder(h=2*thickness, r=empty_radius);
    }
}

function mass_to_offset(m) =
    sqrt((m / sample_weight) * 
         (pow(sample_radius,2) - pow(empty_radius, 2))
         + pow(empty_radius, 2))
        - empty_radius;

function offset_to_mass(offset) =
    sample_weight *
       (pow(offset + empty_radius, 2) - pow(empty_radius, 2)) /
       (pow(sample_radius, 2) - pow(empty_radius, 2));

// Using filament center as origin
module measure() {
    w = 10;
    d = 1.5;
    line_height = 0.5;
    line_short_length = 2;
    line_long_length = 3;
    line_depth = 0.4;
    font_height_mm = 3;
    label_font_height_mm = 4;
    //scale_max_radius = mass_to_offset(scale_max_weight + 50) + 5;
    scale_length = spool_radius - empty_radius;
    measure_length = scale_length + 10;
    scale_max_weight = offset_to_mass(scale_length);
    
    difference() {
        // "Stick"
        translate([empty_radius, -w/2, 0])
        cube([measure_length, w, d]);
        
        // Inset text and markers
        translate([0, 0, d - line_depth + intersect_margin]) {
            // Top label
            translate([empty_radius + measure_length - 2, 0, 0])
            linear_extrude(line_depth)
            rotate([0, 0, -90])
            text(filament_type, label_font_height_mm * FONT_MM,
                 "Liberation Sans:style=Bold", halign="center",
                 valign="top");
            
            // Measure markers
            for (m = [0:scale_step:scale_max_weight]) {
                offset = mass_to_offset(m);
                // Only put text at the label step and only when it will
                // fit within the height.
                has_text = (m % scale_label_step == 0) && (scale_length - offset > font_height_mm / 2);
                line_length = has_text ? line_long_length : line_short_length;
                echo(m=m, offset=offset);
                // Position vertically
                translate([spool_radius - offset, 0, 0]) {
                    // Line - left of origin. Position on edge.
                    translate([-line_height/2, w/2 - line_length, 0])
                    cube([line_height, line_length, line_depth]);
                    
                    // Text - right of origin
                    if (has_text) {
                        // Spacing
                        linear_extrude(height = line_depth)
                        // Move sideways
                        translate([0, w/2 - line_length - 0.5, 0])
                        // Vertical align
                        translate([-font_height_mm/2, 0, 0])
                        rotate([0, 0, -90])
                        text(str(m), font_height_mm * FONT_MM,
                             "Liberation Sans");
                    }
                }
            }
        }
    }
}
