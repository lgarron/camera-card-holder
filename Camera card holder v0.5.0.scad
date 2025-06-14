VERSION_TEXT = "v0.5.0";

DEBUG = false;
NUM_SLOTS = 4;
DEBUG_SHOW_CROSS_SECTION = DEBUG;
ROTATE_FOR_PRINTING = !DEBUG;

PLUNGER_PUSHED_IN = true;

STICK_OUT_MARGIN_Z = 0;

$fn = 180;

/*

## v0.4.25

- Stack cards vertically.
- Increase ejector plunger front size.

## v0.4.24

- Adjust the lever angle to 40°.

## v0.4.23

- Add a torque smoothing curve to the lever for easier smooth ejection (without shooting out the card).

## v0.4.22

- Adjust SD card size.
- Remove the card tab negative from SD cards.
- Add extra height in the middle (on both sides) for sticker labels.

## v0.4.21

- Adjust plunger dimensions to accommodate the SD card size.
- Include 4 output objects: 1 CFexpress, 1 SD card, 4 CFexpress, 4 SD card

## v0.4.20

- Use parametric calculations for the plunger.
- Avoid cutting the plunger when extended.
- Increase the vertical height of the plunger front.

## v0.4.19

- Adjust the lever calculations so they also work for SD card sizes.

## v0.4.18

- `compose()` all blocks instead of duplicating code for carveouts.

## v0.4.17

- Round the entire array instead of individual slot blocks.
- Increase the number of slots to 4.

## v0.4.16

- Reduce back spring compression even more.

## v0.4.15

- Fix the axle hole and plunger chute carving forrealz.
- Decrease the plunger wall clearance for the head.
- Decrease the back spring compression to an even further negative value.
- Increase the number of slots to 3 for testing.

## v0.4.14

- Increase `EJECTOR_PLUNGER_WALL_CLEARANCE` to 0.2.
- Set the number of slots to 2 for testing.

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

include <./node_modules/scad/compose.scad>
include <./node_modules/scad/duplicate.scad>
include <./node_modules/scad/epsilon.scad>
include <./node_modules/scad/minkowski_shell.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/vendor/BOSL2/std.scad>
include <./node_modules/scad/xyz.scad>

CFEXPRESS_B_CARD_SIZE = [29.60, 38.55, 3.85];
CFEXPRESS_CARD_TAB_NEGATIVE_SIZE = [11, 1, 1];

// CFEXPRESS_B_UPPER_INDENT_SIZE = [ 1.00, 33.65, 0.55 ];

SD_CARD_SIZE = [24, 32.0, 2.1];
// SD_CARD_LOWER_INDENT_SIZE = [ 1.00, 33.65, 0.70 ];

CLEARANCE = 0.15;

DEFAULT_MARGIN = 3;
CASE_BACK_THICKNESS = 1;
CASE_MARGIN_Z = 1.5;

FUNNEL_DEPTH = 2.5;
FUNNEL_DEFAULT_MARGIN_Z = 1;
SPRING_WIDTH = 2;

TEXT_ENGRAVING_DEPTH = 0.25;

BEVEL_ROUNDING = 1;

EXTRA_BACK_DEPTH_FOR_LEVER = 7.5;
EJECTOR_PLUNGER_WIDTH_X = 4;
WALL_WIDTH_FOR_EJECTOR_CHUTE = 2;
EJECTOR_RETAINERS_TOTAL_HEIGHT = 2; // Top and bottom accoutn for half each.

TOTAL_EXTRA_WIDTH_FOR_EJECTOR = WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X;

function slot_bottom_distance_z(card_size) = card_size.z + CASE_MARGIN_Z + CLEARANCE;
function slot_width_distance_x(card_size) =
  card_size.x + 2 * SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X + CASE_MARGIN_Z;

module casing(card_size, include_bevel_rounding, extra_height = 0, full_design_has_multiple_slots = false) {
  translate([full_design_has_multiple_slots ? 0 : TOTAL_EXTRA_WIDTH_FOR_EJECTOR / 2, 0, extra_height / 2])
    minkowski() {
      bevel_rounding_value = (include_bevel_rounding ? 2 * BEVEL_ROUNDING : 0);
      cuboid(
        card_size + [
          DEFAULT_MARGIN * 2 - bevel_rounding_value + TOTAL_EXTRA_WIDTH_FOR_EJECTOR * (full_design_has_multiple_slots ? 2 : 1),
          CASE_BACK_THICKNESS + STICK_OUT_MARGIN_Z - bevel_rounding_value + EXTRA_BACK_DEPTH_FOR_LEVER,
          2 * CASE_MARGIN_Z - bevel_rounding_value + extra_height,
        ],
        anchor=FRONT
      );
      if (include_bevel_rounding) {
        translate([0, BEVEL_ROUNDING, 0]) sphere(BEVEL_ROUNDING);
      }
    }
}

EJECTOR_AXLE_RADIUS = 2;
EJECTOR_AXLE_CLEARANCE = 0.15;

// We don't include `y` clearance, since that ensures a snug state when the card is in, and the lever is not
// touching near the spring while printed.
function ejector_axle_center(card_size) =
  _xy_(card_size, [0.45, 1, 0]) + [0, STICK_OUT_MARGIN_Z + EJECTOR_AXLE_RADIUS, 0];

module funnel_comp(card_size) {
  negative() minkowski() {
      cuboid(_xz_(card_size) + [0, _EPSILON, 0 + CLEARANCE * 2], anchor=CENTER);
      rotate([-90, 0, 0]) scale([SPRING_WIDTH, 1, FUNNEL_DEFAULT_MARGIN_Z - CLEARANCE / 2])
          cylinder(FUNNEL_DEPTH - _EPSILON, r1=1, r2=0);
    }
}

module air_hole_comp(card_size) {
  negative() translate(
      [
        card_size.x * -1 / 4,
        card_size.y + STICK_OUT_MARGIN_Z - _EPSILON + EXTRA_BACK_DEPTH_FOR_LEVER,
        -card_size.z / 2 - CLEARANCE,
      ]
    ) cube([card_size.x * 1 / 2, DEFAULT_MARGIN + 2 * _EPSILON, card_size.z * 1 / 3]);
}

module engraving_comp(card_size, card_type_label) {
  negative() render() union() {
        // Version engraving
        translate(
          [
            0,
            (DEFAULT_MARGIN + card_size.y + STICK_OUT_MARGIN_Z) / 2,
            card_size.z * 1 / 2 + CASE_MARGIN_Z - TEXT_ENGRAVING_DEPTH,
          ]
        ) linear_extrude(TEXT_ENGRAVING_DEPTH + _EPSILON)
            text(VERSION_TEXT, size=5, font="Ubuntu:style=bold", halign="center", valign="center");

        // Version engraving
        translate(
          [
            0,
            (DEFAULT_MARGIN + card_size.y + STICK_OUT_MARGIN_Z) / 2 - 7,
            card_size.z * 1 / 2 + CASE_MARGIN_Z - TEXT_ENGRAVING_DEPTH,
          ]
        ) linear_extrude(TEXT_ENGRAVING_DEPTH + _EPSILON)
            text(card_type_label, size=3, font="Ubuntu:style=bold", halign="center", valign="center");
      }
}

LARGE_VALUE = 1000;

SPRING_CLEARANCE = 0.2;
SPRING_THICKNESS = 0.75;

SPRING_INSET = 0.1;

function spring_depth(card_size) = (card_size.y + STICK_OUT_MARGIN_Z) / 2;

module spring_shell(card_size, compression) {
  scale([SPRING_WIDTH + compression, spring_depth(card_size) / 2]) circle(1);
}

module spring_pair(card_size, compression) {
  positive() color("orange") duplicate_and_mirror() translate(
          [card_size.x * 1 / 2 + SPRING_WIDTH, spring_depth(card_size) / 2, card_size.z * -1 / 2 + SPRING_CLEARANCE]
        )
          linear_extrude(card_size.z - 2 * SPRING_CLEARANCE) difference() {
              spring_shell(card_size, compression);
              offset(-SPRING_THICKNESS) spring_shell(card_size, compression);
              translate([LARGE_VALUE / 2, 0, 0]) square(LARGE_VALUE, center=true);
            }
}

BACK_SPRINGS_COMPRESSION = -0.4;
FRONT_SPRINGS_COMPRESSION = 0.05;

module springs_comp(card_size) {
  duplicate_and_translate([0, spring_depth(card_size), 0]) spring_pair(card_size, BACK_SPRINGS_COMPRESSION);
  spring_pair(card_size, FRONT_SPRINGS_COMPRESSION);
}

// TODO don't hardcode this for CFExpress
module card_tab_negative_comp(card_size, card_tab_negative_size) {
  // TODO: implement angled sides?
  negative() translate([0, 0, -card_size.z * 1 / 2]) cuboid(card_tab_negative_size, anchor=FRONT + TOP);
}

EXTRA_HEIGHT_EACH_SIDE_FOR_LABEL = 0.1;

module card_slot_comp(card_size, card_tab_negative_size) {
  negative() translate([0, STICK_OUT_MARGIN_Z, 0])
      cuboid(card_size + [2 * SPRING_WIDTH, EXTRA_BACK_DEPTH_FOR_LEVER, 2 * CLEARANCE], anchor=FRONT);

  // Add extra height in the middle (on both sides) for sticker labels.
  negative() translate([0, STICK_OUT_MARGIN_Z, 0]) cuboid(
        __xyz__scale_entries_independently(card_size, [2 / 3, 1, 1]) + [2 * SPRING_WIDTH, EXTRA_BACK_DEPTH_FOR_LEVER, 2 * CLEARANCE + 2 * EXTRA_HEIGHT_EACH_SIDE_FOR_LABEL],
        anchor=FRONT
      );

  if (is_list(card_tab_negative_size)) {
    card_tab_negative_comp(card_size, card_tab_negative_size);
  }

  positive() %translate([0, STICK_OUT_MARGIN_Z, 0]) cuboid(card_size, anchor=FRONT);
}

EJECTOR_LEVER_WIDTH = EJECTOR_AXLE_RADIUS * 4;
EJECTOR_LEVER_OFFSET_ANGLED_Y = EJECTOR_AXLE_RADIUS;
EJECTOR_LEVER_ROUNDING = EJECTOR_AXLE_RADIUS / 2;
EJECTOR_LEVER_PRINTING_ANGLE = PLUNGER_PUSHED_IN ? 40 : 0;

EJECTOR_AXLE_HOLE_SNAP_CONNECTOR_HEIGHT = CASE_MARGIN_Z * 1 / 2;

AXLE_INSET = 0.7;
AXLE_INSET_CLEARANCE = 0.6;

module ejector_axle_hole_snappable_print_supports(card_size) {
  duplicate_and_mirror([0, 0, 1]) translate([0, 0, card_size.z / 2 + CASE_MARGIN_Z / 2 - AXLE_INSET / 2])
      cuboid(
        [
          EJECTOR_AXLE_RADIUS * 1 / 4,
          (EJECTOR_AXLE_RADIUS * 2 + CLEARANCE + EJECTOR_AXLE_CLEARANCE * 2 + 2 * _EPSILON) / 2,
          EJECTOR_AXLE_HOLE_SNAP_CONNECTOR_HEIGHT,
          // card_size.z + 2 * CASE_MARGIN_Z + 2 * _EPSILON + 2 *
          // _EPSILON
        ],
        anchor=FRONT
      );
}

LEVER_PRINT_SUPPORT_WIDTH = 0.5;
LEVER_PRINT_SUPPORT_HEIGHT = 2;

LEVER_SCALE = 1.5;
LEVER_OFFSET = 1;

module untranslated_axle_hole(card_size) {

  union() {

    cylinder(
      h=card_size.z + 2 * CASE_MARGIN_Z + 2 * _EPSILON - 2 * AXLE_INSET_CLEARANCE,
      r=EJECTOR_AXLE_RADIUS + EJECTOR_AXLE_CLEARANCE, center=true
    );

    {
      cuboid(
        [
          EJECTOR_AXLE_RADIUS * 2 * 2 / 3,
          EJECTOR_AXLE_RADIUS + CLEARANCE + EJECTOR_AXLE_CLEARANCE,
          card_size.z + 2 * CASE_MARGIN_Z + 2 * _EPSILON - 2 * AXLE_INSET_CLEARANCE,
        ],
        anchor=FRONT
      );
    }
  }
}

module lever_intersection_base(lever_values_struct, rotate_deep_side) {
  minkowski() {

    cuboid(
      struct_val(lever_values_struct, "lever_core_size") + [0, struct_val(lever_values_struct, "large_value_for_y"), 0],
      anchor=FRONT
    );
    cylinder(_EPSILON, r=EJECTOR_LEVER_ROUNDING, center=true);
  }
}

LEVER_TORQUE_SMOOTHING_CURVE_SCALE = 2;

module ejector_lever_comp(card_size) {
  // Ejector back area
  negative() translate([card_size.x * 1 / 2, card_size.y + STICK_OUT_MARGIN_Z, 0]) cuboid(
        [
          SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X,
          EXTRA_BACK_DEPTH_FOR_LEVER,
          card_size.z + 2 * CLEARANCE,
        ],
        anchor=LEFT + FRONT
      );

  translate(ejector_axle_center(card_size)) {
    // Ejector axle hole
    negative() difference() {
        untranslated_axle_hole(card_size);

        ejector_axle_hole_snappable_print_supports(card_size);
      }

    // Axle
    positive()
      cylinder(h=card_size.z + 2 * CASE_MARGIN_Z - 2 * AXLE_INSET, r=EJECTOR_AXLE_RADIUS, center=true);

    // Lever
    lever_values_struct = struct_set(
      [], [
        //
        "lever_offset",
        [
          -card_size.x * LEVER_SCALE / 2 + SPRING_WIDTH + TOTAL_EXTRA_WIDTH_FOR_EJECTOR - CLEARANCE + LEVER_OFFSET,
          EJECTOR_LEVER_OFFSET_ANGLED_Y,
          0,
        ],
        //
        "large_value_for_y",
        card_size.x * LEVER_SCALE,
        //
        "lever_core_size",
        _x_(card_size, LEVER_SCALE) + _z_(card_size) + [0, EJECTOR_LEVER_WIDTH, 0] - [2 * EJECTOR_LEVER_ROUNDING, 2 * EJECTOR_LEVER_ROUNDING, -_EPSILON],
      ]
    );
    local_offset_1 = _x_(struct_val(lever_values_struct, "lever_core_size"), -1 / 2);
    local_offset_2 = _y_(struct_val(lever_values_struct, "lever_core_size"), -1 / 2) + struct_val(lever_values_struct, "lever_offset");
    color("purple") positive() rotate([0, 0, EJECTOR_LEVER_PRINTING_ANGLE]) difference() {
            union() {
              lever_offset_y = -EJECTOR_AXLE_RADIUS + EJECTOR_AXLE_RADIUS / 2;
              translate([SPRING_WIDTH + TOTAL_EXTRA_WIDTH_FOR_EJECTOR - CLEARANCE + LEVER_OFFSET, 0, 0])
                difference() {
                  translate([0, lever_offset_y, 0]) cuboid(
                      _x_(card_size, LEVER_SCALE) + _z_(card_size) + [0, EJECTOR_AXLE_RADIUS, 0], anchor=RIGHT
                    );

                  translate(-_x_(card_size, LEVER_SCALE / 2) + [0, lever_offset_y, 0])
                    duplicate_and_mirror([0, 1, 0]) duplicate_and_mirror()
                        translate(_x_(card_size, -LEVER_SCALE / 2) + [0, -EJECTOR_AXLE_RADIUS / 2, 0])
                          round_bevel_complement(
                            height=card_size.z + 2 * _EPSILON,
                            radius=EJECTOR_AXLE_RADIUS / 2, center_z=true
                          );
                }

              {
                translate(local_offset_2) intersection() {
                    lever_intersection_base(lever_values_struct);

                    translate(-local_offset_1) rotate([0, 0, 90 - EJECTOR_LEVER_PRINTING_ANGLE + 10])
                        translate(local_offset_1) lever_intersection_base(lever_values_struct);
                    translate(local_offset_1) rotate([0, 0, -60]) translate(-local_offset_1)
                          lever_intersection_base(lever_values_struct);

                    translate([0, EJECTOR_AXLE_RADIUS * 2.5, 0])
                      cuboid([LARGE_VALUE, LARGE_VALUE, LARGE_VALUE], anchor=BACK);
                    // translate(lever_offset) cuboid(lever_core_size + [ 0, card_size.x* LEVER_SCALE), 0 ],
                    // anchor = FRONT);``
                  }
              }
            }

            // Torque smoothing curve
            translate([-(card_size * LEVER_TORQUE_SMOOTHING_CURVE_SCALE).x, -EJECTOR_AXLE_RADIUS, 0])
              round_bevel_complement(height=card_size.z, radius=card_size.x * 2, center_z=true);
          }

    axle_center_to_back_y = (card_size.y + EXTRA_BACK_DEPTH_FOR_LEVER) - ejector_axle_center(card_size).y;
    color("purple") difference() {
        union() {
          cuboid(
            [LEVER_PRINT_SUPPORT_WIDTH, axle_center_to_back_y + _EPSILON, LEVER_PRINT_SUPPORT_HEIGHT],
            anchor=FRONT
          );

          translate([0, -1, 0]) rotate([0, 0, EJECTOR_LEVER_PRINTING_ANGLE]) duplicate_and_translate(
                [5.25, 0, 0]
              ) translate([5.25, 0, 0]) rotate([0, 0, -EJECTOR_LEVER_PRINTING_ANGLE])
                    cuboid(
                      [LEVER_PRINT_SUPPORT_WIDTH, axle_center_to_back_y + _EPSILON, LEVER_PRINT_SUPPORT_HEIGHT],
                      anchor=FRONT
                    );
        }
        translate([0, axle_center_to_back_y + _EPSILON, 0])
          cuboid([LARGE_VALUE, LARGE_VALUE, LARGE_VALUE], anchor=FRONT);
      }
  }
}

EJECTOR_PLUNGER_ANNULAR_CLEARANCE = 0.2;

EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT = 1; // TODO

// https://gist.github.com/boredzo/fde487c724a40a26fa9c
module skew(xy = 0, xz = 0, yx = 0, yz = 0, zx = 0, zy = 0) {
  matrix = [[1, tan(xy), tan(xz), 0], [tan(yx), 1, tan(yz), 0], [tan(zx), tan(zy), 1, 0], [0, 0, 0, 1]];
  multmatrix(matrix) children();
}

EJECTOR_RETAINER_EXTRA_WIDTH = WALL_WIDTH_FOR_EJECTOR_CHUTE - 1;
PLUNGER_RETAINER_BACK_SLOPE_ANGLE = 60;

function sec(theta) = 1 / cos(theta);

function plunger_back_rounding_center(card_size) =
  [
    1 / 2 * (card_size.x + EJECTOR_PLUNGER_WIDTH_X + 2 * (SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE)),
    card_size.y + EJECTOR_AXLE_RADIUS - 1 / 2 * (2 * EJECTOR_AXLE_RADIUS + EJECTOR_PLUNGER_WIDTH_X) * sec(EJECTOR_LEVER_PRINTING_ANGLE) + (card_size.x / 20 + EJECTOR_PLUNGER_WIDTH_X / 2 + SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE) * tan(EJECTOR_LEVER_PRINTING_ANGLE),
  ];

PLUNGER_ROUNDING_FN = 32; // If this value is higher, render times go *waaaay* up.

module plunger_retainer(card_size, extra_height, subtract_width = 0) {
  depth = SD_CARD_SIZE.y * 1 / 5;

  plunger_hook_size = _z_(card_size) + [EJECTOR_PLUNGER_WIDTH_X - subtract_width, depth, 0];
  render() translate(_x_(card_size) / 2 + [SPRING_WIDTH + TOTAL_EXTRA_WIDTH_FOR_EJECTOR, 0, 0]) render() minkowski() {
          render() cuboid(plunger_hook_size, anchor=RIGHT + FRONT);

          render() translate([-EJECTOR_RETAINER_EXTRA_WIDTH / 2, 0, 0])
              skew(xy=90 - PLUNGER_RETAINER_BACK_SLOPE_ANGLE) render()
                  scale([EJECTOR_RETAINER_EXTRA_WIDTH / 2, 1, extra_height / 2]) rotate([-90, 0, 0])
                      cylinder(
                        h=tan(PLUNGER_RETAINER_BACK_SLOPE_ANGLE) * EJECTOR_RETAINER_EXTRA_WIDTH / 2, r1=1,
                        r2=0, $fn=PLUNGER_ROUNDING_FN
                      );
        }
}

module ejector_plunger(card_size, is_top, is_bottom) {
  render() union() {
      translate(
        _x_(card_size, 1 / 2) + [SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X, 0, 0]
      )
        cuboid(
          _z_(card_size) + [EJECTOR_PLUNGER_WIDTH_X, plunger_back_rounding_center(card_size).y, 0],
          anchor=RIGHT + FRONT
        );

      plunger_retainer(card_size, EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT);
      render() difference() {
          plunger_retainer(card_size, EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT + card_size.z, subtract_width=1);
          if (is_top) {
            cuboid(LARGE_VALUE, anchor=BOTTOM);
          }
          if (is_bottom) {
            cuboid(LARGE_VALUE, anchor=TOP);
          }
        }

      render() translate(_y_(card_size, 1 / 2)) intersection() {
            plunger_retainer(card_size, _EPSILON);
            cuboid([LARGE_VALUE, LARGE_VALUE, card_size.z], anchor=LEFT + FRONT);
          }
    }
}

EJECTOR_PLUNGER_BACK_CLEARANCE = 1;

function plunger_travel_distance_y(card_size) =
  plunger_back_rounding_center(card_size).y - card_size.y + EJECTOR_PLUNGER_WIDTH_X / 2;

// TODO: With current dimensions, the lever doesn't extend *quite* far enough in the `x` direction to perfectly contact
// the plunger.
module ejector_plunger_comp(card_size, is_top, is_bottom) {
  negative() render() minkowski() {
        render() ejector_plunger(card_size, is_top, is_bottom);
        render() translate([0, EJECTOR_PLUNGER_BACK_CLEARANCE, 0]) rotate([90, 0, 0])
              cylinder(
                h=plunger_travel_distance_y(card_size) + EJECTOR_PLUNGER_BACK_CLEARANCE,
                r=EJECTOR_PLUNGER_ANNULAR_CLEARANCE
              );
      }
  ;
  positive() render() translate(PLUNGER_PUSHED_IN ? [0, 0, 0] : [0, -plunger_travel_distance_y(card_size), 0])
        color("green") union() {
            ejector_plunger(card_size, is_top, is_bottom);

            translate(plunger_back_rounding_center(card_size))
              cylinder(h=card_size.z, r=EJECTOR_PLUNGER_WIDTH_X / 2, center=true);
          }
}

module ejector_comp(card_size, is_top, is_bottom) {
  ejector_lever_comp(card_size);
  ejector_plunger_comp(card_size, is_top, is_bottom);
}

ARRAY_CENTERING_OFFSET_X = 0; //-(WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X) / 2;

module conditional_mirror(condition, v) {
  if (condition) {
    mirror(v) children();
  } else {
    children();
  }
}

module block_comp(
  card_size,
  mirror_x,
  card_type_label,
  card_tab_negative_size,
  is_top,
  is_bottom,
  engrave,
  include_bevel_rounding,
  full_design_has_multiple_slots
) {
  conditional_mirror(mirror_x, [1, 0, 0]) {
    translate([ARRAY_CENTERING_OFFSET_X, 0, 0]) {
      carvable() casing(
          card_size, include_bevel_rounding,
          full_design_has_multiple_slots=full_design_has_multiple_slots
        );

      card_slot_comp(card_size, card_tab_negative_size);
      ejector_comp(card_size, is_top, is_bottom);
      color("blue") springs_comp(card_size);

      if (DEBUG_SHOW_CROSS_SECTION) {
        negative() translate([0, 0, LARGE_VALUE / 2]) cube(LARGE_VALUE, center=true);
        // translate(ejector_axle_center(card_size)) negative() translate([ LARGE_VALUE / 2, 0, 0 ])
        //     cube(LARGE_VALUE, center = true);
      }
    }
  }

  if (engrave) {
    engraving_comp(card_size, card_type_label);
  }
}

module block_array_unrounded_comp(
  n,
  card_size,
  card_type_label,
  card_tab_negative_size,
  include_engraving = true,
  use_tiling_offset = false,
  full_design_has_multiple_slots
) {
  for (i = [0:n - 1]) {
    is_top = i == n - 1;
    is_bottom = i == 0;
    translate(
      [
        (use_tiling_offset && (i % 2 == 1)) ? slot_width_distance_x(card_size) / 4 : 0,
        0,
        i * (slot_bottom_distance_z(card_size)),
      ]
    ) block_comp(
        card_size, i % 2 == 1, card_type_label, card_tab_negative_size, is_top, is_bottom,
        include_engraving && is_top, false, full_design_has_multiple_slots
      );
  }
}

module block_array(
  n,
  card_size,
  card_type_label,
  card_tab_negative_size,
  include_engraving = true,
  use_tiling_offset = false,
  full_design_has_multiple_slots
) {
  full_design_has_multiple_slots = n > 1;
  render() translate(
      DEBUG ? [0, 0, 0]
      : -[0, card_size.y + EXTRA_BACK_DEPTH_FOR_LEVER + CASE_BACK_THICKNESS, 0]
    ) compose() {
        render() carvable() difference() {
              render() block_array_unrounded_comp(
                  n=n, card_size=card_size, card_tab_negative_size=card_tab_negative_size,
                  card_type_label=card_type_label, full_design_has_multiple_slots=full_design_has_multiple_slots,
                  $compose_mode="carvable"
                );

              color("orange") render() minkowski_shell() {
                    translate([ARRAY_CENTERING_OFFSET_X * (full_design_has_multiple_slots ? 1 : 1 / 2), 0, 0])
                      casing(
                        card_size, BEVEL_ROUNDING, extra_height=(n - 1) * slot_bottom_distance_z(card_size),
                        full_design_has_multiple_slots=full_design_has_multiple_slots
                      );
                    cube(BEVEL_ROUNDING, center=true);
                  }
            }
        render() negative() block_array_unrounded_comp(
              n=n, card_size=card_size, card_tab_negative_size=card_tab_negative_size,
              card_type_label=card_type_label, full_design_has_multiple_slots=full_design_has_multiple_slots,
              $compose_mode="negative"
            );
        render() positive() block_array_unrounded_comp(
              n=n, card_size=card_size, card_tab_negative_size=card_tab_negative_size,
              card_type_label=card_type_label, full_design_has_multiple_slots=full_design_has_multiple_slots,
              $compose_mode="positive"
            );
      }
}

tx = [30, 0, 0];
ty = [0, 20, 0];

translate(-tx + ty) rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, 0]) render()
      block_array(1, CFEXPRESS_B_CARD_SIZE, "CFexpress B", CFEXPRESS_CARD_TAB_NEGATIVE_SIZE);
translate(tx + ty) rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, 0]) render()
      block_array(1, SD_CARD_SIZE, "SD Card", false);
// if (!DEBUG)
{
  translate(-tx - ty) rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, 0]) render()
        block_array(NUM_SLOTS, CFEXPRESS_B_CARD_SIZE, "CFexpress B", CFEXPRESS_CARD_TAB_NEGATIVE_SIZE);
  translate(tx - ty) rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, 0]) render()
        block_array(NUM_SLOTS, SD_CARD_SIZE, "SD Card", false);
}
