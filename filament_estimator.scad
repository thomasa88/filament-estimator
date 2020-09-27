// Radius of the clamp inside
clamp_radius = 11.7 - 0.2;
clamp_opening = 15;

// Spool distances
// Radius of spool center hole
hole_radius = 26.5;
// Inner radius of filament
inner_radius = 53;
// Maximum radius of filament/spool (not used in calculation)
outer_radius = 100;
spool_inner_width = 45.5;

spool_mass = 217.5; // g
max_filament_mass = 750; // g
// Use max filament radius instead - better than density!!!!?
filament_density = 1.24 / 1000; // g/mm^3
//1.24; // g/cm^3 = kg/dm^3

$fn = 50;

FONT_MM = 0.85;
// Overlap for cuts, so OpenSCAD does not intersect surfaces
intersect_margin = 0.001;

filament();
measure();
clamp();

module filament() {
    color("blue", alpha=0.2)
    translate([0, 0, -spool_inner_width - 0.1])
    difference() {
        cylinder(h=spool_inner_width, r=outer_radius);
        translate([0, 0, -spool_inner_width/2])
        cylinder(h=2*spool_inner_width, r=hole_radius);
    }
}

// Using filament center as origin
module measure() {
    w = 10;
    d = 1.5;
    line_height = 0.5;
    line_short_length = 2;
    line_long_length = 3;
    line_depth = 0.4;
    font_height_mm = 3;
    
    difference() {
        // "Stick"
        translate([hole_radius, -w/2, 0])
        cube([outer_radius - inner_radius, w, d]);
        
        // Measure markers
        for (m = [50:50:max_filament_mass]) {
            x = sqrt(m/(PI*filament_density*spool_inner_width)+pow(inner_radius, 2)) - hole_radius;
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
        translate([-clamp_radius, 0, 0])
        cube([clamp_radius, clamp_opening, 4*d], center=true);
    }
}