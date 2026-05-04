# aerobeat-content-core

Canonical AeroBeat authored-content contracts for the downscoped v1 package model: Songs, Charts, Sets, Workouts, Coach Configs, Environments, shared chart-envelope types, and lightweight package validation helpers.

## Architecture role

`aerobeat-content-core` owns the durable content-lane contract shared by authoring tools and runtime consumers. This repo defines the small set-centered package truth while leaving gameplay execution, rendering, scoring, and editor UX to other repos.

## Approved v1 contract

The current canonical authored package shape is:

- `songs/`
- `charts/`
- `sets/`
- `workouts/`
- `coaches/`
- `environments/`

Key rules:

- official gameplay features are **boxing** and **flow**
- Boxing straight-punch chart types are `punch_left` / `punch_right`; `guard` is canonical wording
- `orthodox` / `southpaw` are authored stance semantics, not tracked input-event vocabulary
- Flow keeps `placement` = pass-through location and optional `direction` = follow-through guidance
- **dance** and **step** are not valid shared content-core feature values
- **Set** is the package-local composition linker between one song, one chart, one environment, and optional coaching overlay selection
- **Workout** sequences ordered `setId` values
- coaching remains valid through coach-config content
- package-local gameplay `assets` and `assetSelections` are not part of the active contract here
- `routine` is not canonical truth in this repo

## Repository scope

This repo intentionally stays contract-focused. It answers:

- which authored record fields are structurally required
- which shared enums and schema ids are canonical
- which package/reference checks are shared across tooling
- what a minimal valid set-centered content package looks like

It intentionally does **not** own:

- editor UX
- CLI command parsing
- runtime rendering or scoring systems
- mode-specific semantic gameplay validation beyond shared structure
- internal product asset catalogs or package-local gameplay asset subsets

## Validation

Run the headless contract suite with:

```bash
godot --headless --path .testbed --script res://../tests/run_contract_tests.gd
```

The suite covers:

- valid minimal boxing package acceptance under the set-centered contract
- rejection of legacy Boxing punch labels such as `jab`, `cross`, `jab_left`, and `cross_right`
- rejection of Boxing stance labels when they are authored as tracked input events
- preservation of Flow `placement` vs `direction` chart-field semantics
- rejection of missing set/song references
- rejection of forbidden legacy manifest fields such as `routines`, `assets`, and `assetSelections`
- rejection of non-v1 gameplay features such as `dance` and `step`
- workout sequencing and workout-resolution semantics based on `setId`
- song timing structural validation

## Repository status

This repo now reflects the downscoped AeroBeat v1 content contract, including helper type names that now match the set-centered semantics already carried by the contract.
