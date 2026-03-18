# Mars Orbital Propagator - Project Status

**Date:** 2026-02-18
**Repository:** /Users/mwolff/processing_local/claude/orbit/satellite_position

## Current State

### Completed Tasks (3/14 - 21.4%)

1. **sp_mars_constants.pro** ✓
   - Defines Mars physical constants (μ, radii, flattening, rotation rate)
   - Unit test: 14/14 tests passing
   - All values use double precision

2. **kepler_solver.pro** ✓
   - Newton-Raphson solver for Kepler's equation: M = Ecc - e·sin(Ecc)
   - Unit test: 10/10 tests passing
   - Converges in 4-6 iterations for e ∈ [0, 0.99]
   - Accuracy: error < 10⁻¹⁰ radians

3. **anomaly_conversions.pro** ✓
   - Functions: ecc_to_true_anomaly(), true_to_ecc_anomaly()
   - Unit test: 10/10 tests passing
   - Round-trip conversion accuracy: machine precision (~10⁻¹⁶)

### Files in Repository

- `sp_mars_constants.pro` - Mars physical constants
- `kepler_solver.pro` - Kepler equation solver
- `anomaly_conversions.pro` - Anomaly conversion functions
- `test_sp_mars_constants.pro` - Unit tests for constants
- `test_kepler_solver.pro` - Unit tests for Kepler solver
- `test_anomaly_conversions.pro` - Unit tests for anomaly conversions
- `run_test_kepler.pro` - Batch runner for Kepler tests
- `run_test_anomaly.pro` - Batch runner for anomaly tests
- `TODO.md` - Task tracking
- `debug_test.pro` - Debugging helper

### Recent Commits (most recent first)

```
e618613 Fix angle wrapping in test 8
fa89f12 Fix test cases in test_anomaly_conversions.pro
f9ce970 Complete task 2.2: Create anomaly_conversions.pro with unit test
58807c8 Mark task 2.2 as in progress
c4c34b3 Complete task 2.1: Create kepler_solver.pro with unit test
309186f Mark task 2.1 as in progress
3e6cba2 Add unit test for sp_mars_constants.pro
f918442 Add unit test requirements to each implementation task
cf3a413 Complete task 1.1: Create sp_mars_constants.pro
52b52b2 Mark task 1.1 as in progress
c07369e Add project TODO list
```

## Next Steps

### Immediate Next Task: **3.1**
Create `coordinate_transforms.pro` with perifocal position calculator and unit test

**Requirements:**
- Function: `calculate_perifocal_position(a, e, nu, mu)`
- Inputs: semi-major axis, eccentricity, true anomaly, gravitational parameter
- Outputs: position and velocity vectors in perifocal frame [P, Q, W]
- Formulas:
  - r = a(1-e²) / (1 + e·cos(ν))
  - r_pqw = [r·cos(ν), r·sin(ν), 0]
  - v_pqw = sqrt(μ/p) · [-sin(ν), e+cos(ν), 0] where p = a(1-e²)
- Unit test must verify correctness for circular and eccentric orbits

### Remaining Tasks (11)

**Coordinate Transforms (2 tasks)**
- 3.1: Perifocal position calculator
- 3.2: Perifocal to MCI transformation

**Geodetic Conversion (3 tasks)**
- 4.1: MCI to Mars-fixed rotation
- 4.2: Iterative geodetic latitude calculator
- 4.3: Longitude and altitude calculations

**Main Propagator (1 task)**
- 5.1: Orbital propagator integrating all modules

**Integration Tests (5 tasks)**
- 6.1: Circular equatorial orbit test
- 6.2: Polar orbit test
- 6.3: Eccentric orbit test
- 6.4: Energy conservation test
- 6.5: Angular momentum conservation test
- 6.6: Kepler solver edge cases

**Documentation (1 task)**
- 7.1: README.md with usage examples

## Technical Notes

- Language: IDL (Interactive Data Language)
- IDL Location: `/Applications/NV5/idl92/bin/idl`
- Planet: Mars (μ = 42828.37 km³/s²)
- Variable Convention: Use "Ecc" for Eccentric Anomaly
- Precision: Double precision throughout (0.0d0)
- Coordinate Frames: Perifocal → MCI → Longitude/Latitude/Altitude
- All unit tests passing with high accuracy (typically < 10⁻¹⁰)

## Project Goal

Build a complete orbital propagator for Mars satellites that:
1. Takes 6 Keplerian elements (a, e, i, Ω, ω, M₀) as input
2. Propagates satellite position forward in time
3. Outputs positions in both MCI (inertial) and LLA (geodetic) coordinates
