VERSION_TEXT = "v0.4.1";
DEBUG = false;

NUM_SLOTS = DEBUG ? 1 : 1;
DEBUG_SHOW_CROSS_SECTION = DEBUG;
ROTATE_FOR_PRINTING = !DEBUG;

PLUNGER_PUSHED_IN = true;

STICK_OUT_MARGIN_Z = 0;

$fn = 180;

/*

## v0.4.0

- Refactor into the `compose(…)` paradigm.

## v0.3.1

- Adjust ejector clearances.

## v0.3.0

- Add an ejector.

## v0.2.4

- Refactor for easier maintenance, resizing, and debugging.

## v0.2.3

- Use a separate vertical margin for the casing.
- Slim both casing margins.

## v0.2.2

- Six slots in a zig-sag configuration.

## v0.2.1

- Adopt springs for the sides.

## v0.2.0

- Include clearance in the funnel.

## v0.1.4

- Fix the air hole regression.
- Adjust clearance some more.
- Add a version engraving.

## v0.1.3

- Adjust funnel depth.
- Adjust clearance.

BUG: air hole accidentally failed to be included due to 🤬
 syncing issues (in turn due to workarounds for an OpenSCAD app bug).

## v0.1.2

- Add an air hole in the back.

## v0.1.1

- Add a funnel in the front.

*/

include <./node_modules/scad/aligned_primitives.scad>
include <./node_modules/scad/compose.scad>
include <./node_modules/scad/duplicate.scad>
include <./node_modules/scad/epsilon.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/xyz.scad>

CFEXPRESS_B_CARD_SIZE = [ 29.60, 38.55, 3.85 ];
// CFEXPRESS_B_UPPER_INDENT_SIZE = [ 1.00, 33.65, 0.55 ];

SD_CARD_SIZE = [ 24.5, 32.0, 2.1 ];
// SD_CARD_LOWER_INDENT_SIZE = [ 1.00, 33.65, 0.70 ];

CLEARANCE = 0.15;

DEFAULT_MARGIN = 3;
CASE_MARGIN_Z = 1.5;

FUNNEL_DEPTH = 2.5;
FUNNEL_DEFAULT_MARGIN_Z = 1;
SPRING_WIDTH = 2;

TEXT_ENGRAVING_DEPTH = 0.5;

BEVEL_ROUNDING = 1.5;

EXTRA_INTERNAL_DEPTH_FOR_EJECTOR = 7.3;
EJECTOR_CHUTE_WIDTH_X = 4;
WALL_WIDTH_FOR_EJECTOR_CHUTE = 1;
EJECTOR_RETAINERS_TOTAL_HEIGHT = 2; // Top and bottom accoutn for half each.

TOTAL_EXTRA_WIDTH_FOR_EJECTOR = WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_CHUTE_WIDTH_X;

function slot_bottom_distance_z(card_size) = _z(card_size) + CASE_MARGIN_Z;

module casing(card_size)
{
    translate([ TOTAL_EXTRA_WIDTH_FOR_EJECTOR / 2, 0, 0 ]) minkowski()
    {
        aligned_cube(
            card_size +
                [
                    DEFAULT_MARGIN * 2 - 2 * BEVEL_ROUNDING + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_CHUTE_WIDTH_X,
                    DEFAULT_MARGIN + STICK_OUT_MARGIN_Z - 2 * BEVEL_ROUNDING + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR,
                    2 * CASE_MARGIN_Z - 2 *
                    BEVEL_ROUNDING
                ],
            ".+.");
        translate([ 0, BEVEL_ROUNDING, 0 ]) sphere(BEVEL_ROUNDING);
    }
}

EJECTOR_AXLE_RADIUS = 2;
EJECTOR_AXLE_CLEARANCE = 0.2;
EJECTOR_PLUNGER_WALL_CLEARANCE = 0.5;

EJECTOR_PLUNGER_RETAINER_DEPTH = 5;
EJECTOR_PLUNGER_RETAINER_HEIGHT = 1.5;

// We don't include `y` clearance, since that ensures a snug state when the card is in, and the lever is not
// touching near the spring while printed.
function ejector_axle_center(card_size) = _x_y_(card_size, [ 1 / 2, 1, 0 ]) +
                                          [ 0, STICK_OUT_MARGIN_Z + EJECTOR_AXLE_RADIUS, 0 ];

module funnel_comp(card_size)
{
    negative() minkowski()
    {
        aligned_cube(_x_z_(card_size) + [ 0, _EPSILON, 0 + CLEARANCE * 2 ], "...");
        rotate([ -90, 0, 0 ]) scale([ SPRING_WIDTH, 1, FUNNEL_DEFAULT_MARGIN_Z - CLEARANCE / 2 ])
            cylinder(FUNNEL_DEPTH - _EPSILON, r1 = 1, r2 = 0);
    }
}

module air_hole_comp(card_size)
{
    negative() translate([
        _x(card_size, -1 / 4), _y(card_size) + STICK_OUT_MARGIN_Z - _EPSILON + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR,
        -_z(card_size) / 2 -
        CLEARANCE
    ]) cube([ _x(card_size, 1 / 2), DEFAULT_MARGIN + 2 * _EPSILON, _z(card_size, 1 / 3) ]);
}

module engraving_comp(card_size)
{
    // Version engraving
    negative() translate([
        0, (DEFAULT_MARGIN + _y(card_size) + STICK_OUT_MARGIN_Z) / 2, _z(card_size, 1 / 2) + CASE_MARGIN_Z -
        TEXT_ENGRAVING_DEPTH
    ]) linear_extrude(TEXT_ENGRAVING_DEPTH + _EPSILON)
        text(VERSION_TEXT, size = 5, font = "Ubuntu:style=bold", halign = "center", valign = "center");
}

LARGE_VALUE = 1000;

SPRING_CLEARANCE = 0.2;
SPRING_THICKNESS = 0.75;

SPRING_INSET = 0.1;

function spring_depth(card_size) = _y(card_size) + STICK_OUT_MARGIN_Z;

module spring_shell(card_size)
{
    scale([ SPRING_WIDTH + SPRING_THICKNESS, spring_depth(card_size) / 2 ]) circle(1);
}

module springs_comp(card_size)
{
    positive() color("orange") duplicate_and_mirror() translate(
        [ _x(card_size, 1 / 2) + SPRING_WIDTH, spring_depth(card_size) / 2, _z(card_size, -1 / 2) + SPRING_CLEARANCE ])
        linear_extrude(_z(card_size) - 2 * SPRING_CLEARANCE) difference()
    {
        spring_shell(card_size);
        offset(-SPRING_THICKNESS) spring_shell(card_size);
        translate([ LARGE_VALUE / 2, 0, 0 ]) square(LARGE_VALUE, center = true);
    }
}

module card_slot_comp(card_size)
{
    negative() translate([ 0, STICK_OUT_MARGIN_Z, 0 ])
        aligned_cube(card_size + [ 2 * SPRING_WIDTH, EXTRA_INTERNAL_DEPTH_FOR_EJECTOR, 2 * CLEARANCE ], ".+.");

    positive() % translate([ 0, STICK_OUT_MARGIN_Z, 0 ]) aligned_cube(card_size, ".+.");
}

EJECTOR_LEVER_WIDTH = EJECTOR_AXLE_RADIUS * 2;
EJECTOR_LEVER_PRINTING_ANGLE = PLUNGER_PUSHED_IN ? 40 : 0;

module ejector_lever_comp(card_size)
{
    // Ejector back area
    negative() translate([ _x(card_size, 1 / 2) + SPRING_WIDTH - _EPSILON, _y(card_size) + STICK_OUT_MARGIN_Z, 0 ])
        aligned_cube(
            [
                WALL_WIDTH_FOR_EJECTOR_CHUTE + 2 * _EPSILON, EXTRA_INTERNAL_DEPTH_FOR_EJECTOR, _z(card_size) + 2 *
                CLEARANCE
            ],
            "++.");

    // Ejector axle hole
    negative() translate(ejector_axle_center(card_size))
        cylinder(h = _z(card_size) + 2 * CASE_MARGIN_Z + 2 * _EPSILON, r = EJECTOR_AXLE_RADIUS + EJECTOR_AXLE_CLEARANCE,
                 center = true);

    positive() color("blue") translate(ejector_axle_center(card_size)) rotate([ 0, 0, EJECTOR_LEVER_PRINTING_ANGLE ])
        translate([ SPRING_WIDTH + TOTAL_EXTRA_WIDTH_FOR_EJECTOR - CLEARANCE, 0, 0 ]) difference()
    {
        aligned_cube(_x_z_(card_size) + [ 0, EJECTOR_LEVER_WIDTH, 0 ], "-..");

        translate(-_x_(card_size, 1 / 2)) duplicate_and_mirror([ 0, 1, 0 ]) duplicate_and_mirror()
            translate(_x_(card_size, -1 / 2) + [ 0, -EJECTOR_LEVER_WIDTH / 2, 0 ]) round_bevel_complement(
                height = _z(card_size) + 2 * _EPSILON, radius = EJECTOR_LEVER_WIDTH / 2, center_z = true);
    }

    positive() translate(ejector_axle_center(card_size))
        cylinder(h = _z(card_size) + 2 * CASE_MARGIN_Z, r = EJECTOR_AXLE_RADIUS, center = true);
}

// Depends on other constants, but is much easier to hardcode than computer.
EJECTOR_PLUNGER_EXTRA_DEPTH = 3.1;
PLUNGER_LEVER_CONTACT_ANTI_CLEARANCE = 0;

module ejector_plunger_comp(card_size)
{
    depth_y = _y(card_size) + STICK_OUT_MARGIN_Z + EJECTOR_PLUNGER_EXTRA_DEPTH;

    // Ejector chute
    negative() translate(
        [ _x(card_size, 1 / 2) + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE, EJECTOR_PLUNGER_RETAINER_DEPTH, 0 ])
        aligned_cube(
            [
                EJECTOR_CHUTE_WIDTH_X,
                _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR + STICK_OUT_MARGIN_Z - EJECTOR_PLUNGER_RETAINER_DEPTH,
                _z(card_size) + 2 *
                CLEARANCE
            ],
            "++.");

    // Ejector chute (inner)
    negative() translate([ _x(card_size, 1 / 2) + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE, -_EPSILON, 0 ])
        aligned_cube(
            [
                EJECTOR_CHUTE_WIDTH_X, _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR + STICK_OUT_MARGIN_Z + _EPSILON,
                _z(card_size) + 2 * CLEARANCE -
                EJECTOR_PLUNGER_RETAINER_HEIGHT
            ],
            "++.");

    positive() color("green") translate([
        _x(card_size, 1 / 2) + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WALL_CLEARANCE,
        PLUNGER_PUSHED_IN ? 0 : -EJECTOR_PLUNGER_EXTRA_DEPTH + PLUNGER_LEVER_CONTACT_ANTI_CLEARANCE, 0
    ]) difference()
    {
        union()
        {
            translate([ 0, EJECTOR_PLUNGER_RETAINER_DEPTH + EJECTOR_PLUNGER_EXTRA_DEPTH, 0 ]) aligned_cube(
                [
                    EJECTOR_CHUTE_WIDTH_X - 2 * EJECTOR_PLUNGER_WALL_CLEARANCE,
                    depth_y - EJECTOR_PLUNGER_RETAINER_DEPTH - EJECTOR_PLUNGER_EXTRA_DEPTH, _z(card_size)
                ],
                "++.");
            aligned_cube(
                [
                    EJECTOR_CHUTE_WIDTH_X - 2 * EJECTOR_PLUNGER_WALL_CLEARANCE, depth_y, _z(card_size) -
                    EJECTOR_RETAINERS_TOTAL_HEIGHT
                ],
                "++."); // Top and bottom accoutn for half each.
        }
        translate([ 0, depth_y, 0 ]) mirror([ 0, 1, 0 ]) round_bevel_complement(
            height = _z(card_size) + 2 * _EPSILON, radius = EJECTOR_CHUTE_WIDTH_X / 2, center_z = true);
    }
}

module ejector_comp(card_size)
{
    ejector_lever_comp(card_size);
    ejector_plunger_comp(card_size);
}

module block(card_size, engrave)
{
    compose()
    {
        carvable() casing(card_size);

        card_slot_comp(card_size);
        ejector_comp(card_size);
        springs_comp(card_size);

        if (engrave)
        {
            engraving_comp(card_size);
        }

        if (DEBUG_SHOW_CROSS_SECTION)
        {
            negative() translate([ 0, 0, LARGE_VALUE / 2 ]) cube(LARGE_VALUE, center = true);
        }
    }
}

EXTRA_SLOT_DISTANCE = 1;

module block_array(n, card_size)
{
    render() union()
    {
        for (i = [0:NUM_SLOTS - 1])
        {
            translate([ 0, 0, i * (slot_bottom_distance_z(card_size) + EXTRA_SLOT_DISTANCE) ])
                block(card_size, i == NUM_SLOTS - 1);
        }
    }
}

rotate([ ROTATE_FOR_PRINTING ? -90 : 0, 0, 0 ]) render() difference()
{
    block_array(NUM_SLOTS, CFEXPRESS_B_CARD_SIZE);
}