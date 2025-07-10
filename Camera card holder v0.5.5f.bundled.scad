// Stacked camera card holder
// Lucas Garron
// v0.5.5c — manually bundled
// License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
//
// This file has been manually bundled and heavily modified to work around incompatibilities with Bambu's rendering vs. OpenSCAD.
// Therefore, it contains some extremely hacky and unmaintainable workarounds.
// For the original source, see: https://github.com/lgarron/camera-card-holder

CARD_TYPE = "SD Card"; // ["SD Card", "CFExpress B"]

NUMBER_OF_SLOTS = 4;

INCLUDE_CARD_TYPE_ENGRAVING = false;

/* [Design parameters] */

CASING_OUTER_THICKNESS_X = 3.5;
CASING_OUTER_THICKNESS_Z = 2;
CASING_BACK_THICKNESS_Y = 1;
CASING_DISTANCE_BETWEEN_CARDS_Z = 1.5;

/* [Debug] */

INCLUDE_DESIGN_VERSION_ENGRAVING = false;
STRUCTURAL_COLORING = false;
DEBUG_EXCLUDE_CASING = false;
DEBUG_SHOW_CROSS_SECTION = false;
VERSION_TEXT = "v0.5.5f";

/* [Hidden] */

// Incompatible with Bambu rendering.
DUAL_COLOR = false;
DEEP_SECONDARY_COLOR = false;

assert(NUMBER_OF_SLOTS > 0);
assert(floor(NUMBER_OF_SLOTS) == NUMBER_OF_SLOTS);
assert(CARD_TYPE == "SD Card" || CARD_TYPE == "CFExpress B");

module structural_color(color_choice) {
  if (STRUCTURAL_COLORING) {
    color(color_choice) children();
  } else {
    children();
  }
}

VARIANT = "default";

VARIANT_DATA = [
  [
    "default",
    [
      [
        ["VARIANT_DUAL_COLOR", DUAL_COLOR],
        ["VARIANT_DEEP_SECONDARY_COLOR", DEEP_SECONDARY_COLOR],
        ["VARIANT_NUMBER_OF_SLOTS", NUMBER_OF_SLOTS],
        ["CF_EXPRESS_B", CARD_TYPE == "CFExpress B"],
        ["VARIANT_INCLUDE_DESIGN_VERSION_ENGRAVING", INCLUDE_DESIGN_VERSION_ENGRAVING],
      ],
    ],
  ],
  [
    "dual-color",
    [
      [
        ["VARIANT_DUAL_COLOR", true],
      ],
    ],
  ],
  [
    "deep-secondary-color",
    [
      [
        ["VARIANT_DEEP_SECONDARY_COLOR", true],
      ],
    ],
  ],
  [
    "6-slots",
    [
      [
        ["VARIANT_NUMBER_OF_SLOTS", 6],
      ],
    ],
  ],
  [
    "8-slots",
    [
      [
        ["VARIANT_NUMBER_OF_SLOTS", 8],
      ],
    ],
  ],
  [
    "10-slots",
    [
      [
        ["VARIANT_NUMBER_OF_SLOTS", 10],
      ],
    ],
  ],
  [
    "CFExpress-B",
    [
      [
        ["CF_EXPRESS_B", true],
      ],
    ],
  ],
  [
    "unengraved",
    [
      [
        ["VARIANT_INCLUDE_DESIGN_VERSION_ENGRAVING", false],
      ],
    ],
  ],
];
/*

// Allows specifying multiple variants to be rendered by `openscad-auto`: https://github.com/lgarron/dotfiles/blob/main/scripts/app-tools/openscad-auto.rs
//
// Each variant is a string, which must defined as an entry in a global BOSL2 struct named `VARIANT_DATA`.
//
// - The struct must contain an entry with the key `"default"`.
// - Keys are used in file names.
//   - They must not contain the character `.`, as this is used to compose variants (see below).
//   - Keys are used to create file names, so it is worth using names that will be as clear as possible in this context.
// - The value of each entry is a list containing:
//   - A required first item with a BOSL2 struct specifying a mapping of parameter names to values.
//   - An optional second item containing a list of parent variants to inherit from.
//     - Later entries override earlier entries.
//
// Each variant falls back to the parameter value from the `"default"` entry if it is not specified among the ancestors of a given entry.
// Note that the top-level order of entries has no effect on the parameter calculations. Parameter inheritance for a variant depends solely on the ordering of its parents (and their parents, recursively).
//
// The variant is specified in a global `VARIANT` var.
//
// - Multiple variants may be composed by specifying them with a `.` inbetween.
//   - Note that such variants can be defined explicitly in `VARIANT_DATA` by specifying those variants as parents. However, the compositional approach is a very convenient mechanism to avoid boilerplate.
//
// Parameters are computed by calling `get_parameter(parameter_name)` after `VARIANT` and `VARIANT_DATA` have been defined.
//
// Example usage:

VARIANT = "default"; // ["default", "no-version", "mini", "mini.normal-height"]

// This empty block prevents any following `CONSTANT_CASE` variables from being settable in the customizer.
// This prevents pathological interactions with persisted customizer values that are meant to be controlled exclusively by `VARIANT`.
{};

VARIANT_DATA = [
  [
    "default",
    [
      [
        ["TOTAL_HEIGHT", 5],
        ["TRIANGLE_EDGE_LENGTH", 25],
        ["INCLUDE_DESIGN_VERSION_ENGRAVING", true],
      ],
    ],
  ],
  [
    "no-version",
    [
      [
        ["INCLUDE_DESIGN_VERSION_ENGRAVING", false],
      ],
    ],
  ],
  [
    "mini",
    [
      [
        ["TOTAL_HEIGHT", 3],
        ["TRIANGLE_EDGE_LENGTH", 15],
      ],
      // Don't include the version for `mini` (it's small)
      ["no-version"]
    ],
  ],
  [
    "normal-height",
    [
      [
        ["TOTAL_HEIGHT", 5],
      ],
    ],
  ]
];

include <./node_modules/scad/variants.scad>

TOTAL_HEIGHT = get_parameter("TOTAL_HEIGHT");
TRIANGLE_EDGE_LENGTH = get_parameter("TRIANGLE_EDGE_LENGTH");
INCLUDE_DESIGN_VERSION_ENGRAVING = get_parameter("INCLUDE_DESIGN_VERSION_ENGRAVING");

*/

include <BOSL2/std.scad>

/*

type undef = undefined;
type ParameterValue = string | number;

type Struct<KeyType, ValueType> = [string, ValueType][];
type VariantID = string;
type ParameterName = string;
type VariantParameters = Struct<ParameterName, ParameterValue>;
type VariantInheritanceChain = VariantID[]; // Semantics: inheritance chain (later entries take priority)
type VariantEntry =
  | [VariantParameters]
  | [VariantParameters, VariantInheritanceChain];
type VariantData = Struct<VariantID, VariantEntry>;

// Global vars which must be set by the calling code.
export const VARIANT: string; // Variants delimited by `.`
export const VARIANT_DATA: VariantData;

*/

// function __variants__variant_parameters(variant_entry: VariantEntry): VariantParameters;
function __variants__variant_parameters(variant_entry) = variant_entry[0];
// function __variants__variant_parents(variant_entry: VariantEntry): [VariantID];
function __variants__variant_parents(variant_entry) = len(variant_entry) > 1 ? variant_entry[1] : [];

// function __variants__maybe_get_parameter_for_variant(parameter_name: ParameterName, variant_id: VariantID, variant_ids_in_recursion_stack_for_cycle_detection: VariantID[]): ParameterValue | undef;
function __variants__maybe_get_parameter_for_variant(parameter_name, variant_id, variant_ids_in_recursion_stack_for_cycle_detection) =
  // echo("__variants__maybe_get_parameter_for_variant", parameter_name, variant_id, variant_ids_in_recursion_stack_for_cycle_detection)
  assert(is_undef(str_find(variant_id, ".")), "Encountered a variant which contains the period (`.`) character. This character is used to delimit variants, and cannot be part of a variant ID directly")
  assert(!in_list(variant_id, variant_ids_in_recursion_stack_for_cycle_detection), str("Encountered recursively defined variants at the following variant: ", variant_id))
  let (
    variant_entry = struct_val(VARIANT_DATA, variant_id),
  ) assert(!is_undef(variant_entry), str("Variant is missing: ", variant_id)) // Technically we're doing unnecessary string concatentation in the "happy" path, but this should be cheap enough.
  let (
    direct_value = struct_val(__variants__variant_parameters(variant_entry), parameter_name)
  ) is_undef(direct_value) ? __variants__maybe_get_parameter_for_variants(parameter_name, __variants__variant_parents(variant_entry), concat(variant_ids_in_recursion_stack_for_cycle_detection, [variant_id])) : direct_value;;

// function __variants__maybe_get_parameter_for_variants(parameter_name: ParameterName, variants: VariantID[], variant_ids_in_recursion_stack_for_cycle_detection: VariantID[]): ParameterValue | undef;
function __variants__maybe_get_parameter_for_variants(parameter_name, variant_ids, variant_ids_in_recursion_stack_for_cycle_detection) =
  // echo("__variants__maybe_get_parameter_for_variants", parameter_name, variant_ids, variant_ids_in_recursion_stack_for_cycle_detection)
  len(variant_ids) == 0 ? undef
  : (
    let (maybe_value = __variants__maybe_get_parameter_for_variant(parameter_name, last(variant_ids), variant_ids_in_recursion_stack_for_cycle_detection)) is_undef(maybe_value) ? __variants__maybe_get_parameter_for_variants(parameter_name, list_head(variant_ids), variant_ids_in_recursion_stack_for_cycle_detection) : maybe_value
  );

// export function get_parameter(parameter_name: ParameterName): ParameterValue;
function get_parameter(parameter_name) =
  assert(!is_undef(VARIANT), "The global variable `VARIANT` must be set before calling `get_parameter(…)`") // TODO: doesn't work
  assert(!is_undef(VARIANT_DATA), "The global variable `VARIANT_DATA` must be set before calling `get_parameter(…)`") // TODO: doesn't work
  let (default_entry = struct_val(VARIANT_DATA, "default")) assert(!is_undef(default_entry), "An entry for the variant `\"default\"` must be present in `VARIANT_DATA`/")
  let (default_entry_value_for_parameter = struct_val(__variants__variant_parameters(default_entry), parameter_name)) assert(!is_undef(default_entry_value_for_parameter), str("Parameter is missing from the `\"default\"` entry in `VARIANT_DATA` (all parameters must be defined on the default variant): ", parameter_name))
  let (
    variant_ids = str_split(VARIANT, "."),
    maybe_value = __variants__maybe_get_parameter_for_variants(parameter_name, concat(["default"], variant_ids), []),
  ) let (value = is_undef(maybe_value) ? __variants__maybe_get_parameter_for_variant(parameter_name, "default", []) : maybe_value) assert(!is_undef(value), str("Unable to get parameter: ", parameter_name)) // Technically we're doing unnecessary string concatentation in the "happy" path, but this should be cheap enough.
  value;

VARIANT_DUAL_COLOR = get_parameter("VARIANT_DUAL_COLOR");
VARIANT_DEEP_SECONDARY_COLOR = get_parameter("VARIANT_DEEP_SECONDARY_COLOR");
VARIANT_NUMBER_OF_SLOTS = get_parameter("VARIANT_NUMBER_OF_SLOTS");
CF_EXPRESS_B = get_parameter("CF_EXPRESS_B");
VARIANT_INCLUDE_DESIGN_VERSION_ENGRAVING = get_parameter("VARIANT_INCLUDE_DESIGN_VERSION_ENGRAVING");

DEBUG = false;
ROTATE_FOR_PRINTING = !DEBUG;

PLUNGER_PUSHED_IN = true;

STICK_OUT_MARGIN_Z = 0;

$fn = 180;

/*

## v0.5.3

- Add plunger recess.
- Add card slot depth.
- Change label from "SD Card" to "SD Cards".

## v0.5.2

- Decrease extra clearance.
- Add SD card size tweaks.
- Rotate final result 180° to allow placing the scarf in the back.

## v0.5.1

- Add extra clearance for H2D tolerances.
- Increase casing outer thickness for (hopefully) more reliable printability and stability.

## v0.5.0

- Add variant support.
- Introduce dual-color variants.

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
// Adapted from https://github.com/openscad/openscad/issues/5510#issuecomment-2557902853

// Values for "extraction":
//
// - "carvable"
// - "negative"
// - "positive"
// - "carving" (carvable - positive)
module composition_filter(extraction) {
  assert(
    extraction == "carvable" || extraction == "negative" || extraction == "positive" || extraction == "carving",
    "Invalid value for `extraction` parameter.",
  );

  if (extraction == "carving") {
    difference() {
      union() {
        children($compose_mode="carvable");
      }
      children($compose_mode="negative");
    }
  } else {
    if ($compose_mode == extraction) {
      children($compose_mode=extraction);
    }
  }
}

module compose() {
  difference() {
    union() {
      children($compose_mode="carvable");
    }
    children($compose_mode="negative");
  }
  children($compose_mode="positive");
}

module carvable() {
  if ($compose_mode == "carvable")
    children();
}

module negative() {
  if ($compose_mode == "negative")
    children();
}

module positive() {
  if ($compose_mode == "positive")
    children();
}
module duplicate_and_mirror(across = [1, 0, 0]) {
  mirror(across) children();
  children();
}

// `number_of_total_copies` includes the original copy.
module duplicate_and_translate(translation, number_of_total_copies = 2) {
  for (i = [0:(number_of_total_copies - 1)]) {
    translate(translation * i) children();
  }
}

// `number_of_total_copies` includes the original copy.
module duplicate_and_rotate(rotation, number_of_total_copies = 2) {
  for (i = [0:(number_of_total_copies - 1)]) {
    rotate(rotation * i) children();
  }
}
_EPSILON = 0.01;
module minkowski_shell() {
  difference() {
    minkowski() {
      children(0);
      children(1);
    }
    children(0);
  }
}

module round_bevel_cylinder(height, radius, center_z = false, epsilon = _EPSILON) {
  translate([radius, radius, center_z ? 0 : height / 2])
    cylinder(h=height + 2 * epsilon, r=radius, center=true);
}

module round_bevel_complement(height, radius, center_z = false, epsilon = _EPSILON, cap_epsilon = _EPSILON) {
  lip = _EPSILON;
  difference() {
    translate([radius / 2 - lip / 2, radius / 2 - lip / 2, center_z ? 0 : height / 2])
      cube([radius + lip, radius + lip, height + 2 * epsilon], center=true);
    round_bevel_cylinder(height, radius, center_z=center_z, epsilon=cap_epsilon * 2);
  }
}
function __scale_coordinate_at_index(scale_factor, index) =
  assert(is_num(scale_factor) || is_list(scale_factor))
  is_num(scale_factor) ? scale_factor
  : scale_factor[index];

// Could be used to scale a position, a size, or a scale in itself.
function __xyz__scale_entries_independently(components, scale_factor) =
  [
    for (i = [0:len(components) - 1]) components[i] * __scale_coordinate_at_index(scale_factor, i),
  ];

function __xyz__coordinate_index_or_num(v, i) = is_num(v) ? v : v[i];

/* 3D */

function _x_(v, scale_factor = 1) = __xyz__scale_entries_independently([__xyz__coordinate_index_or_num(v, 0), 0, 0], scale_factor);
function _y_(v, scale_factor = 1) = __xyz__scale_entries_independently([0, __xyz__coordinate_index_or_num(v, 1), 0], scale_factor);
function _z_(v, scale_factor = 1) = __xyz__scale_entries_independently([0, 0, __xyz__coordinate_index_or_num(v, 2)], scale_factor);

function _xy_(v, scale_factor = 1) = _x_(v, scale_factor) + _y_(v, scale_factor);
function _xz_(v, scale_factor = 1) = _x_(v, scale_factor) + _z_(v, scale_factor);
function _yz_(v, scale_factor = 1) = _y_(v, scale_factor) + _z_(v, scale_factor);

function _xyz_(v, scale_factor = 1) = _x_(v, scale_factor) + _y_(v, scale_factor) + _z_(v, scale_factor);

/* 2D */

function _x_2d(v, scale_factor = 1) = __xyz__scale_entries_independently([__xyz__coordinate_index_or_num(v, 0), 0], scale_factor);
function _y_2d(v, scale_factor = 1) = __xyz__scale_entries_independently([0, __xyz__coordinate_index_or_num(v, 1)], scale_factor);

function _xy2d_(v, scale_factor = 1) = _x_2d(v, scale_factor) + _y_2d(v, scale_factor);

CFEXPRESS_B_CARD_SIZE = [29.60, 38.55, 3.85];
CFEXPRESS_CARD_TAB_NEGATIVE_SIZE = [11, 1.5, 1];
CFEXPRESS_B_ADJUSTMENTS = [0, 0.5, 0];

// CFEXPRESS_B_UPPER_INDENT_SIZE = [ 1.00, 33.65, 0.55 ];

SD_CARD_SIZE = [24, 32.0, 2.1];
// SD_CARD_LOWER_INDENT_SIZE = [ 1.00, 33.65, 0.70 ];
SD_CARD_ADJUSTMENTS = [-0.25, 0.5, 0];

CLEARANCE = 0.15;

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

EXTRA_CLEARANCE_FOR_H2D = 0.1;

function slot_bottom_distance_z(card_size) = card_size.z + CASING_DISTANCE_BETWEEN_CARDS_Z + CLEARANCE;
function slot_width_distance_x(card_size) =
  card_size.x + 2 * SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X + CASING_DISTANCE_BETWEEN_CARDS_Z;

module casing(card_size, include_bevel_rounding, extra_height = 0, full_design_has_multiple_slots = false) {
  translate([full_design_has_multiple_slots ? 0 : TOTAL_EXTRA_WIDTH_FOR_EJECTOR / 2, 0, extra_height / 2])
    minkowski() {
      bevel_rounding_value = (include_bevel_rounding ? 2 * BEVEL_ROUNDING : 0);
      cuboid(
        card_size + [
          CASING_OUTER_THICKNESS_X * 2 - bevel_rounding_value + TOTAL_EXTRA_WIDTH_FOR_EJECTOR * (full_design_has_multiple_slots ? 2 : 1),
          CASING_BACK_THICKNESS_Y + STICK_OUT_MARGIN_Z - bevel_rounding_value + EXTRA_BACK_DEPTH_FOR_LEVER,
          2 * CASING_OUTER_THICKNESS_Z - bevel_rounding_value + extra_height,
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

module engraving_comp(card_size, card_type_label, for_negative = false) {
  if (for_negative)
    render() union() {
        if (INCLUDE_DESIGN_VERSION_ENGRAVING) {
          // Version engraving
          translate(
            [
              0,
              (CASING_OUTER_THICKNESS_X + card_size.y * 7 / 4 + STICK_OUT_MARGIN_Z) / 2,
              card_size.z * 1 / 2 + CASING_OUTER_THICKNESS_Z - TEXT_ENGRAVING_DEPTH,
            ]
          ) linear_extrude(TEXT_ENGRAVING_DEPTH + _EPSILON)
              text(VERSION_TEXT, size=5, font="Ubuntu:style=bold", halign="center", valign="center");
        }

        if (INCLUDE_CARD_TYPE_ENGRAVING) {
          // Card type engraving
          translate(
            [
              0,
              (CASING_OUTER_THICKNESS_X + card_size.y * 3 / 2 + STICK_OUT_MARGIN_Z) / 2 - 7,
              card_size.z * 1 / 2 + CASING_OUTER_THICKNESS_Z - TEXT_ENGRAVING_DEPTH,
            ]
          ) linear_extrude(TEXT_ENGRAVING_DEPTH + _EPSILON)
              text(CF_EXPRESS_B ? "CFExpress B" : "SD Cards", size=CF_EXPRESS_B ? 5.25 : 6, font="Ubuntu:style=bold", halign="center", valign="center");
        }
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
  positive() structural_color("orange") duplicate_and_mirror() translate(
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
module card_tab_negative_comp(card_size, card_tab_negative_size, for_negative = false) {
  if (for_negative) {
    // TODO: implement angled sides?
    translate([0, 0, -card_size.z * 1 / 2]) cuboid(card_tab_negative_size, anchor=FRONT + TOP);
  }
}

EXTRA_HEIGHT_EACH_SIDE_FOR_LABEL = 0.1;

module card_slot_comp(card_size, card_tab_negative_size, for_negative) {
  if (for_negative) {
    translate([0, STICK_OUT_MARGIN_Z, 0])
      cuboid(card_size + [2 * SPRING_WIDTH, EXTRA_BACK_DEPTH_FOR_LEVER, 2 * CLEARANCE], anchor=FRONT);

    // Add extra height in the middle (on both sides) for sticker labels.
    translate([0, STICK_OUT_MARGIN_Z, 0]) cuboid(
        __xyz__scale_entries_independently(card_size, [2 / 3, 1, 1]) + [2 * SPRING_WIDTH, EXTRA_BACK_DEPTH_FOR_LEVER, 2 * CLEARANCE + 2 * EXTRA_HEIGHT_EACH_SIDE_FOR_LABEL],
        anchor=FRONT
      );

    if (is_list(card_tab_negative_size)) {
      card_tab_negative_comp(card_size, card_tab_negative_size);
    }
  } else {
    positive() %translate([0, STICK_OUT_MARGIN_Z, 0]) cuboid(card_size, anchor=FRONT);
  }
}

EJECTOR_LEVER_WIDTH = EJECTOR_AXLE_RADIUS * 4;
EJECTOR_LEVER_OFFSET_ANGLED_Y = EJECTOR_AXLE_RADIUS;
EJECTOR_LEVER_ROUNDING = EJECTOR_AXLE_RADIUS / 2;
EJECTOR_LEVER_PRINTING_ANGLE = PLUNGER_PUSHED_IN ? 40 : 0;

EJECTOR_AXLE_HOLE_SNAP_CONNECTOR_HEIGHT = CASING_DISTANCE_BETWEEN_CARDS_Z * 1 / 2;

AXLE_INSET = 0.7;
AXLE_INSET_CLEARANCE = 0.6;

module ejector_axle_hole_snappable_print_supports(card_size) {
  duplicate_and_mirror([0, 0, 1]) translate([0, 0, card_size.z / 2 + CASING_DISTANCE_BETWEEN_CARDS_Z / 2 - AXLE_INSET / 2])
      cuboid(
        [
          EJECTOR_AXLE_RADIUS * 1 / 4,
          (EJECTOR_AXLE_RADIUS * 2 + CLEARANCE + EJECTOR_AXLE_CLEARANCE * 2 + 2 * _EPSILON) / 2,
          EJECTOR_AXLE_HOLE_SNAP_CONNECTOR_HEIGHT,
          // card_size.z + 2 * CASING_DISTANCE_BETWEEN_CARDS_Z + 2 * _EPSILON + 2 *
          // _EPSILON
        ],
        anchor=FRONT
      );
}

LEVER_PRINT_SUPPORT_WIDTH = 0.5;

LEVER_SCALE = 1.5;
LEVER_OFFSET = 1;

module untranslated_axle_hole(card_size) {

  union() {

    cylinder(
      h=card_size.z + 2 * CASING_DISTANCE_BETWEEN_CARDS_Z + 2 * _EPSILON - 2 * AXLE_INSET_CLEARANCE,
      r=EJECTOR_AXLE_RADIUS + EJECTOR_AXLE_CLEARANCE, center=true
    );

    {
      cuboid(
        [
          EJECTOR_AXLE_RADIUS * 2 * 2 / 3,
          EJECTOR_AXLE_RADIUS + CLEARANCE + EJECTOR_AXLE_CLEARANCE,
          card_size.z + 2 * CASING_DISTANCE_BETWEEN_CARDS_Z + 2 * _EPSILON - 2 * AXLE_INSET_CLEARANCE,
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
module ejector_lever_comp(card_size, for_negative = false) {
  lever_thickness = card_size.z - EXTRA_CLEARANCE_FOR_H2D * 2;

  // Ejector back area
  if (for_negative)
    translate([card_size.x * 1 / 2, card_size.y + STICK_OUT_MARGIN_Z, 0]) cuboid(
        [
          SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X,
          EXTRA_BACK_DEPTH_FOR_LEVER,
          card_size.z + 2 * CLEARANCE,
        ],
        anchor=LEFT + FRONT
      );

  translate(ejector_axle_center(card_size)) {
    // Ejector axle hole
    if (for_negative)
      difference() {
        untranslated_axle_hole(card_size);

        ejector_axle_hole_snappable_print_supports(card_size);
      }

    if (!for_negative) {

      // Axle
      positive()
        cylinder(h=card_size.z + 2 * CASING_DISTANCE_BETWEEN_CARDS_Z - 2 * AXLE_INSET, r=EJECTOR_AXLE_RADIUS, center=true);

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
          _x_(card_size, LEVER_SCALE) + _z_(lever_thickness) + [0, EJECTOR_LEVER_WIDTH, 0] - [2 * EJECTOR_LEVER_ROUNDING, 2 * EJECTOR_LEVER_ROUNDING, -_EPSILON],
        ]
      );
      local_offset_1 = _x_(struct_val(lever_values_struct, "lever_core_size"), -1 / 2);
      local_offset_2 = _y_(struct_val(lever_values_struct, "lever_core_size"), -1 / 2) + struct_val(lever_values_struct, "lever_offset");
      structural_color("purple") positive() rotate([0, 0, EJECTOR_LEVER_PRINTING_ANGLE]) difference() {
              union() {
                lever_offset_y = -EJECTOR_AXLE_RADIUS + EJECTOR_AXLE_RADIUS / 2;
                translate([SPRING_WIDTH + TOTAL_EXTRA_WIDTH_FOR_EJECTOR - CLEARANCE + LEVER_OFFSET, 0, 0])
                  difference() {
                    translate([0, lever_offset_y, 0]) cuboid(
                        _x_(card_size, LEVER_SCALE) + _z_(lever_thickness) + [0, EJECTOR_AXLE_RADIUS, 0], anchor=RIGHT
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
      structural_color("purple") difference() {
          union() {
            cuboid(
              [LEVER_PRINT_SUPPORT_WIDTH, axle_center_to_back_y + _EPSILON, lever_thickness / 2],
              anchor=FRONT
            );

            // translate([0, -1, 0]) rotate([0, 0, EJECTOR_LEVER_PRINTING_ANGLE]) duplicate_and_translate(
            //       [5.25, 0, 0]
            //     ) translate([5.25, 0, 0]) rotate([0, 0, -EJECTOR_LEVER_PRINTING_ANGLE])
            //           cuboid(
            //             [LEVER_PRINT_SUPPORT_WIDTH, axle_center_to_back_y + _EPSILON, lever_thickness / 2],
            //             anchor=FRONT
            //           );
          }
          translate([0, axle_center_to_back_y + _EPSILON, 0])
            cuboid([LARGE_VALUE, LARGE_VALUE, LARGE_VALUE], anchor=FRONT);
        }
    }
  }
}

EJECTOR_PLUNGER_ANNULAR_CLEARANCE = 0.2 + EXTRA_CLEARANCE_FOR_H2D;

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

PLUNGER_FRONT_RECESS = 1;
module plunger_retainer(card_size, extra_height, subtract_width = 0, recess = false) {
  depth = SD_CARD_SIZE.y * 1 / 5;
  recess_amount = recess ? PLUNGER_FRONT_RECESS : 0;

  plunger_hook_size = _z_(card_size) + [EJECTOR_PLUNGER_WIDTH_X - subtract_width, depth, 0];
  render() translate(_x_(card_size) / 2 + [SPRING_WIDTH + TOTAL_EXTRA_WIDTH_FOR_EJECTOR, 0, 0]) render() minkowski() {
          render() translate([0, recess_amount, 0]) cuboid(plunger_hook_size - _y_(recess_amount), anchor=RIGHT + FRONT);

          render() translate([-EJECTOR_RETAINER_EXTRA_WIDTH / 2, 0, 0])
              skew(xy=90 - PLUNGER_RETAINER_BACK_SLOPE_ANGLE) render()
                  scale([EJECTOR_RETAINER_EXTRA_WIDTH / 2, 1, extra_height / 2]) rotate([-90, 0, 0])
                      cylinder(
                        h=tan(PLUNGER_RETAINER_BACK_SLOPE_ANGLE) * EJECTOR_RETAINER_EXTRA_WIDTH / 2, r1=1,
                        r2=0, $fn=PLUNGER_ROUNDING_FN
                      );
        }
}

PLUNGER_PRINTING_OFFSET = 0.4;
PLUNGER_PRINTING_SUPPORT_RADIUS = 0.3;

module ejector_plunger(card_size, is_top, is_bottom) {
  fwd(PLUNGER_PRINTING_OFFSET) union() {
      render() {
        translate(
          _x_(card_size, 1 / 2) + [SPRING_WIDTH + WALL_WIDTH_FOR_EJECTOR_CHUTE + EJECTOR_PLUNGER_WIDTH_X, PLUNGER_FRONT_RECESS, 0]
        )
          cuboid(
            _z_(card_size) + [EJECTOR_PLUNGER_WIDTH_X, plunger_back_rounding_center(card_size).y - PLUNGER_FRONT_RECESS, 0],
            anchor=RIGHT + FRONT
          );

        plunger_retainer(card_size, EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT, recess=true);

        plunger_retainer(card_size, EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT, recess=true);
        render() difference() {
            plunger_retainer(card_size, EJECTOR_PLUNGER_FRONT_EXTRA_HEIGHT + card_size.z, subtract_width=1, recess=true);
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
}

EJECTOR_PLUNGER_BACK_CLEARANCE = 1;

function plunger_travel_distance_y(card_size) =
  plunger_back_rounding_center(card_size).y - card_size.y + EJECTOR_PLUNGER_WIDTH_X / 2;

// TODO: With current dimensions, the lever doesn't extend *quite* far enough in the `x` direction to perfectly contact
// the plunger.
module ejector_plunger_comp(card_size, is_top, is_bottom, for_negative = false) {
  if (for_negative) {
    render() minkowski() {
        render() ejector_plunger(card_size, is_top, is_bottom);
        render() translate([0, EJECTOR_PLUNGER_BACK_CLEARANCE, 0]) rotate([90, 0, 0])
              cylinder(
                h=plunger_travel_distance_y(card_size) + EJECTOR_PLUNGER_BACK_CLEARANCE,
                r=EJECTOR_PLUNGER_ANNULAR_CLEARANCE
              );
      }
  } else {
    positive() render() translate(PLUNGER_PUSHED_IN ? [0, 0, 0] : [0, -plunger_travel_distance_y(card_size), 0])
          structural_color("green") union() {
              ejector_plunger(card_size, is_top, is_bottom);

              fwd(PLUNGER_PRINTING_OFFSET)
                translate(plunger_back_rounding_center(card_size))
                  cylinder(h=card_size.z, r=EJECTOR_PLUNGER_WIDTH_X / 2, center=true);
              #translate(plunger_back_rounding_center(card_size))
                rotate([90, 0, 0])
                  cyl(r=PLUNGER_PRINTING_SUPPORT_RADIUS, h=EJECTOR_PLUNGER_WIDTH_X / 2 + PLUNGER_PRINTING_OFFSET * 2, anchor=TOP);
            }
  }
}

module ejector_comp(card_size, is_top, is_bottom, plungers_only = undef, for_negative = false) {
  if (!plungers_only) ejector_lever_comp(card_size, for_negative);
  ejector_plunger_comp(card_size, is_top, is_bottom, for_negative=for_negative);
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
  full_design_has_multiple_slots,
  plungers_only = undef,
  for_negative = false
) {
  conditional_mirror(mirror_x, [1, 0, 0]) {
    translate([ARRAY_CENTERING_OFFSET_X, 0, 0]) {
      if (!plungers_only) {
        if (!DEBUG_EXCLUDE_CASING) {
          if (!for_negative)
            carvable() casing(
                card_size, include_bevel_rounding,
                full_design_has_multiple_slots=full_design_has_multiple_slots
              );
        }

        card_slot_comp(card_size, card_tab_negative_size, for_negative=for_negative);
        structural_color("blue") springs_comp(card_size);
      }
      ejector_comp(card_size, is_top, is_bottom, plungers_only=plungers_only, for_negative=for_negative);

      if (DEBUG_SHOW_CROSS_SECTION) {
        if (for_negative) translate([0, 0, LARGE_VALUE / 2]) cube(LARGE_VALUE, center=true);
        // translate(ejector_axle_center(card_size)) negative() translate([ LARGE_VALUE / 2, 0, 0 ])
        //     cube(LARGE_VALUE, center = true);
      }
    }
  }

  engraving_comp(card_size, card_type_label, for_negative=for_negative);
}

LAYER_HEIGHT = 0.2;
COLORING_DEPTH = VARIANT_DEEP_SECONDARY_COLOR ? LARGE_VALUE / 2 : 6 * LAYER_HEIGHT;

module block_array_unrounded_comp_inner_loop(
  i,
  n,
  card_size,
  card_type_label,
  card_tab_negative_size,
  include_engraving = true,
  use_tiling_offset = false,
  full_design_has_multiple_slots,
  plungers_only = undef,
  color_layers_only = false,
  for_negative = false,
) {
  translation = [
    (use_tiling_offset && (i % 2 == 1)) ? slot_width_distance_x(card_size) / 4 : 0,
    0,
    i * (slot_bottom_distance_z(card_size)),
  ];
  is_bottom = i == 0;
  is_top = i == n - 1;
  render() translate(
      translation
    ) {
      if (!color_layers_only) {
        if (!plungers_only || plungers_only == "all" || (plungers_only == "even" && i % 2 == 0)) {
          block_comp(
            card_size, i % 2 == 1, card_type_label, card_tab_negative_size, is_top, is_bottom,
            include_engraving && is_top, false, full_design_has_multiple_slots,
            plungers_only=plungers_only,
            for_negative=for_negative
          );
        }
      }
      if (color_layers_only && i % 2 == 0 && !for_negative) {
        extra = i == 0 ? LARGE_VALUE : 0;
        translate([0, COLORING_DEPTH, -extra / 2]) carvable()
            cuboid([LARGE_VALUE, LARGE_VALUE, slot_bottom_distance_z(card_size) + extra], anchor=BACK);
      }
    }
}

module block_array_unrounded_comp(
  n,
  card_size,
  card_type_label,
  card_tab_negative_size,
  include_engraving = true,
  use_tiling_offset = false,
  full_design_has_multiple_slots,
  plungers_only = undef,
  color_layers_only = false,
  for_negative = false,
) {
  num_copies_of_idx_1 = max(0, floor((n - 1) / 2));
  num_copies_of_idx_2 = max(0, floor((n - 2) / 2));

  translation = [
    0,
    0,
    2 * slot_bottom_distance_z(card_size),
  ];

  render() {
    if (n > 0)
      block_array_unrounded_comp_inner_loop(
        i=0,
        n=n,
        card_size=card_size,
        card_type_label=card_type_label,
        card_tab_negative_size=card_tab_negative_size,
        include_engraving=include_engraving,
        use_tiling_offset=use_tiling_offset,
        full_design_has_multiple_slots=full_design_has_multiple_slots,
        plungers_only=plungers_only,
        color_layers_only=color_layers_only,
        for_negative=for_negative,
      );

    if (num_copies_of_idx_1 > 0)
      duplicate_and_translate(translation=translation, number_of_total_copies=num_copies_of_idx_1)
        block_array_unrounded_comp_inner_loop(
          i=1,
          n=n,
          card_size=card_size,
          card_type_label=card_type_label,
          card_tab_negative_size=card_tab_negative_size,
          include_engraving=include_engraving,
          use_tiling_offset=use_tiling_offset,
          full_design_has_multiple_slots=full_design_has_multiple_slots,
          plungers_only=plungers_only,
          color_layers_only=color_layers_only,
          for_negative=for_negative,
        );

    if (num_copies_of_idx_2 > 0)
      duplicate_and_translate(translation=translation, number_of_total_copies=num_copies_of_idx_2)
        block_array_unrounded_comp_inner_loop(
          i=2,
          n=n,
          card_size=card_size,
          card_type_label=card_type_label,
          card_tab_negative_size=card_tab_negative_size,
          include_engraving=include_engraving,
          use_tiling_offset=use_tiling_offset,
          full_design_has_multiple_slots=full_design_has_multiple_slots,
          plungers_only=plungers_only,
          color_layers_only=color_layers_only,
          for_negative=for_negative,
        );

    if (n > 1)
      block_array_unrounded_comp_inner_loop(
        i=n - 1,
        n=n,
        card_size=card_size,
        card_type_label=card_type_label,
        card_tab_negative_size=card_tab_negative_size,
        include_engraving=include_engraving,
        use_tiling_offset=use_tiling_offset,
        full_design_has_multiple_slots=full_design_has_multiple_slots,
        plungers_only=plungers_only,
        color_layers_only=color_layers_only,
        for_negative=for_negative,
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
  full_design_has_multiple_slots,
  plungers_only = undef,
  color_layers_only = false,
) {
  full_design_has_multiple_slots = n > 1;
  render() translate(
      DEBUG ? [0, 0, 0]
      : -[0, card_size.y + EXTRA_BACK_DEPTH_FOR_LEVER + CASING_BACK_THICKNESS_Y, 0]
    ) compose() {
        if (!plungers_only && !color_layers_only) {
          difference() {
            compose() {
              composition_filter("carvable")
                block_array_unrounded_comp(
                  n=n, card_size=card_size, card_tab_negative_size=card_tab_negative_size, include_engraving=include_engraving,
                  card_type_label=card_type_label, full_design_has_multiple_slots=full_design_has_multiple_slots,
                  for_negative=false
                );
              composition_filter("positive")
                block_array_unrounded_comp(
                  n=n, card_size=card_size, card_tab_negative_size=card_tab_negative_size, include_engraving=include_engraving,
                  card_type_label=card_type_label, full_design_has_multiple_slots=full_design_has_multiple_slots,
                  for_negative=false
                );

              negative() structural_color("silver") minkowski_shell() {
                    translate([ARRAY_CENTERING_OFFSET_X * (full_design_has_multiple_slots ? 1 : 1 / 2), 0, 0])
                      casing(
                        card_size, BEVEL_ROUNDING, extra_height=(n - 1) * slot_bottom_distance_z(card_size),
                        full_design_has_multiple_slots=full_design_has_multiple_slots
                      );
                    cube(BEVEL_ROUNDING, center=true);
                  }
            }

            block_array_unrounded_comp(
              n=n, card_size=card_size, card_tab_negative_size=card_tab_negative_size, include_engraving=include_engraving,
              card_type_label=card_type_label, full_design_has_multiple_slots=full_design_has_multiple_slots, for_negative=true
            );
          }
        }
        render() positive() block_array_unrounded_comp(
              n=n, card_size=card_size, card_tab_negative_size=card_tab_negative_size, include_engraving=include_engraving,
              card_type_label=card_type_label, full_design_has_multiple_slots=full_design_has_multiple_slots,
              $compose_mode="positive",
              plungers_only=plungers_only,
              color_layers_only=color_layers_only
            );
      }
}

tx = [30, 0, 0];
ty = [0, 20, 0];

module block_array_secondary_color_mask(
  n,
  card_size,
  card_type_label,
  card_tab_negative_size,
  include_engraving = true,
  use_tiling_offset = false,
  full_design_has_multiple_slots,
) {
  intersection() {
    difference() {
      block_array(
        n=n,
        card_size=card_size,
        card_type_label=card_type_label,
        card_tab_negative_size=card_tab_negative_size,
        include_engraving=include_engraving,
        use_tiling_offset=use_tiling_offset,
        full_design_has_multiple_slots=full_design_has_multiple_slots,
      );
      block_array(
        n=n,
        card_size=card_size,
        card_type_label=card_type_label,
        card_tab_negative_size=card_tab_negative_size,
        include_engraving=include_engraving,
        use_tiling_offset=use_tiling_offset,
        full_design_has_multiple_slots=full_design_has_multiple_slots,
        plungers_only="all"
      );
    }
    block_array(
      n=n,
      card_size=card_size,
      card_type_label=card_type_label,
      card_tab_negative_size=card_tab_negative_size,
      include_engraving=include_engraving,
      use_tiling_offset=use_tiling_offset,
      full_design_has_multiple_slots=full_design_has_multiple_slots,
      color_layers_only=true
    );
  }
  intersection() {
    block_array(
      n=n,
      card_size=card_size,
      card_type_label=card_type_label,
      card_tab_negative_size=card_tab_negative_size,
      include_engraving=include_engraving,
      use_tiling_offset=use_tiling_offset,
      full_design_has_multiple_slots=full_design_has_multiple_slots,
      plungers_only="even"
    );
    translate([0, -(card_size.y + EXTRA_BACK_DEPTH_FOR_LEVER + CASING_BACK_THICKNESS_Y) + COLORING_DEPTH, 0])
      cuboid(LARGE_VALUE, anchor=BACK);
  }
}

module block_array_primary_color(
  n,
  card_size,
  card_type_label,
  card_tab_negative_size,
  include_engraving = true,
  use_tiling_offset = false,
  full_design_has_multiple_slots,
) {
  difference() {
    block_array(
      n=n,
      card_size=card_size,
      card_type_label=card_type_label,
      card_tab_negative_size=card_tab_negative_size,
      include_engraving=include_engraving,
      use_tiling_offset=use_tiling_offset,
      full_design_has_multiple_slots=full_design_has_multiple_slots,
    );
    block_array_secondary_color_mask(
      n=n,
      card_size=card_size,
      card_type_label=card_type_label,
      card_tab_negative_size=card_tab_negative_size,
      include_engraving=include_engraving,
      use_tiling_offset=use_tiling_offset,
      full_design_has_multiple_slots=full_design_has_multiple_slots,
    );
  }
}

module block_array_color(
  n,
  card_size,
  card_type_label,
  card_tab_negative_size,
  include_engraving = true,
  use_tiling_offset = false,
  full_design_has_multiple_slots,
  primary_color,
  card_size_negative_adjust = [0, 0, 0]
) {
  squished_card_size = card_size + card_size_negative_adjust;
  if (is_undef(primary_color)) {
    block_array(
      n=n,
      card_size=squished_card_size,
      card_type_label=card_type_label,
      card_tab_negative_size=card_tab_negative_size,
      include_engraving=include_engraving,
      use_tiling_offset=use_tiling_offset,
      full_design_has_multiple_slots=full_design_has_multiple_slots,
    );
  } else if (primary_color) {
    block_array_primary_color(
      n=n,
      card_size=squished_card_size,
      card_type_label=card_type_label,
      card_tab_negative_size=card_tab_negative_size,
      include_engraving=include_engraving,
      use_tiling_offset=use_tiling_offset,
      full_design_has_multiple_slots=full_design_has_multiple_slots,
    );
  } else {
    block_array_secondary_color_mask(
      n=n,
      card_size=squished_card_size,
      card_type_label=card_type_label,
      card_tab_negative_size=card_tab_negative_size,
      include_engraving=include_engraving,
      use_tiling_offset=use_tiling_offset,
      full_design_has_multiple_slots=full_design_has_multiple_slots,
    );
  }
}

module parts(primary_color = under) {
  // translate(-tx + ty) rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, 0]) render()
  //       block_array_color(1, CFEXPRESS_B_CARD_SIZE, "CFexpress B", CFEXPRESS_CARD_TAB_NEGATIVE_SIZE, primary_color=primary_color);
  // translate(tx + ty) rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, 0]) render()
  //       block_array_color(1, SD_CARD_SIZE, "SD Card", false, primary_color=primary_color);
  // if (!DEBUG)
  {
    if (CF_EXPRESS_B) {
      rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, ROTATE_FOR_PRINTING ? 180 : 0]) render()
          block_array_color(VARIANT_NUMBER_OF_SLOTS, CFEXPRESS_B_CARD_SIZE, "CFexpress B", CFEXPRESS_CARD_TAB_NEGATIVE_SIZE, primary_color=primary_color, include_engraving=true);
    } else {
      rotate([ROTATE_FOR_PRINTING ? -90 : 0, 0, ROTATE_FOR_PRINTING ? 180 : 0]) render()
          block_array_color(VARIANT_NUMBER_OF_SLOTS, SD_CARD_SIZE, "SD Cards", false, primary_color=primary_color, card_size_negative_adjust=SD_CARD_ADJUSTMENTS, include_engraving=true);
    }
  }
}

if (VARIANT_DUAL_COLOR) {
  group("primary_color") structural_color("blue") parts(primary_color=true);
  group("secondary_color") structural_color("red") parts(primary_color=false);
} else {
  group("single_color") parts(primary_color=undef);
}
