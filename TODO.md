# Mars Orbital Propagator - TODO List

## Project Tasks

### 1. Foundation Module
- [~] **1.1** Create `mars_constants.pro` with Mars physical constants
  - **Acceptance**: Function returns structure with μ, r_eq, r_pol, f, e2, omega_mars, ref_epoch

### 2. Core Mathematical Solvers
- [ ] **2.1** Create `kepler_solver.pro` with Newton-Raphson solver for Kepler's equation
  - **Acceptance**: Solves M = Ecc - e·sin(Ecc) and converges within 50 iterations for e=[0, 0.5, 0.9, 0.99]

- [ ] **2.2** Create `anomaly_conversions.pro` with Ecc ↔ ν conversion functions
  - **Acceptance**: Round-trip conversion (Ecc → ν → Ecc) returns original value within 1e-10 radians

### 3. Coordinate Transformation Module
- [ ] **3.1** Create `coordinate_transforms.pro` with perifocal position calculator
  - **Acceptance**: Function returns correct r_pqw and v_pqw for given (a, e, ν, μ)

- [ ] **3.2** Add perifocal to MCI transformation to `coordinate_transforms.pro`
  - **Acceptance**: Rotation matrix is orthogonal (R·R^T = I) and transforms vectors correctly

### 4. Geodetic Conversion Module
- [ ] **4.1** Create `mci_to_lla.pro` with MCI to Mars-fixed rotation
  - **Acceptance**: Correctly rotates MCI coordinates by θ = ω_Mars·(t - t_ref) about Z-axis

- [ ] **4.2** Add iterative geodetic latitude calculator to `mci_to_lla.pro`
  - **Acceptance**: Converges to geodetic latitude within 1e-8 degrees in < 10 iterations

- [ ] **4.3** Add longitude and altitude calculations to `mci_to_lla.pro`
  - **Acceptance**: Round-trip MCI → LLA → MCI returns original position within 0.1 meters

### 5. Main Propagator
- [ ] **5.1** Create `orbital_propagator.pro` integrating all modules
  - **Acceptance**: Accepts Keplerian elements and time array, returns structure with r_mci, v_mci, lon, lat, alt, nu, Ecc

### 6. Validation & Testing
- [ ] **6.1** Create `test_orbit_propagation.pro` with circular equatorial orbit test
  - **Acceptance**: Constant altitude ± 0.01 km, latitude ≈ 0° ± 0.01°, linear longitude change

- [ ] **6.2** Add polar orbit test to `test_orbit_propagation.pro`
  - **Acceptance**: Latitude ranges from -90° to +90°

- [ ] **6.3** Add eccentric orbit test to `test_orbit_propagation.pro`
  - **Acceptance**: Periapsis and apoapsis altitudes match theoretical values within 0.1 km

- [ ] **6.4** Add energy conservation test to `test_orbit_propagation.pro`
  - **Acceptance**: Orbital energy E = -μ/(2a) remains constant (ΔE/E < 1e-12)

- [ ] **6.5** Add angular momentum conservation test to `test_orbit_propagation.pro`
  - **Acceptance**: |h| = |r × v| remains constant (Δh/h < 1e-12)

- [ ] **6.6** Add Kepler solver edge cases test to `test_orbit_propagation.pro`
  - **Acceptance**: Solver converges for e = [0, 0.1, 0.5, 0.9, 0.99] with error < 1e-10

### 7. Documentation
- [ ] **7.1** Create `README.md` with project overview and usage examples
  - **Acceptance**: Includes installation, example usage code, and description of all modules

---

## Progress Summary
- Total tasks: 14
- Completed: 0
- In progress: 1
- Not started: 13

## Notes
- All angle inputs/outputs should be documented with units (radians vs degrees)
- Use double precision throughout: `variable = 0.0d0`
- Variable naming: Use "Ecc" for Eccentric Anomaly
- Validate inputs: a > 0, 0 ≤ e < 1, 0 ≤ i ≤ π
