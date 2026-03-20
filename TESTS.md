# Test Suite Documentation

This document describes the purpose and expected values for every test in the `satellite_position` test suite. The suite covers the full orbital mechanics pipeline from Kepler's equation through coordinate transforms to ground-track computation for Mars orbiters. Expected values are grounded in standard astrodynamics references (Vallado 2013, Prussing & Conway 1993) and Mars planetary constants from the NASA Mars Fact Sheet and IAU/IAG 2015. All 8 suites (101 tests total) must pass before merging changes.

## Running the tests

```
idl -e "sp_run_all_tests"      # all 8 suites + tabular summary
idl sp_run_all_tests.pro       # equivalent batch form
idl -e "sp_test_kepler_solver" # individual suite
```

`sp_run_all_tests` configures the IDL path automatically; no manual `.pth` setup is required.

---

## 1. Mars Constants (`sp_test_mars_constants`)

**Function under test:** `sp_mars_constants()`

**Description:** Verifies that the constants structure contains all required fields with correct data types and physically reasonable values.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1–9 | Required fields present | `mu`, `r_eq`, `r_pol`, `f`, `e2`, `omega_mars`, `obliquity`, `ref_epoch` all exist |
| 10 | μ in range | 42828.37 km³/s² — NASA Mars Fact Sheet |
| 11 | r_eq > r_pol | Oblate spheroid — IAU/IAG 2015 |
| 12 | f = (r_eq − r_pol)/r_eq | Derived identity — Vallado §3.2 |
| 13 | e² = f(2−f) | Derived identity — Vallado §3.2 |
| 14 | ω_Mars in range | 7.088218×10⁻⁵ rad/s — IAU/IAG 2015 |
| 15 | obliquity in range | 25.19° — NASA Mars Fact Sheet / IAU 2015 |
| 16 | All fields float64 | Implementation contract |

**Tolerances:** Exact equality for structural checks; numeric range checks use physically motivated bounds.

---

## 2. Kepler Solver (`sp_test_kepler_solver`)

**Function under test:** `sp_solve_kepler(M, e)`

**Description:** Verifies that the Newton–Raphson iteration solves Kepler's equation M = E − e·sin E to machine precision across a range of eccentricities and mean anomalies.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1 | Circular orbit e=0: E = M | Degenerate case — Vallado §2.2 |
| 2–5 | e = 0.1, 0.5, 0.9, 0.99 | Residual \|M_computed − M\| < 1e-10 rad — Kepler's equation |
| 6–8 | M = 0, π, 2π | Periapsis / apoapsis / full-orbit edge cases |
| 9 | Sweep e = [0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99] | Max residual < 2.3e-16 rad (machine epsilon) |
| 10 | e=0.7, M=π/3, tol=1e-12 | Residual < 1e-10 — Prussing & Conway §2 |

**Tolerances:** Residual in Kepler's equation < 1e-10 rad; sweep test targets machine epsilon (2.3e-16 rad).

---

## 3. Anomaly Conversions (`sp_test_anomaly_conversions`)

**Functions under test:** `sp_ecc_to_true_anomaly()`, `sp_true_to_ecc_anomaly()`

**Description:** Verifies invertibility and known analytical values of the eccentric ↔ true anomaly conversion.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1 | e=0: ν = E | Degenerate case — Vallado §2.2 |
| 2 | Round-trip E → ν → E, e=0.5 | Error < 1e-10 rad |
| 3 | Round-trip ν → E → ν, e=0.7 | Error < 3.4e-16 rad (machine epsilon) |
| 4–5 | Periapsis ν=E=0; apoapsis ν=E=π | Exact boundary values |
| 6 | e=0.5, E=60° → ν=90° | Analytical: tan(ν/2) = √((1+e)/(1−e))·tan(E/2) — Vallado eq. 2-16 |
| 7 | Sweep e = [0.1, 0.3, 0.5, 0.7, 0.9] | Max round-trip error < 1.1e-16 rad |
| 8 | ν = [0, π/2, π, 3π/2] full orbit sweep | Round-trip error = 0 |
| 9 | Symmetry: ν and −ν | E(−ν) = −E(ν) mod 2π |
| 10 | e=0.99 high precision | Round-trip error < 2.3e-16 rad |

**Tolerances:** Round-trip errors < 1e-10 rad in general; near-circular cases target machine epsilon.

---

## 4. Coordinate Transforms (`sp_test_coordinate_transforms`)

**Functions under test:** `sp_calculate_perifocal_position()`, `sp_perifocal_to_mci()`, `sp_mci_to_perifocal()`

**Description:** Verifies perifocal position/velocity magnitudes, orbital invariants, and rotation matrix correctness.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1–3 | Circular orbit ν=0: r=a, r=[a,0,0], v=[0,v_c,0] | v_c = √(μ/a) — Vallado §2.3 |
| 4–5 | Eccentric periapsis/apoapsis radii | r_peri = a(1−e), r_apo = a(1+e) — Vallado eq. 2-22 |
| 6 | r·v = 0 at periapsis/apoapsis | Orthogonality at apsides |
| 7 | Specific energy E = −μ/(2a) | Vis-viva equation — Vallado eq. 2-15 |
| 8 | Angular momentum h = √(μp) | p = a(1−e²) — Vallado eq. 2-19 |
| 9 | h in +W direction | Definition of perifocal frame — Vallado §2.3 |
| 10 | W-components zero in perifocal frame | Frame definition |
| 11 | Identity rotation (all angles 0) | R·R^T = I, position error < 1.8e-12 km |
| 12 | R·R^T = I (orthogonality) | Rotation matrix property — Vallado §2.6 |
| 13 | Magnitude preserved under rotation | Isometric property |
| 14 | Pure RAAN rotation → rotation about Z | R₃(Ω) definition — Vallado §2.6 |
| 15 | Polar orbit i=90°: r_pqw → r_mci | Analytical basis vector transform |

**Tolerances:** Position errors < 1.8e-12 km; energy/momentum relative errors < 1e-12.

---

## 5. MCI to LLA (`sp_test_mci_to_lla`)

**Functions under test:** `sp_mci_to_mars_fixed()`, `sp_mars_fixed_to_mci()`, `sp_calculate_geodetic_latitude()`, `sp_mci_to_lla()`, `sp_lla_to_mci()`

**Description:** Verifies time-dependent rotation to the Mars-fixed frame, the iterative geodetic latitude algorithm, and the full MCI ↔ LLA coordinate chain.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1 | Zero rotation at t=t_ref | Identity — Mars-fixed = MCI at reference epoch |
| 2–3 | 90°, 180° rotation | Passive rotation by ω_Mars·Δt — Vallado §3.4 |
| 4 | Z-component unchanged | Rotation about Z-axis |
| 5 | Magnitude preserved | Isometric |
| 6 | Round-trip MCI → fixed → MCI | Exact inverse |
| 7 | Non-zero t_ref | Rotation offset applied correctly |
| 8 | Full Mars sidereal day ≈ 24.623 h | 2π/ω_Mars — IAU/IAG 2015 |
| 9–11 | Geodetic lat at equator, N/S poles | Degenerate cases — Vallado §3.2 |
| 12 | Convergence < 10 iterations | Bowring iterative algorithm — Vallado §3.2 |
| 13 | Accuracy < 1e-8° for general point | Algorithm precision |
| 14 | On-surface: altitude ≈ 0 km | By construction |
| 15 | 45° latitude round-trip | Lat error < 1.6e-13°, alt error < 1.1e-11 km |
| 16 | MCI → LLA → MCI round-trip | Error < 0.1 m (4.5e-10 m achieved) |
| 17 | LLA in valid ranges | −180° ≤ lon ≤ 180°, −90° ≤ lat ≤ 90°, alt > 0 |
| 18 | Equatorial position lat ≈ 0° | Equatorial orbit in MCI → lat = 0 at t=0 |
| 19 | Multiple round-trips, different times | Max error < 4.5e-9 m |
| 20 | High altitude 10,000 km round-trip | Error < 0.1 m |

**Tolerances:** Round-trip position errors < 0.1 m; geodetic latitude errors < 1e-8°.

---

## 6. Subsolar Latitude (`sp_test_subsolar_latitude`)

**Function under test:** `sp_calculate_subsolar_latitude(Ls)`

**Description:** Verifies the analytical relationship subsolar_lat = obliquity · sin(Ls) at cardinal points, with the `/DEGREES` keyword, for specific angles, and for array input.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1–4 | Cardinal points Ls=0, π/2, π, 3π/2 (radians) | 0, +ε, 0, −ε where ε = obliquity — IAU 2015 |
| 5 | Cardinal points with /DEGREES keyword | Same values, max error < 1e-6° |
| 6–8 | Ls = 30°, 45°, 135° | obliquity·sin(Ls), tolerance 1e-8° |
| 9 | Custom obliquity 26° at Ls=90° | 26.0° exactly |
| 10 | Array input | Output size = input size |
| 11 | Output range over full cycle | \|lat\| ≤ obliquity everywhere |
| 12 | Ls=60° high precision | obliquity·√3/2, error < 1e-8 rad |
| 13 | Negative Ls: −90° = 270° | Periodicity |
| 14 | Ls > 360°: 450° = 90° | Periodicity |

**Tolerances:** < 1e-8° for degree-mode tests; < 1e-8 rad for radian-mode tests.

Reference: analytical formula valid for small obliquity — NASA Mars Fact Sheet.

---

## 7. Propagate Orbit, unit (`sp_test_propagate_orbit`)

**Function under test:** `sp_propagate_orbit()`

**Description:** Verifies output fields, single-step orbital mechanics, and conservation laws.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1 | All 12 output fields present | API contract |
| 2 | Circular orbit: constant radius | r = a throughout — circular orbit definition |
| 3 | Circular equatorial: lat = 0° | i = 0, equatorial plane |
| 4 | Mean anomaly increases monotonically | M(t) = M₀ + n·t, n = √(μ/a³) |
| 5 | Eccentric r_peri, r_apo | a(1−e), a(1+e) to 1 km — Vallado eq. 2-22 |
| 6 | Specific energy constant | ΔE/E < 1e-12 — vis-viva, Vallado eq. 2-15 |
| 7 | Scalar vs array consistency | Same result either way |
| 8 | Altitude > 0 km | Physically above surface |

**Tolerances:** Energy conservation relative error < 1e-12; apsidal distances to 1 km.

---

## 8. Orbit Propagation, integration (`sp_test_orbit_propagation`)

**Function under test:** `sp_propagate_orbit()` (end-to-end, 101-point trajectories)

**Description:** Verifies full propagation pipeline correctness using conservation laws and geometric properties over complete orbits.

| # | Description | Expected value / basis |
|---|-------------|------------------------|
| 1 | Circular equatorial: altitude variation < 0.01 km | Circular orbit definition |
| 2 | Circular equatorial: \|lat\| < 0.01° | i = 0 |
| 3 | Longitude change linear in time | Mars rotation + orbital motion; RMS residual < 1° |
| 4 | Polar orbit: lat range ⊂ [−90°, +90°] | i = 90°, sampled near poles |
| 5 | Eccentric orbit: apoapsis/periapsis alt ± 0.1 km | a=15000 km, e=0.5; t[50]=period/2 hits apoapsis exactly |
| 6 | Energy conservation ΔE/E < 1e-12 | Kepler two-body energy — Vallado §2.3 |
| 7 | Angular momentum Δh/h < 1e-12 | h = r × v conserved — Vallado §2.3 |
| 8 | Kepler residual < 1e-10 rad, e=[0…0.99] | Kepler's equation — Prussing & Conway §2 |

**Tolerances:** Energy and momentum relative errors < 1e-12; altitude variation < 0.01 km; Kepler residual < 1e-10 rad.

---

## References

```
[1] Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications,
    4th Ed. Microcosm Press.
[2] Prussing, J. E., & Conway, B. A. (1993). Orbital Mechanics.
    Oxford University Press.
[3] NASA Mars Fact Sheet.
    https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
[4] IAU/IAG Working Group on Cartographic Coordinates and Rotational
    Elements of Planets and Satellites (2015).
```
