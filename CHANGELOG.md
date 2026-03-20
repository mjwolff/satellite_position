# Changelog

## 2026-03-20

### Added
- `CHANGELOG.md` — this file.

### Fixed
- **Single-precision `!DTOR`/`!RADEG` system variables** (`src/sp_mci_to_lla.pro`, `src/sp_lla_to_mci.pro`, `src/sp_mars_constants.pro`, `src/sp_calculate_subsolar_latitude.pro`, `src/sp_propagate_orbit.pro`, `src/sp_calculate_subsolar_longitude.pro`)
  - IDL's `!DTOR` and `!RADEG` are float32 constants promoted to float64. Their product is `0.99999994`, not `1.0`, introducing ~1.6e-8 rad (~0.18 m) error per radian–degree–radian round-trip. Replaced `!DTOR` with `(!DPI/180.0d0)` and `!RADEG` with `(180.0d0/!DPI)` in all functional code. Round-trip error reduced from 0.18 m to 4.5e-10 m.
- **Geodetic altitude mismatch in iterative convergence** (`src/sp_calculate_geodetic_latitude.pro`)
  - On convergence, the returned altitude `h` was computed from `lat` (the second-to-last iteration) while `lat_new` (the final iteration) was returned as latitude. Fixed by recomputing `h` from `lat_new` before returning, ensuring the `(lat, h)` pair is internally consistent.
- **Wrong test expectation for 90° Mars rotation** (`tests/sp_test_mci_to_lla.pro`)
  - The test expected `[0, +10000, 0]` after a 90° Mars rotation of `[10000, 0, 0]`, but the correct passive-frame result is `[0, -10000, 0]`. Corrected the expected value.
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
