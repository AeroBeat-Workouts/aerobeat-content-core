# AeroBeat Flow v1 Shared Contract Freeze

**Date:** 2026-07-20  
**Status:** In Progress  
**Last Updated:** 2026-07-20 15:10 EDT  
**Blocked Reason:** None  
**Agent:** `pico`

---

## Goal

Land the approved shared Flow v1 authored contract in `aerobeat-content-core` so downstream BeatSaver conversion can emit canonical `note`, `burst`, `bomb`, `obstacle`, and `arc` objects without inventing repo-local truth.

---

## Overview

Derrick approved the full Flow v1 authored contract freeze, including `angleOffset` on `note`, direct occupancy-based `obstacle` objects, and source-semantic `arc` objects with preserved curve multipliers, mid-anchor mode, and optional note-linkage refs. That approval clears the architecture gate that had kept non-burst Flow conversion out of the shared contract.

This repo owns the durable content contract and validation truth, so the next slice belongs here first. The work should add the shared data shapes and validation rules, keep existing `burst` behavior truthful, and avoid baking gameplay scoring/runtime policy into the contract. After the shared contract lands and is verified here, follow-on work can expand `aerobeat-tool-content-authoring` to emit the new objects.

Execution stays on one bead through coder -> QA -> auditor. The auditor should close the bead only if the shared contract and validation surface really match the approved Flow freeze and remain lane-correct for downstream consumers.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Active parent converter-foundation plan with approval trail | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-tool-content-authoring/.plans/2026-07-20-beatsaver-flow-boxing-converter-foundation.md` |
| `REF-02` | Flow v1 BeatSaver conversion architecture | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs/docs/architecture/beatsaver-flow-v1-conversion.md` |
| `REF-03` | Shared content-core contract boundary | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-content-core/README.md` |
| `REF-04` | Approved Flow v1 contract freeze from Derrick | `chat approval on 2026-07-20 14:58 EDT` |

---

## Tasks

### Task 1: Land shared Flow contract + validation

**Bead ID:** `aerobeat-content-core-f95`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Implement the approved Flow v1 shared authored contract in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-content-core` against bead `aerobeat-content-core-f95`. Claim it on start with `bd update aerobeat-content-core-f95 --status in_progress --json`. Use the approved freeze exactly: canonical Flow object types are `note`, `burst`, `bomb`, `obstacle`, and `arc`. `note` must support `start`, `hand`, `placement`, `requiresDirection`, conditional `direction`, and optional `angleOffset`. `bomb` uses `start` and `placement`. `obstacle` uses `start`, `end`, and `cells`. `arc` must preserve source-semantic BeatSaver fields: `start`, `end`, `hand`, `startPlacement`, `endPlacement`, `startDirection`, `endDirection`, `headCurveMultiplier`, `tailCurveMultiplier`, `midAnchorMode`, and optional `startNoteRef` / `endNoteRef`. Keep `burst` truthful to the existing frozen contract. Update shared validators/tests/fixtures/docs as needed, run all relevant repo-local validation, commit, and push to `main` by default before handoff. Do not close the bead; report exact files changed, validation evidence, and any contract caveats discovered.  

**Folders Created/Deleted/Modified:**
- `data_types/`
- `validators/`
- `tests/`
- `fixtures/`

**Files Created/Deleted/Modified:**
- `data_types/chart.gd`
- `tests/test_chart_event_contract.gd`
- `README.md`

**Status:** ✅ Complete  

**Results:** Coder landed the approved shared Flow v1 contract and pushed commit `18db07e` (`Freeze Flow v1 shared authored contract`). `data_types/chart.gd` now validates the canonical Flow object types `note`, `burst`, `bomb`, `obstacle`, and `arc` with the approved field rules, including `note.angleOffset`, conditional `direction`, `obstacle.cells`, and source-semantic `arc` fields plus optional `startNoteRef` / `endNoteRef`. `tests/test_chart_event_contract.gd` now covers valid and invalid cases for the full frozen Flow object set, and `README.md` was updated to reflect the broadened shared contract truth. Repo-local validation passed via `godot --headless --path .testbed --script res://../tests/run_contract_tests.gd`, and `git diff --check` passed cleanly. References validated: `REF-01`, `REF-02`, `REF-03`, `REF-04`.

---

### Task 2: QA shared Flow contract

**Bead ID:** `aerobeat-content-core-f95`  
**SubAgent:** `primary` (for `qa`)  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Perform QA on bead `aerobeat-content-core-f95` in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-content-core` after coder handoff. Verify the shared contract and validation surface really match the approved Flow freeze, especially `note.angleOffset`, `obstacle` occupied-cell semantics, and the full source-semantic `arc` fields including optional note-linkage refs. Run the strongest repo-local validation available and inspect fixtures/tests to ensure they enforce the approved contract instead of masking drift. Do not self-implement missing work. Do not close the bead; leave it ready for audit with exact verification evidence.  

**Folders Created/Deleted/Modified:**
- verification-only if needed

**Files Created/Deleted/Modified:**
- verification notes only if needed

**Status:** ✅ Complete  

**Results:** QA verified that the shared validator implementation matches the approved Flow freeze for `note`, `burst`, `bomb`, `obstacle`, and `arc`, and that repo boundaries stayed clean. Repo-local validation passed again via `godot --headless --path .testbed --script res://../tests/run_contract_tests.gd`, `git diff --check 18db07e^ 18db07e` passed cleanly, and manual headless spot checks confirmed several newly added negative-path validator branches behave correctly (`flow_note_missing_direction`, `flow_note_invalid_requires_direction`, `flow_obstacle_missing_cells`, `flow_obstacle_empty_cells`, `flow_arc_invalid_end_note_ref`, etc.). Non-blocking caution: committed automated coverage is good but not fully exhaustive for every new negative-path branch yet, so some regression protection still depends on the current validator correctness rather than direct checked-in assertions. References validated: `REF-02`, `REF-03`, `REF-04`.

---

### Task 3: Audit shared Flow contract

**Bead ID:** `aerobeat-content-core-f95`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Independently audit bead `aerobeat-content-core-f95` in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-content-core`. Verify the shared contract belongs in this repo, the implemented Flow object shapes and validators match the approved freeze exactly, and the evidence is strong enough for downstream converter expansion. If the work passes, close the bead with `bd close aerobeat-content-core-f95 --reason "Flow v1 shared contract freeze implemented, verified, and audited" --json`. If it fails, do not close it; report the exact gap with evidence.  

**Folders Created/Deleted/Modified:**
- audit-only if needed

**Files Created/Deleted/Modified:**
- audit notes only if needed

**Status:** ✅ Complete  

**Results:** Auditor independently verified the repo boundary, approved object shapes, validator truth, and validation evidence, then closed bead `aerobeat-content-core-f95` with reason `Flow v1 shared contract freeze implemented, verified, and audited`. Audit confirmed the Flow allowed types are exactly `note`, `burst`, `bomb`, `obstacle`, and `arc`; that `angleOffset`, obstacle occupancy `cells`, source-semantic arc fields, and optional `startNoteRef` / `endNoteRef` are all implemented truthfully; and that the work belongs in `aerobeat-content-core` before downstream converter expansion. Remaining non-blocking risks: committed negative-path coverage is still not exhaustive for every validator branch, and the validator remains requirement-focused rather than a full unknown-field rejection whitelist.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** The shared-contract repo now contains the approved Flow v1 authored object validation surface, and the bead was implemented, verified, audited, and closed.

**Reference Check:** `REF-04` approved the full Flow freeze, and the landed contract was implemented and independently verified against `REF-02` and `REF-03`. The remaining cautions are non-blocking coverage/strictness notes, not contract-truth failures.

**Commits:**
- `18db07e` - Freeze Flow v1 shared authored contract

**Lessons Learned:** The converter repo could only go so far with Flow until the shared contract was frozen; now that the contract truth has landed in content-core, the next truthful seam is downstream converter expansion against the new shared object shapes.

---

*Completed on 2026-07-20*
