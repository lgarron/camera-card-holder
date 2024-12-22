VERSION_TEXT = "v0.4.13";

DEBUG = false;
NUM_SLOTS = /* DEBUG ? 1 : */ 4;
DEBUG_SHOW_CROSS_SECTION = DEBUG;
ROTATE_FOR_PRINTING = !DEBUG;

PLUNGER_PUSHED_IN = true;

STICK_OUT_MARGIN_Z = 0;

$fn = 180;

/*

## v0.4.13

- Ensure the axle holes and plunger chutes are properly carved from adjacent stacked casings.

## v0.4.12

- Implement stacking.
- Set the design to 4 slots.

## v0.4.11

- Decrease `EJECTOR_PLUNGER_WALL_CLEARANCE`.
- Decrease the depth of the casing (and adjust the lever to compensate).

## v0.4.10

- Decrease text engraving depth.
- Change the spring compression to be even lighter (again).

## v0.4.9

- Adjust the axle inset further to accommodate double-wall slicing.

## v0.4.8

- Change the axle holder to only have extra print clearance on the supported side.
- Inset the axle for a flush casing.
- Lengthen the lever to require less leverage.

## v0.4.7

- Change the spring compression to be even lighter.

## v0.4.6

- Change the spring compression to be lighter.

## v0.4.5

- Use two half-sized springs on each side instead of a single one.
- Carve space for the card tab to enable the card to sit flush in front.

## v0.4.4

- Fix the plunger front button width.

## v0.4.3

- Remove one of the axle snap connectors.
- Change the lever to be thicker throughout more of its length.
- Reduce `EJECTOR_PLUNGER_WALL_CLEARANCE` further to 0.25.

## v0.4.2

- Swap to a single axle print support.
- Reduce `EJECTOR_PLUNGER_WALL_CLEARANCE` to 0.3.
- Adjust how close ejector plunger and lever distance are at printing time.
- Thicken the lever around the axle.
- Add lever printing supports.

## v0.4.1

- Increase the wall thickness between the card and the ejector plunger, for more subtle leverage and a larger available
front surface that can be turned into a button.
  - Increase ejector plunger depth to compensate.
- Add a bigger ejector button.
- Add snappable axle supports for printing.

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
CASE_BACK_THICKNESS = 1;
CASE_MARGIN_Z = 1.5;

FUNNEL_DEPTH = 2.5;
FUNNEL_DEFAULT_MARGIN_Z = 1;
SPRING_WIDTH = 2;

TEXT_ENGRAVING_DEPTH = 0.25;

BEVEL_ROUNDING = 1.5;

EXTRA_INTERNAL_DEPTH_FOR_EJECTOR = 7.3;
EJECTOR_CHUTE_WIDTH_X = 4;
WALL_WIDTH_FOR_EJECTOR_CHUTE = 3;
EJECTOR_RETAINERS_TOTAL_HEIGHT = 2; // Top and bottom accoutn for half each.
LEVER_BACK_EXTRA_DEPTH = 0;

TOTAL_EXTRA_WIDTH_FOR_EJECTOR = WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_CHUTE_WIDTH_X;

function slot_bottom_distance_z(card_size) = _z(card_size) + CASE_MARGIN_Z + CLEARANCE;
function slot_width_distance_x(card_size) = _x(card_size) + 2 * SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE
                                            + EJECTOR_CHUTE_WIDTH_X + CASE_MARGIN_Z;

module casing(card_size)
{
    translate([ TOTAL_EXTRA_WIDTH_FOR_EJECTOR / 2, 0, 0 ]) minkowski()
    {
        aligned_cube(
            card_size +
                [
                    DEFAULT_MARGIN * 2 - 2 * BEVEL_ROUNDING + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_CHUTE_WIDTH_X,
                    CASE_BACK_THICKNESS + STICK_OUT_MARGIN_Z - 2 * BEVEL_ROUNDING + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR,
                    2 * CASE_MARGIN_Z - 2 *
                    BEVEL_ROUNDING
                ],
            ".+.");
        translate([ 0, BEVEL_ROUNDING, 0 ]) sphere(BEVEL_ROUNDING);
    }
}

EJECTOR_AXLE_RADIUS = 2;
EJECTOR_AXLE_CLEARANCE = 0.15;

// We don't include `y` clearance, since that ensures a snug state when the card is in, and the lever is not
// touching near the spring while printed.
function ejector_axle_center(card_size) = _x_y_(card_size, [ 0.375, 1, 0 ]) +
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

function spring_depth(card_size) = (_y(card_size) + STICK_OUT_MARGIN_Z) / 2;

module spring_shell(card_size, compression)
{
    scale([ SPRING_WIDTH + compression, spring_depth(card_size) / 2 ]) circle(1);
}

module spring_pair(card_size, compression)
{
    positive() color("orange") duplicate_and_mirror() translate(
        [ _x(card_size, 1 / 2) + SPRING_WIDTH, spring_depth(card_size) / 2, _z(card_size, -1 / 2) + SPRING_CLEARANCE ])
        linear_extrude(_z(card_size) - 2 * SPRING_CLEARANCE) difference()
    {
        spring_shell(card_size, compression);
        offset(-SPRING_THICKNESS) spring_shell(card_size, compression);
        translate([ LARGE_VALUE / 2, 0, 0 ]) square(LARGE_VALUE, center = true);
    }
}

module springs_comp(card_size)
{
    duplicate_and_translate([ 0, spring_depth(card_size), 0 ]) spring_pair(card_size, -0.1);
    spring_pair(card_size, 0.05);
}

CARD_TAB_WIDTH = 11; // rounded up
CARD_TAB_HEIGHT = 1; // approximate
CARD_TAB_DEPTH = 1;  // approximate

module card_tab_negative_comp(card_size)
{

    // TODO: implement angled sides?
    negative() translate([ 0, 0, -_z(card_size, 1 / 2) ])
        aligned_cube([ CARD_TAB_WIDTH, CARD_TAB_HEIGHT, CARD_TAB_DEPTH ], ".+-");
}

module card_slot_comp(card_size)
{
    negative() translate([ 0, STICK_OUT_MARGIN_Z, 0 ])
        aligned_cube(card_size + [ 2 * SPRING_WIDTH, EXTRA_INTERNAL_DEPTH_FOR_EJECTOR, 2 * CLEARANCE ], ".+.");

    card_tab_negative_comp(card_size);

    positive() % translate([ 0, STICK_OUT_MARGIN_Z, 0 ]) aligned_cube(card_size, ".+.");
}

EJECTOR_LEVER_WIDTH = EJECTOR_AXLE_RADIUS * 1;
EJECTOR_LEVER_PRINTING_ANGLE = PLUNGER_PUSHED_IN ? 30 : 0;

EJECTOR_AXLE_HOLE_SNAP_CONNECTOR_HEIGHT = CASE_MARGIN_Z * 1 / 2;

AXLE_INSET = 0.7;
AXLE_INSET_CLEARANCE = 0.6;

module ejector_axle_hole_snappable_print_supports(card_size)
{
    duplicate_and_mirror([ 0, 0, 1 ]) translate([ 0, 0, _z(card_size) / 2 + CASE_MARGIN_Z / 2 - AXLE_INSET / 2 ])
        aligned_cube(
            [
                EJECTOR_AXLE_RADIUS * 1 / 4,
                (EJECTOR_AXLE_RADIUS * 2 + CLEARANCE + EJECTOR_AXLE_CLEARANCE * 2 + 2 * _EPSILON) / 2,
                EJECTOR_AXLE_HOLE_SNAP_CONNECTOR_HEIGHT
                // _z(card_size) + 2 * CASE_MARGIN_Z + 2 * _EPSILON + 2 *
                // _EPSILON
            ],
            centering_spec = ".+.");
}

LEVER_PRINT_SUPPORT_WIDTH = 0.5;
LEVER_PRINT_SUPPORT_HEIGHT = 2;

LEVER_SCALE = 1.25;
LEVER_OFFSET = 2;

EJECTOR_LEVER_ANGLING_SPACE_EXTRA_WIDTH = 2.9;
EJECTOR_BOTTOM_SUPPORT_OFFSET_X = 5.4;

module untranslated_axle_hole(card_size)
{

    union()
    {

        cylinder(h = _z(card_size) + 2 * CASE_MARGIN_Z + 2 * _EPSILON - 2 * AXLE_INSET_CLEARANCE,
                 r = EJECTOR_AXLE_RADIUS + EJECTOR_AXLE_CLEARANCE, center = true);

        {
            aligned_cube(
                [
                    EJECTOR_AXLE_RADIUS * 2 * 2 / 3, EJECTOR_AXLE_RADIUS + CLEARANCE + EJECTOR_AXLE_CLEARANCE,
                    _z(card_size) + 2 * CASE_MARGIN_Z + 2 * _EPSILON - 2 *
                    AXLE_INSET_CLEARANCE
                ],
                centering_spec = ".+.");
        }
    }
}

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

    // Ejector lever angling space
    negative() translate([
        _x(card_size, 1 / 2) - EJECTOR_LEVER_ANGLING_SPACE_EXTRA_WIDTH,
        _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR - _EPSILON, 0
    ])
        aligned_cube(
            [
                EJECTOR_CHUTE_WIDTH_X + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE +
                    EJECTOR_LEVER_ANGLING_SPACE_EXTRA_WIDTH,
                LEVER_BACK_EXTRA_DEPTH + _EPSILON, _z(card_size) + 2 *
                CLEARANCE
            ],
            "++.");

    // Small printing connectors
    positive() translate([
        _x(card_size, 1 / 2) - LEVER_PRINT_SUPPORT_WIDTH - EJECTOR_LEVER_ANGLING_SPACE_EXTRA_WIDTH,
        _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR - _EPSILON - 0.5 + 0.2, 0
    ]) aligned_cube([ LEVER_PRINT_SUPPORT_WIDTH, LEVER_PRINT_SUPPORT_WIDTH, LEVER_PRINT_SUPPORT_HEIGHT ], "++.");
    positive() translate([
        _x(card_size, 1 / 2) - LEVER_PRINT_SUPPORT_WIDTH - EJECTOR_LEVER_ANGLING_SPACE_EXTRA_WIDTH + 4.6,
        _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR - _EPSILON - 0.4, 0
    ]) aligned_cube([ LEVER_PRINT_SUPPORT_WIDTH, LEVER_PRINT_SUPPORT_WIDTH, LEVER_PRINT_SUPPORT_HEIGHT ], "++.");

    positive() translate([
        _x(card_size, 1 / 2) - CLEARANCE + EJECTOR_BOTTOM_SUPPORT_OFFSET_X,
        _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR - _EPSILON - 0.5, 0
    ]) aligned_cube([ LEVER_PRINT_SUPPORT_WIDTH, LEVER_PRINT_SUPPORT_WIDTH, LEVER_PRINT_SUPPORT_HEIGHT ], "++.");

    translate(ejector_axle_center(card_size))
    {
        // Ejector axle hole
        negative() difference()
        {
            untranslated_axle_hole(card_size);

            ejector_axle_hole_snappable_print_supports(card_size);
        }

        // Axle
        positive()
            cylinder(h = _z(card_size) + 2 * CASE_MARGIN_Z - 2 * AXLE_INSET, r = EJECTOR_AXLE_RADIUS, center = true);

        // Lever
        positive() color("blue") rotate([ 0, 0, EJECTOR_LEVER_PRINTING_ANGLE ])
        {
            lever_offset_y = -EJECTOR_AXLE_RADIUS + EJECTOR_LEVER_WIDTH / 2;
            translate([ SPRING_WIDTH + TOTAL_EXTRA_WIDTH_FOR_EJECTOR - CLEARANCE + LEVER_OFFSET, 0, 0 ]) difference()
            {
                translate([ 0, lever_offset_y, 0 ])
                    aligned_cube(_x_(card_size, LEVER_SCALE) + _z_(card_size) + [ 0, EJECTOR_LEVER_WIDTH, 0 ], "-..");

                translate(-_x_(card_size, LEVER_SCALE / 2) + [ 0, lever_offset_y, 0 ]) duplicate_and_mirror([ 0, 1, 0 ])
                    duplicate_and_mirror()
                        translate(_x_(card_size, -LEVER_SCALE / 2) + [ 0, -EJECTOR_LEVER_WIDTH / 2, 0 ])
                            round_bevel_complement(height = _z(card_size) + 2 * _EPSILON,
                                                   radius = EJECTOR_LEVER_WIDTH / 2, center_z = true);
            }
            union()
            {
                // TODO: neaten this up.
                translate([ -8, 0, 0 ]) aligned_cube([ 22, 4, _z(card_size) ], ".+.");
                translate([ -4.1, -1.85, 0 ]) aligned_cube([ 22, 3.5, _z(card_size) ], ".+.");
                translate([ -23, -2, 0 ]) rotate([ 0, 0, 20 ]) aligned_cube([ 6, 2, _z(card_size) ], "++.");
                translate([ -24.8, -2, 0 ]) rotate([ 0, 0, 32 ]) aligned_cube([ 8.1, 2, _z(card_size) ], "++.");
                translate([ 9.7, -2, 0 ]) rotate([ 0, 0, 160 ]) aligned_cube([ 8.1, 2, _z(card_size) ], "+-.");
                translate([ 8.7, -2, 0 ]) rotate([ 0, 0, 160 ]) aligned_cube([ 8.1, 2, _z(card_size) ], "+-.");
            }
        }
    }
}

// Depends on other constants, but is much easier to hardcode than computer.
EJECTOR_PLUNGER_EXTRA_DEPTH = 5.55;
PLUNGER_LEVER_CONTACT_ANTI_CLEARANCE = 0;

EJECTOR_PLUNGER_WALL_CLEARANCE = 0.15;

EJECTOR_PLUNGER_RETAINER_INSET_DEPTH = 10;
EJECTOR_PLUNGER_RETAINER_DEPTH = 5;
EJECTOR_PLUNGER_RETAINERS_HEIGHT_FOR_EACH = 0.75;

EJECTOR_PLUNGER_FRONT_CLEARANCE_FROM_RETAINER = 0.5;
EJECTOR_PLUNGER_FRONT_TRANSITION_DEPTH_TO_STEM = 2;

FRONT_WALL_WIDTH_FOR_EJECTOR_CHUTE = 1;

EJECTOR_PLUNGER_FRONT_ROUNDING_RADIUS = 1;
EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT = 1;

// https://gist.github.com/boredzo/fde487c724a40a26fa9c
module skew(xy = 0, xz = 0, yx = 0, yz = 0, zx = 0, zy = 0)
{
    matrix = [ [ 1, tan(xy), tan(xz), 0 ], [ tan(yx), 1, tan(yz), 0 ], [ tan(zx), tan(zy), 1, 0 ], [ 0, 0, 0, 1 ] ];
    multmatrix(matrix) children();
}

module ejector_plunger_front(card_size)
{
    color("blue") translate([
        _x(card_size, 1 / 2) + SPRING_WIDTH + FRONT_WALL_WIDTH_FOR_EJECTOR_CHUTE +
            EJECTOR_PLUNGER_FRONT_ROUNDING_RADIUS + EJECTOR_PLUNGER_WALL_CLEARANCE + CLEARANCE,
        EJECTOR_PLUNGER_FRONT_TRANSITION_DEPTH_TO_STEM, 0
    ]) minkowski()
    {
        difference()
        {
            // TODO: refactor these calculations.
            aligned_cube(
                [
                    WALL_WIDTH_FOR_EJECTOR_CHUTE - FRONT_WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_CHUTE_WIDTH_X -
                        EJECTOR_PLUNGER_FRONT_ROUNDING_RADIUS * 1.5 - CLEARANCE,
                    EJECTOR_PLUNGER_RETAINER_INSET_DEPTH - EJECTOR_PLUNGER_FRONT_CLEARANCE_FROM_RETAINER - _EPSILON -
                        EJECTOR_PLUNGER_FRONT_TRANSITION_DEPTH_TO_STEM,
                    _z(card_size) - EJECTOR_PLUNGER_FRONT_ROUNDING_RADIUS * 2 + EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT - 2 *
                    EJECTOR_PLUNGER_WALL_CLEARANCE
                ],
                "++.");

            translate([ 0, 6, 0 ]) rotate([ 0, 0, 60 ]) aligned_cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], ".+.");
        }
        rotate([ 90, 0, 0 ]) skew(xz = -20) cylinder(h = EJECTOR_PLUNGER_FRONT_TRANSITION_DEPTH_TO_STEM, r1 = 0,
                                                     r2 = EJECTOR_PLUNGER_FRONT_ROUNDING_RADIUS);
    }
}

module ejector_plunger_comp(card_size)
{
    plunger_depth_y = _y(card_size) + STICK_OUT_MARGIN_Z + EJECTOR_PLUNGER_EXTRA_DEPTH;

    // Ejector chute (back)
    color("red") negative() translate([
        _x(card_size, 1 / 2) + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE,
        EJECTOR_PLUNGER_RETAINER_DEPTH + EJECTOR_PLUNGER_RETAINER_INSET_DEPTH, 0
    ])
        aligned_cube(
            [
                EJECTOR_CHUTE_WIDTH_X,
                _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR + STICK_OUT_MARGIN_Z - EJECTOR_PLUNGER_RETAINER_DEPTH -
                    EJECTOR_PLUNGER_RETAINER_INSET_DEPTH,
                _z(card_size) + 2 *
                CLEARANCE
            ],
            "++.");

    color("red") negative()
        translate([ _x(card_size, 1 / 2) + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE, -_EPSILON, 0 ]) aligned_cube(
            [ EJECTOR_CHUTE_WIDTH_X, EJECTOR_PLUNGER_RETAINER_INSET_DEPTH + _EPSILON, _z(card_size) + 2 * CLEARANCE ],
            "++.");

    // Ejector chute (inner)
    color("yellow") negative()
        translate([ _x(card_size, 1 / 2) + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE, -_EPSILON, 0 ]) aligned_cube(
            [
                EJECTOR_CHUTE_WIDTH_X, _y(card_size) + EXTRA_INTERNAL_DEPTH_FOR_EJECTOR + STICK_OUT_MARGIN_Z + _EPSILON,
                _z(card_size) + 2 * CLEARANCE - 2 *
                EJECTOR_PLUNGER_RETAINERS_HEIGHT_FOR_EACH
            ],
            "++.");

    positive() ejector_plunger_front(card_size);
    negative() minkowski()
    {
        ejector_plunger_front(card_size);
        cube(
            [
                2 * EJECTOR_PLUNGER_WALL_CLEARANCE, 2 * EJECTOR_PLUNGER_FRONT_CLEARANCE_FROM_RETAINER, 2 *
                EJECTOR_PLUNGER_WALL_CLEARANCE
            ],
            center = true);
    }

    positive() color("green") translate([
        _x(card_size, 1 / 2) + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WALL_CLEARANCE,
        PLUNGER_PUSHED_IN ? 0 : -EJECTOR_PLUNGER_EXTRA_DEPTH + PLUNGER_LEVER_CONTACT_ANTI_CLEARANCE, 0
    ]) difference()
    {
        union()
        {
            translate([
                0, EJECTOR_PLUNGER_RETAINER_DEPTH + EJECTOR_PLUNGER_EXTRA_DEPTH + EJECTOR_PLUNGER_RETAINER_INSET_DEPTH,
                0
            ])
                aligned_cube(
                    [
                        EJECTOR_CHUTE_WIDTH_X - 2 * EJECTOR_PLUNGER_WALL_CLEARANCE,
                        plunger_depth_y - EJECTOR_PLUNGER_RETAINER_DEPTH - EJECTOR_PLUNGER_EXTRA_DEPTH -
                            EJECTOR_PLUNGER_RETAINER_INSET_DEPTH,
                        _z(card_size)
                    ],
                    "++.");
            aligned_cube(
                [
                    EJECTOR_CHUTE_WIDTH_X - 2 * EJECTOR_PLUNGER_WALL_CLEARANCE, plunger_depth_y, _z(card_size) -
                    EJECTOR_RETAINERS_TOTAL_HEIGHT
                ],
                "++."); // Top and bottom accoutn for half each.
        }
        translate([ 0, plunger_depth_y, 0 ]) mirror([ 0, 1, 0 ]) round_bevel_complement(
            height = _z(card_size) + 2 * _EPSILON, radius = EJECTOR_CHUTE_WIDTH_X / 2, center_z = true);
    }
}

module ejector_comp(card_size)
{
    ejector_lever_comp(card_size);
    ejector_plunger_comp(card_size);
}

ARRAY_CENTERING_OFFSET_X = -(WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_CHUTE_WIDTH_X) / 2;

module conditional_mirror(condition, v)
{
    if (condition)
    {
        mirror(v) children();
    }
    else
    {
        children();
    }
}

module block(card_size, mirror_x, is_top, is_bottom, engrave)
{
    compose()
    {
        conditional_mirror(mirror_x, [ 1, 0, 0 ])
        {
            translate([ ARRAY_CENTERING_OFFSET_X, 0, 0 ])
            {
                carvable() casing(card_size);

                card_slot_comp(card_size);
                ejector_comp(card_size);
                springs_comp(card_size);

                if (DEBUG_SHOW_CROSS_SECTION)
                {
                    negative() translate([ 0, 0, LARGE_VALUE / 2 ]) cube(LARGE_VALUE, center = true);
                    // translate(ejector_axle_center(card_size)) negative() translate([ LARGE_VALUE / 2, 0, 0 ])
                    //     cube(LARGE_VALUE, center = true);
                }
            }

            negative() mirror([ 1, 0, 0 ]) translate([ ARRAY_CENTERING_OFFSET_X, 0, 0 ])
                translate([ 0, 0, -slot_bottom_distance_z(card_size) ])
            {
                if (!is_bottom)
                {
                    translate([ 0, 0, 2 ]) translate(ejector_axle_center(card_size)) untranslated_axle_hole(card_size);
                }
                if (!is_top)
                {
                    translate([ 0, 0, -2 ]) translate(ejector_axle_center(card_size)) untranslated_axle_hole(card_size);
                }
                if (!is_bottom)
                {
                    ejector_plunger_comp(card_size, $compose_mode = "negative");
                }
            }
        }

        if (!is_top)
        {
            conditional_mirror(mirror_x, [ 1, 0, 0 ]) translate([ -ARRAY_CENTERING_OFFSET_X, 0, 0 ])
                translate([ 0, 0, slot_bottom_distance_z(card_size) ]) card_tab_negative_comp(card_size);
        }

        if (engrave)
        {
            engraving_comp(card_size);
        }
    }
}

EXTRA_SLOT_DISTANCE = 0;

module block_array(n, card_size, include_engraving = true, use_tiling_offset = false)
{
    render() union()
    {
        for (i = [0:NUM_SLOTS - 1])
        {
            is_top = i == NUM_SLOTS - 1;
            is_bottom = i == 0;
            translate([
                (use_tiling_offset && (i % 2 == 1)) ? slot_width_distance_x(card_size) / 4 : 0, 0,
                i * (slot_bottom_distance_z(card_size) + EXTRA_SLOT_DISTANCE)
            ]) block(card_size, i % 2 == 1, is_top, is_bottom, include_engraving && is_top);
        }
    }
}

// TODO: Fix tab negative placement.
module double_block_array(n, card_size)
{
    translate([ slot_width_distance_x(card_size), 0, 0 ]) block_array(n, card_size, false, true);
    block_array(n, card_size, true, true);
}

rotate([ ROTATE_FOR_PRINTING ? -90 : 0, 0, 0 ]) render() block_array(NUM_SLOTS, CFEXPRESS_B_CARD_SIZE);
