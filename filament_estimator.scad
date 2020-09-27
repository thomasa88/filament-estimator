/*


                _________________
               /                 \
              /                   \
             /                     \
            |                       |
            |           O           |
            |                       |
             \                     /
              \                   /
               \_________________/


*/


// Inner radius of the clamp
clamp_radius = 11.7 - 0.2;
// Width of the clamp opening - approximate
clamp_opening = 30;

// Spool distances
// Radius of spool center hole
hole_radius = 26.5;
// Filament radii
min_radius = 53;
// Full spool
max_radius = 89;
max_weight = 750; // g


scale_max_weight = 850;

// Not used in current calculations. Just for rendering.
spool_inner_width = 45.5;

//spool_mass = 217.5; // g
//max_filament_mass = 750; // g
//filament_density = 1.24 / 1000; // g/mm^3

$fn = 50;

FONT_MM = 0.85;
// Overlap for cuts, so OpenSCAD does not intersect surfaces
intersect_margin = 0.01;

*filament();
measure();
clamp();

module filament() {
    color("blue", alpha=0.2)
    translate([0, 0, -spool_inner_width - 0.1])
    difference() {
        cylinder(h=spool_inner_width, r=max_radius);
        translate([0, 0, -spool_inner_width/2])
        cylinder(h=2*spool_inner_width, r=min_radius);
    }
}

function mass_to_radius(m) =
    // Find the area of filament for radius x, then divide it
    // by the area of max filament. Use this ratio to scale
    // the weight m. Then solve for the radius x.
    sqrt((m*(pow(max_radius,2)-pow(min_radius, 2))) / max_weight + pow(min_radius, 2));

// Using filament center as origin
module measure() {
    w = 10;
    d = 1.5;
    line_height = 0.5;
    line_short_length = 2;
    line_long_length = 3;
    line_depth = 0.4;
    font_height_mm = 3;
    scale_max_radius = mass_to_radius(scale_max_weight + 50);
    
    difference() {
        // "Stick"
        translate([hole_radius, -w/2, 0])
        cube([scale_max_radius - hole_radius, w, d]);
        
        // Measure markers
        #for (m = [0:50:scale_max_weight]) {
            x = mass_to_radius(m);
            has_text = (m % 100 == 0);
            line_length = has_text ? line_long_length : line_short_length;
            echo(m=m, x=x);
            // Position vertically and inset
            translate([x, 0, d - line_depth + intersect_margin]) {
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