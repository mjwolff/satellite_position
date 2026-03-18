# Mars Orbital Propagator - TODO List

## Project Tasks

### 1. Foundation Module
- [x] **1.1** Create `mars_constants.pro` with Mars physical constants and unit test (2026-02-18)
  - **Acceptance**: Function returns structure with μ, r_eq, r_pol, f, e2, omega_mars, ref_epoch; unit test verifies all values

### 2. Core Mathematical Solvers
- [x] **2.1** Create `kepler_solver.pro` with Newton-Raphson solver and unit test (2026-02-18)
  - **Acceptance**: Solves M = Ecc - e·sin(Ecc) for e=[0, 0.5, 0.9, 0.99]; unit test verifies convergence within 50 iterations and error < 1e-10

- [x] **2.2** Create `anomaly_conversions.pro` with Ecc ↔ ν conversion functions and unit test (2026-02-18)
  - **Acceptance**: Unit test verifies round-trip conversion (Ecc → ν → Ecc) returns original value within 1e-10 radians

### 3. Coordinate Transformation Module
- [x] **3.1** Create `coordinate_transforms.pro` with perifocal position calculator and unit test (2026-02-18)
  - **Acceptance**: Unit test verifies correct r_pqw and v_pqw for known test cases (circular, eccentric orbits)

- [x] **3.2** Add perifocal to MCI transformation to `coordinate_transforms.pro` with unit test (2026-02-18)
  - **Acceptance**: Unit test verifies rotation matrix is orthogonal (R·R^T = I) and known vectors transform correctly

### 4. Geodetic Conversion Module
- [x] **4.1** Create `mci_to_lla.pro` with MCI to Mars-fixed rotation and unit test (2026-02-18)
  - **Acceptance**: Unit test verifies rotation by θ = ω_Mars·(t - t_ref) about Z-axis for known test vectors

- [x] **4.2** Add iterative geodetic latitude calculator to `mci_to_lla.pro` with unit test (2026-02-18)
  - **Acceptance**: Unit test verifies convergence to geodetic latitude within 1e-8 degrees in < 10 iterations

- [x] **4.3** Add longitude and altitude calculations to `mci_to_lla.pro` with unit test (2026-02-18)
  - **Acceptance**: Unit test verifies round-trip MCI → LLA → MCI returns original position within 0.1 meters

### 5. Main Propagator
- [x] **5.1** Create `propagate_orbit.pro` integrating all modules with unit test (2026-02-18)
  - **Acceptance**: Unit test verifies propagation for simple circular orbit returns expected position; all output fields present

### 6. Validation & Testing
- [x] **6.1** Create `test_orbit_propagation.pro` with circular equatorial orbit test (2026-02-18)
  - **Acceptance**: Constant altitude ± 0.01 km, latitude ≈ 0° ± 0.01°, linear longitude change

- [x] **6.2** Add polar orbit test to `test_orbit_propagation.pro` (2026-02-18)
  - **Acceptance**: Latitude ranges from -90° to +90°

- [x] **6.3** Add eccentric orbit test to `test_orbit_propagation.pro` (2026-02-18)
  - **Acceptance**: Periapsis and apoapsis altitudes match theoretical values within 0.1 km

- [x] **6.4** Add energy conservation test to `test_orbit_propagation.pro` (2026-02-18)
  - **Acceptance**: Orbital energy E = -μ/(2a) remains constant (ΔE/E < 1e-12)

- [x] **6.5** Add angular momentum conservation test to `test_orbit_propagation.pro` (2026-02-18)
  - **Acceptance**: |h| = |r × v| remains constant (Δh/h < 1e-12)

- [x] **6.6** Add Kepler solver edge cases test to `test_orbit_propagation.pro` (2026-02-18)
  - **Acceptance**: Solver converges for e = [0, 0.1, 0.5, 0.9, 0.99] with error < 1e-10

### 7. Documentation
- [x] **7.1** Create `README.md` with project overview and usage examples (2026-02-18)
  - **Acceptance**: Includes installation, example usage code, and description of all modules

---

## Progress Summary
- Total tasks: 14
- Completed: 14
- In progress: 0
- Not started: 0

**ALL TASKS COMPLETED! ✓**

## Notes
- All angle inputs/outputs should be documented with units (radians vs degrees)
- Use double precision throughout: `variable = 0.0d0`
- Variable naming: Use "Ecc" for Eccentric Anomaly
- Validate inputs: a > 0, 0 ≤ e < 1, 0 ≤ i ≤ π
- Unit tests: Create `test_<module_name>.pro` for each module with test procedures that print PASS/FAIL results
- Integration tests (6.1-6.6): End-to-end validation of complete orbital propagation system
