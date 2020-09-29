/*

Filament Estimator

Copyright Thomas Axelsson 2020.

License: CC BY-SA 4.0

*/

/* [Fastening] */
// Should the measure have a spool holder clamp?
have_clamp = true;

// Inner radius of the clamp. Make it approx 0.2 mm smaller than the spool holder rod.
clamp_radius = 11.5; // 11.7 - 0.2

// Width of the opening in the clamp.
clamp_opening = 30;

/* [Filament Calculations] */
// Spool distances
// Radius of the hole in the center of the spool
hole_radius = 26.5;
// Radius from the spool center to where the filament starts
empty_radius = 53;
// Radius from the spool center to sample point on filament
sample_radius = 89;
// Weight of the filament at sample point.
sample_weight = 750; // g

/* [Scale] */
// Filament type label
filament_type = "PLA";

// Maximum weight to show on the scale. Determines the length of the scale.
scale_max_weight = 850;

// How much weight each line on the scale represents.
scale_step = 50;

// How often too label the lines, in weight.
scale_label_step = 100;

/* [Hidden] */

// Not used in current calculations. Just for rendering.
// The width of the spool
spool_inner_width = 45.5;

$fn = 50;

// Font size
FONT_MM = 0.85;

// Overlap for cuts, so OpenSCAD does not intersect surfaces
intersect_margin = 0.01;

*filament();
measure();
if (have_clamp) {
    clamp();
}

module filament() {
    color("blue", alpha=0.2)
    translate([0, 0, -spool_inner_width - 0.1])
    difference() {
        cylinder(h=spool_inner_width, r=sample_radius);
        translate([0, 0, -spool_inner_width/2])
        cylinder(h=2*spool_inner_width, r=empty_radius);
    }
}

function mass_to_radius(m) =
    // Find the area of filament for radius r, then divide it
    // by the area of max filament. Use this ratio to scale
    // the weight m. Then solve for the radius r.
    sqrt((m*(pow(sample_radius,2)-pow(empty_radius, 2))) / sample_weight + pow(empty_radius, 2));

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
    scale_max_radius = mass_to_radius(scale_max_weight + 50) + 5;
    
    difference() {
        // "Stick"
        translate([hole_radius, -w/2, 0])
        cube([scale_max_radius - hole_radius, w, d]);
        
        // Inset text and markers
        translate([0, 0, d - line_depth + intersect_margin]) {
            // Top label
            translate([scale_max_radius - 2, 0, 0])
            linear_extrude(line_depth)
            rotate([0, 0, -90])
            text(filament_type, label_font_height_mm * FONT_MM,
                 "Liberation Sans:style=Bold", halign="center",
                 valign="top");
            
            // Measure markers
            for (m = [0:scale_step:scale_max_weight]) {
                r = mass_to_radius(m);
                has_text = (m % scale_label_step == 0);
                line_length = has_text ? line_long_length : line_short_length;
                echo(m=m, r=r);
                // Position vertically
                translate([r, 0, 0]) {
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

module clamp() {
    d = 3;
    w = 3;
    translate([hole_radius - clamp_radius, 0, 0])
    difference() {
        cylinder(h=d, r=clamp_radius + w);
        // Hole
        translate([0, 0, -d/2])
        cylinder(h=2*d, r=clamp_radius);
        // Opening
        translate([0, 0, -intersect_margin])
        linear_extrude(2*d)
        // Make walls *2 to cut through the ring completely
        polygon([[0, 0], [-clamp_radius*2, clamp_opening],
                 [-clamp_radius*2, -clamp_opening]]);
    }
}