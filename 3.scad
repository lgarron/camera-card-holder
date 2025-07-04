
DUAL_COLOR = get_parameter("DUAL_COLOR");
DEEP_SECONDARY_COLOR = get_parameter("DEEP_SECONDARY_COLOR");
VARIANT_NUMBER_OF_SLOTS = get_parameter("VARIANT_NUMBER_OF_SLOTS");
CF_EXPRESS_B = get_parameter("CF_EXPRESS_B");
VARIANT_INCLUDE_ENGRAVING = get_parameter("VARIANT_INCLUDE_ENGRAVING");

DEBUG = false;
DEBUG_SHOW_CROSS_SECTION = DEBUG;
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
