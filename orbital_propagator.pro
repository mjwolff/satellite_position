;+
; NAME:
;   PROPAGATE_ORBIT
;
; PURPOSE:
;   Main orbital propagator that integrates all modules to propagate a satellite
;   orbit from Keplerian elements and output position in multiple coordinate frames.
;
; CATEGORY:
;   Orbital Mechanics / Orbit Propagation
;
; CALLING SEQUENCE:
;   result = propagate_orbit(elements, t, t0, constants)
;
; INPUTS:
;   elements  - Structure containing Keplerian orbital elements:
;               .a     - Semi-major axis (km)
;               .e     - Eccentricity (dimensionless), 0 <= e < 1
;               .i     - Inclination (radians)
;               .raan  - Right ascension of ascending node (radians)
;               .omega - Argument of periapsis (radians)
;               .M0    - Mean anomaly at epoch (radians)
;   t         - Time to propagate to (seconds since epoch), scalar or array
;   t0        - Epoch time (seconds)
;   constants - Mars constants structure from mars_constants()
;
; OUTPUTS:
;   Structure (or array of structures if t is an array) containing:
;     .t       - Time (seconds)
;     .M       - Mean anomaly (degrees)
;     .Ecc     - Eccentric anomaly (degrees)
;     .nu      - True anomaly (degrees)
;     .r       - Radius (km)
;     .r_pqw   - Position in perifocal frame [3] (km)
;     .v_pqw   - Velocity in perifocal frame [3] (km/s)
;     .r_mci   - Position in MCI frame [3] (km)
;     .v_mci   - Velocity in MCI frame [3] (km/s)
;     .lon     - Longitude (degrees)
;     .lat     - Geodetic latitude (degrees)
;     .alt     - Altitude above ellipsoid (km)
;
; ALGORITHM:
;   For each time point:
;   1. Calculate mean motion: n = sqrt(μ/a³)
;   2. Propagate mean anomaly: M(t) = M₀ + n·(t-t₀)
;   3. Solve Kepler's equation: M = Ecc - e·sin(Ecc)
;   4. Convert to true anomaly: ν = f(Ecc, e)
;   5. Calculate perifocal position & velocity
;   6. Transform to MCI frame
;   7. Convert to longitude/latitude/altitude
;
; EXAMPLE:
;   IDL> mars = mars_constants()
;   IDL> ; Phobos-like orbit
;   IDL> elements = {a: 9376.0d0, e: 0.0151d0, i: 1.093d0*!DTOR, $
;                     raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}
;   IDL> t0 = 0.0d0
;   IDL> period = 2*!DPI*sqrt(elements.a^3 / mars.mu)
;   IDL> t = dindgen(100) * period / 99.0d0
;   IDL> result = propagate_orbit(elements, t, t0, mars)
;   IDL> plot, result.lon, result.lat
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION propagate_orbit, elements, t, t0, constants

  COMPILE_OPT IDL2, HIDDEN

  ; Extract orbital elements
  a = elements.a
  e = elements.e
  i = elements.i
  raan = elements.raan
  omega = elements.omega
  M0 = elements.M0

  ; Validate inputs
  if (a le 0.0d0) then begin
    MESSAGE, 'Semi-major axis must be positive. a = ' + STRTRIM(a, 2)
  endif

  if (e lt 0.0d0 OR e ge 1.0d0) then begin
    MESSAGE, 'Eccentricity must be in range [0, 1). e = ' + STRTRIM(e, 2)
  endif

  if (i lt 0.0d0 OR i gt !DPI) then begin
    MESSAGE, 'Inclination must be in range [0, π]. i = ' + STRTRIM(i, 2)
  endif

  ; Calculate mean motion: n = sqrt(μ/a³)
  n = SQRT(constants.mu / a^3)

  ; Determine if t is scalar or array
  n_times = N_ELEMENTS(t)
  is_scalar = (n_times eq 1)

  ; Initialize result structure(s)
  if (is_scalar) then begin
    ; Single time point
    t_val = t

    ; Step 1: Calculate mean anomaly
    M = M0 + n * (t_val - t0)

    ; Step 2: Solve Kepler's equation for eccentric anomaly
    Ecc = solve_kepler(M, e)

    ; Step 3: Convert to true anomaly
    nu = ecc_to_true_anomaly(Ecc, e)

    ; Step 4: Calculate position & velocity in perifocal frame
    peri_result = calculate_perifocal_position(a, e, nu, constants.mu)

    ; Step 5: Transform to MCI frame
    mci_result = perifocal_to_mci(peri_result.r_pqw, peri_result.v_pqw, raan, omega, i)

    ; Step 6: Convert to LLA
    lla_result = mci_to_lla(mci_result.r_mci, t_val, constants)

    ; Build result structure
    result = { $
      t:     t_val, $
      M:     M * !RADEG, $
      Ecc:   Ecc * !RADEG, $
      nu:    nu * !RADEG, $
      r:     peri_result.r, $
      r_pqw: peri_result.r_pqw, $
      v_pqw: peri_result.v_pqw, $
      r_mci: mci_result.r_mci, $
      v_mci: mci_result.v_mci, $
      lon:   lla_result.lon, $
      lat:   lla_result.lat, $
      alt:   lla_result.alt $
    }

  endif else begin
    ; Multiple time points - create array of structures
    results = REPLICATE({t: 0.0d0, M: 0.0d0, Ecc: 0.0d0, nu: 0.0d0, r: 0.0d0, $
                         r_pqw: DBLARR(3), v_pqw: DBLARR(3), $
                         r_mci: DBLARR(3), v_mci: DBLARR(3), $
                         lon: 0.0d0, lat: 0.0d0, alt: 0.0d0}, n_times)

    ; Propagate for each time point
    for idx = 0, n_times - 1 do begin
      t_val = t[idx]

      ; Step 1: Calculate mean anomaly
      M = M0 + n * (t_val - t0)

      ; Step 2: Solve Kepler's equation
      Ecc = solve_kepler(M, e)

      ; Step 3: Convert to true anomaly
      nu = ecc_to_true_anomaly(Ecc, e)

      ; Step 4: Calculate perifocal position & velocity
      peri_result = calculate_perifocal_position(a, e, nu, constants.mu)

      ; Step 5: Transform to MCI
      mci_result = perifocal_to_mci(peri_result.r_pqw, peri_result.v_pqw, raan, omega, i)

      ; Step 6: Convert to LLA
      lla_result = mci_to_lla(mci_result.r_mci, t_val, constants)

      ; Store results
      results[idx].t = t_val
      results[idx].M = M * !RADEG
      results[idx].Ecc = Ecc * !RADEG
      results[idx].nu = nu * !RADEG
      results[idx].r = peri_result.r
      results[idx].r_pqw = peri_result.r_pqw
      results[idx].v_pqw = peri_result.v_pqw
      results[idx].r_mci = mci_result.r_mci
      results[idx].v_mci = mci_result.v_mci
      results[idx].lon = lla_result.lon
      results[idx].lat = lla_result.lat
      results[idx].alt = lla_result.alt
    endfor

    result = results
  endelse

  RETURN, result

END
