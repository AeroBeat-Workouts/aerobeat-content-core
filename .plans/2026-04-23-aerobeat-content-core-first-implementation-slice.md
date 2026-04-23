# AeroBeat Content Core + Content Authoring — Definition Phase

**Date:** 2026-04-23  
**Status:** Draft  
**Agent:** Chip 🐱‍💻

---

## Goal

Define what `aerobeat-content-core` and `aerobeat-tool-content-authoring` are actually responsible for before any implementation begins, including ownership boundaries, concrete capabilities, first user/workflow targets, and the minimum day-one contract/workflow surfaces worth building.

---

## Overview

Derrick correctly called out that the previous implementation-first draft was premature. We have architecture direction and repo-shape guidance, but we have **not yet finished defining what the content lane and content-authoring tool should actually do in practice**. Until those responsibilities, workflows, and day-one surfaces are explicit, implementation would just be guesswork.

So this plan is now a **definition and design plan**, not an execution plan. The next step is to turn the existing architecture docs into a clearer product/contract definition for both repos: what problems they solve, what they must own, what they must not own, which users/workflows matter first, what “day one” means, and what concrete interfaces/services/files are justified by those decisions.

Only after those definitions are agreed should we create Beads and spawn coder/qa/auditor implementation work. Until then, the work is discussion, definition, and doc refinement.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Approved day-one repo shapes and ownership split for content-core and tool-content-authoring | `projects/aerobeat/aerobeat-docs/docs/architecture/content-repo-shapes.md` |
| `REF-02` | Current repo identity and intended development flow for tool-content-authoring | `projects/aerobeat/aerobeat-tool-content-authoring/README.md` |
| `REF-03` | Current repo identity and scope statement for content-core | `projects/aerobeat/aerobeat-content-core/README.md` |
| `REF-04` | Last session handoff describing the AeroBeat stop point and likely next area | `memory/2026-04-21.md#L41-L87` |

---

## Tasks

### Task 1: Define the job of `aerobeat-content-core`

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** Not ready to spawn yet. First, work with Derrick to define what `aerobeat-content-core` should actually do. Clarify the durable content language, what records/contracts belong there, who consumes it, which validation belongs there vs elsewhere, and what explicitly stays out.

**Folders Created/Deleted/Modified:**
- likely `aerobeat-docs/docs/architecture/`
- possibly `aerobeat-content-core/README.md`
- `.plans/`

**Files Created/Deleted/Modified:**
- likely definition docs, decision docs, or refined READMEs only

**Status:** ⏳ Pending discussion

**Results:** Need Derrick alignment on the actual responsibilities and day-one scope of the repo.

---

### Task 2: Define the job of `aerobeat-tool-content-authoring`

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-04`  
**Prompt:** Not ready to spawn yet. First, work with Derrick to define what `aerobeat-tool-content-authoring` should actually do. Clarify whether it is primarily authoring, validation, migration, packaging, inspection, import/export, or some staged subset of those; identify its first real workflows and the headless/editor split.

**Folders Created/Deleted/Modified:**
- likely `aerobeat-docs/docs/architecture/`
- possibly `aerobeat-tool-content-authoring/README.md`
- `.plans/`

**Files Created/Deleted/Modified:**
- likely definition docs, decision docs, or refined READMEs only

**Status:** ⏳ Pending discussion

**Results:** Need Derrick alignment on the actual workflows and minimum useful product shape.

---

### Task 3: Define the day-one interaction between the two repos

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** Not ready to spawn yet. First, define the concrete handoff boundary between the repos: what content-core exposes, what content-authoring consumes, which interfaces/services exist on day one, what files/resources/tests are justified immediately, and what should wait.

**Folders Created/Deleted/Modified:**
- likely docs only

**Files Created/Deleted/Modified:**
- likely interface definition docs, boundary docs, or staged roadmap docs

**Status:** ⏳ Pending discussion

**Results:** Need a clean boundary so implementation does not invent premature abstractions.

---

### Task 4: Convert the agreed definition into an implementation-ready plan

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `primary`)  
**Role:** `primary`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** After Derrick approves the definitions, rewrite this plan into an implementation-ready plan with explicit Beads, coder → QA → auditor sequencing, concrete file targets, and validation expectations.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- this plan file
- any final architecture/decision docs that become the source of truth

**Status:** ⏳ Pending discussion

**Results:** Blocked on definition work.

---

## Current Discussion Direction

Derrick redirected the work to start from the **data shapes first**.

The immediate design focus is:

- define the durable data shapes for `Song`, `Routine`, `Chart Variant`, and `Workout`
- model the workout-creator perspective first
- derive package authoring/editing/validation responsibilities only after those records are clear

Current workout-creator goals called out explicitly:

- pick songs
- pick difficulty levels: `easy`, `medium`, `hard`, `pro`
- pick gameplay features: `boxing`, `flow`, `dance`, `step`
- pick a default background scene at the workout level
- attach pre-workout coaching videos
- attach post-workout coaching videos
- attach workout-level coaching media/overlay structure for the workout experience

## Current agreed direction

From Derrick's review on 2026-04-23, the current direction is:

- all primary ids (`songId`, `routineId`, `chartId`, `workoutId`, `authorId`, `coachId`) should be UIDs
- naming should stay consistent across shapes using `*Id` + `*Name` pairs where applicable:
  - `songId`, `songName`
  - `routineId`, `routineName`
  - `chartId`, `chartName`
  - `workoutId`, `workoutName`
- use `chart` instead of `chart variant` as the cleaner durable term for the playable authored slice
- `Song` should not store athlete/device-specific timing offset like `offsetMs`
- `Routine` should stay lean:
  - keep `routineId`, `routineName`, `songId`, `mode`, `authorId`, `authorName`, and `charts`
  - remove `intensity`, `trainingFocus`, and presentation defaults/preferred views from the durable routine shape
- `Chart` should not own mode-global tuning like hit windows; those belong in feature/mode rules rather than per-chart authored data
- `Workout` should:
  - use `workoutName`
  - use `description` instead of `goal`
  - derive total runtime from referenced song durations rather than storing `targetDurationMin`
  - keep `coachId` as a UID and also carry `coachName`
- workout selections should resolve to exact UIDs
- default background scene selection is workout-level
- coaching is workout-level, and workouts should contain coaching overlay entries keyed to each selected song/chart UID
- `Routine` means `song + mode`, not `song + mode + choreography edition/style`

## Emerging storage / retrieval direction

After locking the core data-shape direction, Derrick proposed the following storage preferences for the next discussion phase:

- prefer YAML over JSON for authored durable records so comments are possible
- prefer copied package contents over cross-package references because the packages will be easier to reason about and debug
- use Option B for package layout: keep `workout.yaml` separate from the other YAML files early so large chart data does not bloat one giant file
- `workout.yaml` should contain the workout data shape plus manifest/version concepts such as schema/package versioning and creation-tool version info
- use a SQLite database at the root of the workouts folder on disk as the searchable installed-workouts index
- `workouts.db` should point at the installed `workout.yaml` files and denormalize the workout metadata needed for search/query/filter/tag browsing
- Godot can query that SQLite index to discover currently installed workouts
- the same SQLite concept might also be used as a low-scope online catalog snapshot that gets downloaded locally and queried client-side instead of requiring a full API first

These are promising direction signals, but they still need design pressure-testing before they become canonical architecture.

## Open Questions To Resolve

1. What is the smallest useful day-one shape of a `Song` from the workout creator's perspective versus from the runtime/content-contract perspective?
2. Given the new discussion, should authored records be canonically YAML while the searchable installed catalog is canonically SQLite?
3. If manifest and workout data are combined, what exact version fields must the combined file carry?
4. What should the root on-disk package layout be for copied/self-contained workout packages?
5. What exact rows/tables should the root SQLite index contain versus what should remain only inside package YAML files?
6. For the online-catalog idea, what scale limits or sync/integrity issues would make a downloaded SQLite snapshot insufficient?
7. After the four core shapes and storage rules are defined, what is the first package/install/discovery workflow we want to support end to end?

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Reframed the work from premature implementation into the correct definition phase, then documented today's agreed direction for both the core data shapes and the first storage/discovery draft.

Specific outputs landed so far:
- updated `aerobeat-docs/docs/architecture/content-model.md` to reflect:
  - `Song -> Routine -> Chart -> Workout`
  - consistent `*Id` + `*Name` naming
  - lean `Routine` ownership
  - workout-owned coaching overlays
- updated `aerobeat-docs/docs/gdd/glossary/terms.md` to replace `Chart Variant` with `Chart`
- created draft storage/discovery doc:
  - `aerobeat-docs/docs/architecture/workout-package-storage-and-discovery.md`

**Reference Check:** Current plan still uses `REF-01` through `REF-04` as architectural background, but implementation remains intentionally blocked pending further definition of exact YAML fields, SQLite schema, and install/discovery behavior.

**Commits:**
- Pending land-the-plane commit/push.

**Lessons Learned:** Repo shape is not the same thing as repo purpose. We need the purpose, data shapes, and storage/discovery model nailed down before we tell coders to build anything.

---

*Completed on 2026-04-23*
