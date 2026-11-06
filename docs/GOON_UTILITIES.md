# Pneumatic mail and glass recycling

Both machines use sprites extracted from the local Goonstation source without
changing their pixels. Provenance and original-file hashes are recorded alongside
`icons/goonstation/objects/mail_chute.dmi` and `glass_recycler.dmi`.

## Pneumatic mail

- Type: `/obj/machinery/disposal/mail`.
- Available in the RPD's **Disposals** category and disposal pipe dispenser as
  **Mail Chute**. Attach over a trunk and weld using normal disposal construction.
- Insert items, select a department in the interface, then press **Send mail**.
  Pressure, power, pump controls and manual ejection use the existing disposal
  machinery. The opening rejects people.
- Routing uses the existing `TAGGERLOCATIONS` addresses and sorting junctions.
  Pipes must physically connect to the destination, and the relevant junction
  must be tagged for that department. The menu does not establish new pipe routes.
- A destination tagger labels a terminal's receiving address. This labels the
  terminal; configure the branch junction with the same tag separately.
- The terminal's selected destination takes precedence over individual package
  labels. Received items are placed beside the receiving terminal, which chimes
  and increments its delivery counter. They are not automatically sent back.
- Ordinary disposal outlets can still receive mail from these terminals.

## Glass recycler

- Type: `/obj/machinery/glass_recycler`.
- Cargo: **Glass recycling equipment** in the organic/service supply group.
- Construction: the **Glass Recycler** machine circuit board is available from
  the circuit imprinter with programming 1 and materials 1. It requires a matter
  bin and a manipulator in an ordinary machine frame.
- Insert an empty vessel, plate, bowl, ordinary glass sheet stack, glass shard or
  broken bottle by clicking with it. Full vessels and vessels containing other
  objects are rejected. No-drop items and non-glass machinery are rejected.
- The catalog makes empty drinking glasses, shot glasses, mugs, plates, bowls,
  beakers, large beakers and chemical bottles.
- Plain glass sheets contribute their actual material amount. Each recipe
  consumes at least the raw glass material present in its product; broken
  glassware contributes no more than a basic glass. Specialty vessels containing
  other materials are not accepted as ordinary glassware.
- Requires power and a closed maintenance panel. Supports normal screwdriver,
  crowbar and wrench maintenance/deconstruction.

## Verification

Scripts, sprite previews, builds and isolated runtime logs are under
`tmp/goon_utilities`. The runtime suite exercises delivery through actual trunks
and a sorting junction with a deliberately conflicting wrapper label; invalid
destinations; construction availability; every manufacturing recipe; resource
conservation; full and occupied containers; specialty containers; broken bottles;
invalid requests and power loss. It also reruns the three wall-disposal tests.

The tests exposed an existing queued atmos callback touching deleted disposal
units. The callback now checks that its disposal and turf still exist before
accessing air.

Final results on 2026-11-05: ordinary BYOND 516.1688 compilation **0 errors,
0 warnings** (`build-final.log`); TypeScript and TGUI production build PASS;
Biome check of both interfaces PASS; **7/7 runtime tests PASS, zero runtimes**
(`runtime-final.log` and `runtime/data/clean_run.lk`). The test compilation has
the existing reference-tracking and disabled-loop-check warnings.

The station maps are not edited by this change; use the construction and cargo
entries above to place the machines. In-client placement and interface use have
not been playtested.
