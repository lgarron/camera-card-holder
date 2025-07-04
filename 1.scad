// Stacked camera card holder
// Lucas Garron
// v0.5.5 — manually bundled
// License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
//
// This file has been manually bundled and heavily modified to work around incompatibilities with Bambu's rendering vs. OpenSCAD.
// For the original source, see: https://github.com/lgarron/camera-card-holder

VARIANT = "default"; // ["default", "dual-color", "dual-color.deep-secondary-color", "CFExpress-B", "6-slots", "8-slots", "CFExpress-B.8-slots", "8-slots.dual-color.deep-secondary-color", "CFExpress-B.8-slots.dual-color.deep-secondary-color", "unengraved"]

// Overridden by the `unengraved` variant.
INCLUDE_ENGRAVING = true;

// Overridden by variants that explicitly set the number of slots.
NUMBER_OF_SLOTS = 4;

DEBUG_EXCLUDE_CASING = false;

/* [Hidden] */

// This empty block prevents any following `CONSTANT_CASE` variables from being settable in the customizer.
// This prevents pathological interactions with persisted customizer values that are meant to be controlled exclusively by `VARIANT`.
{};

VERSION_TEXT = "v0.5.5";

VARIANT_DATA = [
  [
    "default",
    [
      [
        ["DUAL_COLOR", false],
        ["DEEP_SECONDARY_COLOR", false],
        ["VARIANT_NUMBER_OF_SLOTS", NUMBER_OF_SLOTS],
        ["CF_EXPRESS_B", false],
        ["VARIANT_INCLUDE_ENGRAVING", INCLUDE_ENGRAVING],
      ],
    ],
  ],
  [
    "dual-color",
    [
      [
        ["DUAL_COLOR", true],
      ],
    ],
  ],
  [
    "deep-secondary-color",
    [
      [
        ["DEEP_SECONDARY_COLOR", true],
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
        ["VARIANT_INCLUDE_ENGRAVING", false],
      ],
    ],
  ],
];
