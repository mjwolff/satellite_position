# Changelog

## 2026-03-20

### Added
- `CHANGELOG.md` — this file.

### Fixed
- **IDL column-major indexing bug in rotation matrix construction** (`src/sp_perifocal_to_mci.pro`, `src/sp_mci_to_perifocal.pro`)
  - In IDL, `A[i,j]` means column `i`, row `j`. Both rotation functions were filling matrix columns when intending to fill rows, causing each function to apply the transpose of the intended rotation (i.e., the inverse transform). Fixed by swapping indices on all off-diagonal array assignments.
  - The bug was masked by the round-trip test since the two transposed transforms cancelled each other. Absolute rotation direction tests (e.g. pure RAAN rotation) exposed the error.

### Changed
- **`sp_` namespace prefix applied to all files in `tests/`** — renames, `PRO`/`FUNCTION` declarations, internal `.compile` directives, and docstring calling sequences updated:
  - `test_anomaly_conversions.pro` → `sp_test_anomaly_conversions.pro`
  - `test_coordinate_transforms.pro` → `sp_test_coordinate_transforms.pro`
  - `test_kepler_solver.pro` → `sp_test_kepler_solver.pro`
  - `test_mars_constants.pro` → `sp_test_mars_constants.pro`
  - `test_mci_to_lla.pro` → `sp_test_mci_to_lla.pro`
  - `test_orbit_propagation.pro` → `sp_test_orbit_propagation.pro`
  - `test_propagate_orbit.pro` → `sp_test_propagate_orbit.pro`
  - `test_subsolar_latitude.pro` → `sp_test_subsolar_latitude.pro`
  - `run_test_kepler.pro` → `sp_run_test_kepler.pro`
  - `run_test_anomaly.pro` → `sp_run_test_anomaly.pro`
- **`sp_` namespace prefix applied to root-level test/runner scripts:**
  - `run_all_tests.pro` → `sp_run_all_tests.pro`
  - `test_install.pro` → `sp_test_install.pro`
- **`README.md`** — updated all test calling sequences and directory tree to reflect renamed files.
