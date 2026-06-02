# AeroBeat Content Core Downscope Alignment

**Date:** 2026-05-01  
**Status:** Stale  
**Agent:** Chip 🐱‍💻

---

## Goal

Align `aerobeat-content-core` with the newly downscoped AeroBeat v1 contract so this repo no longer encodes removed gameplay/package assumptions.

---

## Overview

With `aerobeat-docs` and `aerobeat-tool-content-authoring` now aligned, `aerobeat-content-core` is the next high-risk contract surface in the AeroBeat polyrepo. This repo likely defines shared content/domain concepts that downstream tooling and gameplay code will treat as authoritative, so stale assumptions here can keep reintroducing removed scope even after docs and validators have been cleaned up.

This slice is about truth alignment, not broad redesign. The approved v1 shape is now: `boxing` and `flow` only as official gameplay features; camera-first official gameplay input; workout packages keep songs/charts/sets/workouts/coaching/environments; workout-package `assets` and `assetSelections` are removed as active authored package concepts; internal AeroBeat assets still exist product-side but not as workout-package subsets.

The repo-local audit should identify any surviving constants, enums, examples, docs, or tests that still treat `dance`, `step`, package `assets/`, or `assetSelections` as active contract truth. Then the coder pass should realign only the touched contract surfaces and keep the loop tight.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Active plan for this repo-local cleanup slice | `.plans/2026-05-01-aerobeat-content-core-downscope-alignment.md` |
| `REF-02` | Updated AeroBeat docs source of truth | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs` |
| `REF-03` | Parent coordination plan and matrix | `/home/derrick/.openclaw/workspace/projects/openclaw-chip/.plans/2026-05-01-aerobeat-polyrepo-downscope-audit.md` |
| `REF-04` | Recently aligned authoring tool contract surface | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-tool-content-authoring` |

---

## Tasks

### Task 1: Audit `aerobeat-content-core` for stale downscope assumptions

**Bead ID:** `oc-v6l`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Audit this repo against the updated docs and the newly aligned authoring tool. Identify stale content-core assumptions such as active `dance`/`step` feature truth, package `assets/`, `assetSelections`, or any examples/docs/tests/constants that still encode the broader pre-downscope package model. Do not edit yet; produce an execution-ready list.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-content-core-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ✅ Complete

**Results:** Completed the repo-local content-core stale-contract audit. Main findings: `dance` and `step` are still canonical-valid features; the repo still encodes an older routine + workout-step package model instead of the current set-centered package model; package manifest/schema/constants/fixtures/tests still assume `routines/` and workout `steps[]`; and workout/coaching/environment semantics diverge sharply from the updated docs and the newly aligned authoring tool. Derrick approved the key architectural decision for this slice: `routine` should be fully removed as canonical truth and replaced with `set` everywhere this repo touches.

---

### Task 2: Apply the repo cleanup and contract alignment

**Bead ID:** `oc-jk6`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** After the audit/action list is approved, update this repo so its docs, constants/contracts, examples, and tests match the downscoped AeroBeat v1 contract. Commit and push by default.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-content-core-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ✅ Complete

**Results:** Applied the downscope contract alignment. The coder pass removed routine-era canonical truth from active contracts/validation/fixtures/tests, restricted canonical features to `boxing` and `flow`, added canonical set/coach/environment support, rewrote workout semantics around `setOrder`, rebuilt fixtures and tests around the set-centered package model, and updated the README to match the implemented contract. Validation passed via `godot --headless --path .testbed --script res://../tests/run_contract_tests.gd`, and the changes were committed/pushed as `29e2830` (`Align content-core with downscoped v1 contract`). The only nearby follow-up noted is naming debt: `WorkoutStep` / `ResolvedWorkoutStep` filenames remain even though their semantics are now set-centered.

---

### Task 3: QA and audit the alignment

**Bead ID:** `oc-dod` (QA), `oc-16n` (Auditor)  
**SubAgent:** `primary`  
**Role:** `qa` then `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Independently verify that this repo no longer presents removed gameplay/package concepts as active contract truth and stays aligned with docs + tool-content-authoring.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-content-core-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ⏳ In Progress

**Results:** QA pass completed with no fixes required and recommended auditor handoff. QA independently confirmed that canonical features are now restricted to `boxing` and `flow`, `dance` and `step` are rejected, package truth is set-centered (`songs/charts/sets/workouts/coaches/environments`), legacy manifest fields `routines`, `assets`, and `assetSelections` are explicitly forbidden, workout semantics are `setOrder`-based, and fixtures/README now reflect the new contract. Full repo validation passed again via `godot --headless --path .testbed --script res://../tests/run_contract_tests.gd`.

---

### Task 4: Clean up residual step-era naming debt

**Bead ID:** `oc-l34` (Coder), `oc-r6f` (QA), `oc-bxj` (Auditor)  
**SubAgent:** `primary`  
**Role:** `coder` then `qa` then `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Rename residual `WorkoutStep` / `ResolvedWorkoutStep` naming to truthful set-centered terms now that the contract semantics are already set-centered. Keep the cleanup scoped to naming parity across code/tests/docs and verify behavior still passes.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `data_types/`
- `interfaces/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-content-core-downscope-alignment.md`
- `data_types/**`
- `interfaces/**`
- `tests/**`

**Status:** ⏳ In Progress

**Results:** Follow-up naming cleanup slice requested by Derrick before moving on to `aerobeat-feature-core`. Coder pass completed: residual helper surfaces were renamed from step-era names to set-centered names, including `data_types/workout_step.gd` → `data_types/workout_set.gd`, `WorkoutStep` → `WorkoutSet`, `data_types/resolved_workout_step.gd` → `data_types/resolved_workout_set.gd`, `ResolvedWorkoutStep` → `ResolvedWorkoutSet`, and `tests/test_workout_step_contract.gd` → `tests/test_workout_set_contract.gd`. Imports/references/README text were updated, and `godot --headless --path .testbed --script res://../tests/run_contract_tests.gd` passed. Changes were committed/pushed as `4487784` (`Rename workout step helpers to set-centered terms`). QA then re-ran the full contract suite with no fixes needed and confirmed the active helper/type/test surfaces now use set-centered naming where intended. Broader serialized/API-facing names like the resolved payload field `steps`, `stepId`, and `resolved_workout_step_*` error codes were intentionally left alone because changing them would be a larger contract/API slice, not just naming parity.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Landed the core contract downscope alignment and then opened a small follow-up slice to remove residual step-era naming debt before advancing to the next repo.

**Reference Check:** Core contract alignment is complete; naming cleanup follow-up is now in progress.

**Commits:**
- `29e2830` - Align content-core with downscoped v1 contract
- `Pending` - Rename residual set-centered naming debt

**Lessons Learned:** After aligning source docs and validator tooling, the next most important surfaces are shared content/contract repos that can silently reintroduce old worldview assumptions. Once semantics are corrected, small naming debt should be cleaned promptly so future work doesn’t drag stale language forward.

---

*Completed on 2026-05-01*