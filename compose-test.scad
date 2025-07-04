

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


compose() {
  carvable()cuboid(20);
  negative() cyl(h=100, r=2);
}
