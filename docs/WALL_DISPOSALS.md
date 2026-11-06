# Wall-mounted disposals

Added `/obj/machinery/disposal/wall`, with `/north`, `/south`, `/east` and `/west`
mapping variants. Place it on the **floor tile beside a wall**, with a disposal
trunk underneath, just like an ordinary disposal bin. Its directional sprite
sits at the edge of the tile; the tile remains walkable.

The unit shares normal item capacity, bag emptying, pressure, power, flushing,
manual ejection and pipe routing. Its opening rejects self-climbing, dragging a
person inside, aggressive-grab insertion, shove insertion and monkey-AI stuffing.
Normal disposal bins keep their existing behavior.

Construction is available as **wall-mounted disposals bin** in the RPD's Disposals
category and **Wall-mounted Bin** in the disposal pipe dispenser. Rotate the frame,
attach it over a trunk and weld as usual. Dismantled frames retain the compact
icon, wall-bin type and orientation.

Sprites are extracted from Goonstation's `disposal_small.dmi`, including all four
directions, flush animation, both handle positions, indicator lights and broken
state. See `icons/goonstation/objects/disposal_wall.LICENSE.md` for provenance.

## Validation — 2026-11-05

- BYOND 516.1688, ordinary project compilation using the standard `CBT` define:
  **0 errors, 0 warnings** (`tmp/wall_disposal/build-normal.log`).
- Three focused unit tests compiled and ran on an isolated test server:
  `wall_disposal_rejects_mobs`, `wall_disposal_items`,
  `wall_disposal_construction`. The runner wrote `Success!` to
  `tmp/wall_disposal/runtime/data/clean_run.lk`; its finalizer requires both
  successful tests and zero runtime errors. Test compilation reports the existing
  reference-tracking and disabled-loop-check warnings.
- Verified transferred pixel data against the original for every frame/direction.
  Sprite preview: `tmp/wall_disposal/preview.png`.
- Preparation script: `tmp/wall_disposal/prepare.py`. The isolated server uses its
  own config/data directories and junctions to project source/assets.

In-client visual placement and a live station playtest remain unverified.
