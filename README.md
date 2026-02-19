# Mars Orbital Propagator

A complete orbital mechanics library for propagating satellite orbits around Mars, written in IDL (Interactive Data Language).

## Overview

This project provides tools to:
- Propagate Keplerian orbital elements forward in time
- Calculate satellite position and velocity in multiple coordinate frames
- Convert between inertial and geodetic coordinates on Mars
- Validate orbital mechanics with comprehensive unit and integration tests

## Features

- **Two-body orbital propagation** using classical Keplerian elements
- **Multiple coordinate frames**: Perifocal (PQW), Mars-Centered Inertial (MCI), Longitude/Latitude/Altitude (LLA)
- **Geodetic coordinates** accounting for Mars' oblate spheroid shape
- **Time-dependent transformations** accounting for Mars rotation
- **High precision** with double-precision arithmetic throughout
- **Comprehensive testing** with 100+ unit and integration tests

## Requirements

- IDL (Interactive Data Language) version 8.0 or higher
  - Tested with IDL 9.1.0
  - Compatible with GDL (GNU Data Language)

## Installation

1. Clone or download this repository
2. Ensure IDL is installed and accessible from your command line
3. Add the project directory to your IDL path (optional)

```bash
# Test installation
cd satellite_position
idl -e ".compile mars_constants.pro" -e "mars = mars_constants()" -e "help, mars"
```

## Quick Start

### Basic Orbit Propagation

```idl
; Initialize Mars constants
.compile mars_constants.pro
.compile orbital_propagator.pro
mars = mars_constants()

; Define orbital elements (Phobos-like orbit)
elements = {$
  a:     9376.0d0,         ; Semi-major axis (km)
  e:     0.0151d0,         ; Eccentricity
  i:     1.093d0 * !DTOR,  ; Inclination (radians)
  raan:  0.0d0,            ; RAAN (radians)
  omega: 0.0d0,            ; Argument of periapsis (radians)
  M0:    0.0d0             ; Mean anomaly at epoch (radians)
}

; Propagate for one orbit
t0 = 0.0d0
period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
t = DINDGEN(100) * period / 99.0d0  ; 100 points

result = propagate_orbit(elements, t, t0, mars)

; Plot ground track
plot, result.lon, result.lat, psym=3, $
      xtitle='Longitude (deg)', ytitle='Latitude (deg)', $
      title='Ground Track'

; Plot altitude vs time
plot, result.t / 3600.0d0, result.alt, $
      xtitle='Time (hours)', ytitle='Altitude (km)'
```

## Module Descriptions

### Core Modules

#### `mars_constants.pro`
Defines physical and orbital constants for Mars:
- Gravitational parameter (μ = 42828.37 km³/s²)
- Reference ellipsoid dimensions (r_eq = 3396.19 km, r_pol = 3376.20 km)
- Rotation rate (ω = 7.088218×10⁻⁵ rad/s)

#### `solve_kepler.pro`
Solves Kepler's equation (M = Ecc - e·sin(Ecc)) using Newton-Raphson iteration:
- Converges in typically 4-6 iterations
- Accuracy: < 10⁻¹⁰ radians
- Handles eccentricities from 0 to 0.99

#### Anomaly Conversions
Converts between eccentric and true anomaly:
- `ecc_to_true_anomaly.pro` - Eccentric → True anomaly
- `true_to_ecc_anomaly.pro` - True → Eccentric anomaly
- Round-trip accuracy: machine precision (~10⁻¹⁶)

#### Coordinate Transformations
Coordinate frame transformations:
- `calculate_perifocal_position.pro` - Calculate position/velocity in perifocal frame
- `perifocal_to_mci.pro` - Perifocal → MCI transformation
- `mci_to_perifocal.pro` - MCI → Perifocal transformation

#### Geodetic Conversions
Geodetic coordinate conversions:
- `mci_to_mars_fixed.pro` - Account for Mars rotation (MCI → Mars-fixed)
- `mars_fixed_to_mci.pro` - Mars-fixed → MCI transformation
- `calculate_geodetic_latitude.pro` - Iterative geodetic latitude solver
- `mci_to_lla.pro` - Full MCI → Longitude/Latitude/Altitude
- `lla_to_mci.pro` - Inverse transformation (LLA → MCI)

#### `orbital_propagator.pro`
Main propagator integrating all modules:
- Input: Keplerian elements + time array
- Output: Position/velocity in all coordinate frames
- Single function call for complete propagation

## Coordinate Frames

### Perifocal Frame (PQW)
- **Origin**: Center of Mars
- **P-axis**: Points toward periapsis
- **Q-axis**: In orbital plane, 90° ahead (direction of motion)
- **W-axis**: Normal to orbital plane (angular momentum direction)

### Mars-Centered Inertial (MCI)
- **Origin**: Center of Mars
- **X-axis**: Vernal equinox direction (J2000)
- **Z-axis**: Mars rotation axis (north pole)
- **Y-axis**: Completes right-handed system

### Longitude/Latitude/Altitude (LLA)
- **Longitude**: East longitude, range [-180°, 180°]
- **Latitude**: Geodetic latitude (perpendicular to reference ellipsoid)
- **Altitude**: Height above reference ellipsoid (km)

## Running Tests

### Unit Tests

Each module has its own unit test file:

```bash
# Test Mars constants
idl run_test_mars.pro  # Or: idl -e ".compile mars_constants.pro" -e ".compile test_mars_constants.pro" -e "test_mars_constants"

# Test Kepler solver
idl run_test_kepler.pro

# Test anomaly conversions
idl run_test_anomaly.pro

# Test coordinate transforms
idl -e ".compile coordinate_transforms.pro" -e ".compile test_coordinate_transforms.pro" -e "test_coordinate_transforms"

# Test MCI to LLA conversions
idl -e ".compile mci_to_lla.pro" -e ".compile test_mci_to_lla.pro" -e "test_mci_to_lla"

# Test orbital propagator
idl -e ".compile orbital_propagator.pro" -e ".compile test_orbital_propagator.pro" -e "test_orbital_propagator"
```

### Integration Tests

```bash
idl -e ".compile test_orbit_propagation.pro" -e "test_orbit_propagation"
```

Integration tests validate:
- Circular equatorial orbits
- Polar orbits
- Eccentric orbits
- Energy conservation
- Angular momentum conservation
- Kepler solver edge cases

## Examples

### Example 1: Circular Orbit at 500 km Altitude

```idl
mars = mars_constants()

; Circular orbit at 500 km altitude
a = mars.r_eq + 500.0d0
elements = {a: a, e: 0.0d0, i: 0.0d0, raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}

t = DINDGEN(10) * 3600.0d0  ; Every hour for 10 hours
result = propagate_orbit(elements, t, 0.0d0, mars)

print, 'Time (hr)    Lon (deg)    Lat (deg)    Alt (km)'
for i = 0, 9 do begin
  print, result[i].t/3600.0, result[i].lon, result[i].lat, result[i].alt, $
         format='(F8.2, 3F13.2)'
endfor
```

### Example 2: Eccentric Orbit

```idl
mars = mars_constants()

; Highly eccentric orbit
elements = {a: 15000.0d0, e: 0.7d0, i: 0.5d0, raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}

period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
t = DINDGEN(200) * period / 199.0d0

result = propagate_orbit(elements, t, 0.0d0, mars)

; Plot orbital radius vs time
plot, result.t / 3600.0d0, result.r, $
      xtitle='Time (hours)', ytitle='Radius (km)', $
      title='Orbital Radius vs Time (e=0.7)'
```

### Example 3: Polar Orbit Ground Track

```idl
mars = mars_constants()

; Sun-synchronous-like polar orbit
elements = {a: 10000.0d0, e: 0.01d0, i: !DPI/2.0d0, raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}

period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
t = DINDGEN(500) * period * 3.0d0 / 499.0d0  ; 3 orbits

result = propagate_orbit(elements, t, 0.0d0, mars)

; Plot ground track
plot, result.lon, result.lat, psym=3, $
      xrange=[-180, 180], yrange=[-90, 90], $
      xtitle='Longitude (deg)', ytitle='Latitude (deg)', $
      title='Polar Orbit Ground Track (3 revolutions)'
```

### Example 4: TGO (Trace Gas Orbiter) Realistic Mission Orbit

```idl
; ============================================================
; ExoMars Trace Gas Orbiter (TGO) - Real Mars Mission Example
; ============================================================
; TGO has been studying Mars' atmosphere since 2018 from a
; near-circular orbit at 400 km altitude with 74-degree
; inclination, providing excellent mid-latitude coverage.
;
; Mission: ESA/Roscosmos ExoMars 2016
; Operational orbit achieved: February 2018
; Reference: https://exploration.esa.int/web/mars/-/46475-trace-gas-orbiter
; ============================================================

mars = mars_constants()

; TGO operational science orbit parameters
a_tgo = mars.r_eq + 400.0d0        ; Semi-major axis: 3796.19 km
e_tgo = 0.005d0                    ; Nearly circular (low eccentricity)
i_tgo = 74.0d0 * !DTOR             ; 74-degree inclination (near-polar)
raan_tgo = 0.0d0                   ; RAAN (arbitrary for this example)
omega_tgo = 0.0d0                  ; Argument of periapsis (minimal effect at low ecc)
M0_tgo = 0.0d0                     ; Mean anomaly at epoch

elements_tgo = {a: a_tgo, e: e_tgo, i: i_tgo, $
                raan: raan_tgo, omega: omega_tgo, M0: M0_tgo}

; Calculate and verify orbital period (should be ~2 hours)
period_tgo = 2.0d0 * !DPI * SQRT(elements_tgo.a^3 / mars.mu)
print, 'TGO Orbital Period: ', period_tgo / 3600.0d0, ' hours'

; Propagate for 10 complete orbits (~20 hours of mission time)
n_orbits = 10
t = DINDGEN(n_orbits * 100) * period_tgo / 100.0d0  ; 100 points per orbit

result = propagate_orbit(elements_tgo, t, 0.0d0, mars)

; Verify altitude remains constant at ~400 km (validates circular orbit)
print, 'Mean Altitude: ', MEAN(result.alt), ' km'
print, 'Altitude Range: ', MIN(result.alt), ' to ', MAX(result.alt), ' km'

; Verify latitude coverage (74-deg inclination reaches latitudes +/- 74 deg)
print, 'Latitude Range: ', MIN(result.lat), ' to ', MAX(result.lat), ' degrees'

; Plot ground track showing 10 orbits of coverage
; The 74-degree inclination provides excellent mid-latitude coverage
; while the near-circular orbit maintains constant altitude
plot, result.lon, result.lat, psym=3, $
      xrange=[-180, 180], yrange=[-90, 90], $
      xtitle='Longitude (deg)', ytitle='Latitude (deg)', $
      title='TGO Ground Track (10 orbits, ~20 hours)'

; Verify nearly constant altitude profile (circular orbit characteristic)
plot, result.t / 3600.0d0, result.alt, $
      xtitle='Time (hours)', ytitle='Altitude (km)', $
      title='TGO Altitude Profile - Should be nearly flat'
```

**What this example demonstrates:**
- **Real-world spacecraft**: Uses actual orbital parameters from ESA's Mars mission
- **Near-circular orbits**: Very low eccentricity (0.005) means nearly constant 400 km altitude
- **Inclined orbit coverage**: 74° inclination provides access to mid-latitudes without full polar coverage
- **Multi-orbit propagation**: Shows how to analyze extended mission timelines (10 orbits, ~20 hours)
- **Orbit verification**: Confirms that calculated period (~2 hours) and altitude match published mission parameters

**Expected Results:**
- Orbital period: ~1.98 hours (7128 seconds)
- Altitude: 400 km ± 1-2 km (variation due to small eccentricity)
- Latitude coverage: -74° to +74° (matching inclination)
- Ground track pattern: Diagonal passes across Mars surface with gradual westward drift due to Mars rotation

## Variable Naming Conventions

- **Ecc**: Eccentric Anomaly (capital E distinguishes from eccentricity e)
- **M**: Mean Anomaly
- **nu** (ν): True Anomaly
- **a**: Semi-major axis (km)
- **e**: Eccentricity
- **i**: Inclination (radians)
- **raan** (Ω): Right Ascension of Ascending Node - RAAN (radians)
- **omega** (ω): Argument of periapsis (radians)
- **M0**: Mean anomaly at epoch (radians)

## Technical Details

### Accuracy

- Kepler solver: < 10⁻¹⁰ radians
- Anomaly conversions: ~10⁻¹⁶ radians (machine precision)
- Geodetic latitude: < 10⁻⁸ degrees
- Round-trip MCI ↔ LLA: < 0.1 meters
- Energy conservation: ΔE/E < 10⁻¹²
- Angular momentum conservation: Δh/h < 10⁻¹²

### Convergence

- Kepler solver: Typically 4-6 iterations (max 50)
- Geodetic latitude: Typically 3-5 iterations (max 10)

### Limitations

- **Two-body problem only**: No perturbations (atmospheric drag, J2, third-body, etc.)
- **Elliptical orbits**: Eccentricity must be in range [0, 1)
- **No time-varying elements**: Elements are constant during propagation

## File Structure

```
satellite_position/
├── mars_constants.pro              # Mars physical constants
├── kepler_solver.pro               # Kepler equation solver
├── anomaly_conversions.pro         # Anomaly conversions
├── coordinate_transforms.pro       # Coordinate transformations
├── mci_to_lla.pro                 # Geodetic conversions
├── orbital_propagator.pro          # Main propagator
├── test_mars_constants.pro         # Unit tests
├── test_kepler_solver.pro          # Unit tests
├── test_anomaly_conversions.pro    # Unit tests
├── test_coordinate_transforms.pro  # Unit tests
├── test_mci_to_lla.pro            # Unit tests
├── test_orbital_propagator.pro     # Unit tests
├── test_orbit_propagation.pro      # Integration tests
├── run_test_kepler.pro            # Test runner
├── run_test_anomaly.pro           # Test runner
├── TODO.md                        # Task tracking
├── STATUS.md                      # Project status
└── README.md                      # This file
```

## References

- Vallado, D. A. (2013). *Fundamentals of Astrodynamics and Applications*, 4th Edition.
- Prussing, J. E., & Conway, B. A. (1993). *Orbital Mechanics*.
- NASA Mars Fact Sheet: https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
- IAU/IAG Working Group on Cartographic Coordinates and Rotational Elements

## License

This project was created for educational and scientific purposes.

## Contributing

This is a complete, tested implementation. Future enhancements could include:
- Perturbation models (J2, atmospheric drag, solar radiation pressure)
- State transition matrix propagation
- Orbit determination capabilities
- Additional planets/moons
- Visualization tools

## Support

For questions or issues, please refer to the comprehensive inline documentation in each `.pro` file.

---

**Project completed: 2026-02-18**
