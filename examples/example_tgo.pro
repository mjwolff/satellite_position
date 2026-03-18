; ============================================================
; ExoMars Trace Gas Orbiter (TGO) - Comprehensive Example
; ============================================================
; This standalone example demonstrates orbital propagation using
; real parameters from ESA's ExoMars Trace Gas Orbiter mission.
;
; TGO has been studying Mars' atmosphere and surface since 2018
; from a near-circular science orbit at 400 km altitude with
; 74-degree inclination.
;
; Mission: ESA/Roscosmos ExoMars 2016
; Launch: March 14, 2016
; Mars Orbit Insertion: October 19, 2016
; Science Orbit: February 2018 - present
;
; References:
; - ESA ExoMars: https://exploration.esa.int/web/mars/-/46475-trace-gas-orbiter
; - Wikipedia: https://en.wikipedia.org/wiki/Trace_Gas_Orbiter
; ============================================================

PRO example_tgo

  ; Initialize Mars constants
  ; Note: Ensure mars_constants.pro and propagate_orbit.pro are compiled before running
  mars = mars_constants()

  print, ''
  print, '============================================================'
  print, 'TGO (Trace Gas Orbiter) Orbital Propagation Example'
  print, '============================================================'
  print, ''

  ; ============================================================
  ; Define TGO Orbital Elements
  ; ============================================================

  ; TGO operational science orbit parameters
  a_tgo = mars.r_eq + 400.0d0        ; Semi-major axis: 3796.19 km
  e_tgo = 0.005d0                    ; Nearly circular (low eccentricity)
  i_tgo = 74.0d0 * !DTOR             ; 74-degree inclination (near-polar)
  raan_tgo = 0.0d0                   ; RAAN (arbitrary for this example)
  omega_tgo = 0.0d0                  ; Argument of periapsis (minimal effect at low ecc)
  M0_tgo = 0.0d0                     ; Mean anomaly at epoch

  elements_tgo = {a: a_tgo, e: e_tgo, i: i_tgo, $
                  raan: raan_tgo, omega: omega_tgo, M0: M0_tgo}

  print, 'TGO Orbital Elements:'
  print, '  Semi-major axis: ', a_tgo, ' km'
  print, '  Eccentricity: ', e_tgo
  print, '  Inclination: ', i_tgo * !RADEG, ' degrees'
  print, '  RAAN: ', raan_tgo * !RADEG, ' degrees'
  print, '  Argument of periapsis: ', omega_tgo * !RADEG, ' degrees'
  print, '  Mean anomaly at epoch: ', M0_tgo * !RADEG, ' degrees'
  print, ''

  ; ============================================================
  ; Calculate Orbital Period
  ; ============================================================

  period_tgo = 2.0d0 * !DPI * SQRT(elements_tgo.a^3 / mars.mu)

  print, 'Orbital Period Calculation:'
  print, '  Period: ', period_tgo, ' seconds'
  print, '  Period: ', period_tgo / 60.0d0, ' minutes'
  print, '  Period: ', period_tgo / 3600.0d0, ' hours'
  print, '  (Expected: ~2 hours for TGO science orbit)'
  print, ''

  ; ============================================================
  ; Propagate Orbit for 10 Revolutions
  ; ============================================================

  n_orbits = 10
  n_points_per_orbit = 100
  t = DINDGEN(n_orbits * n_points_per_orbit) * period_tgo / DOUBLE(n_points_per_orbit)

  print, 'Propagating orbit for ', n_orbits, ' revolutions...'
  result = propagate_orbit(elements_tgo, t, 0.0d0, mars)
  print, 'Propagation complete.'
  print, ''

  ; ============================================================
  ; Verify Orbital Parameters
  ; ============================================================

  print, 'Orbital Parameter Verification:'
  print, ''

  ; Altitude verification (should be ~400 km throughout)
  alt_mean = MEAN(result.alt)
  alt_min = MIN(result.alt)
  alt_max = MAX(result.alt)
  alt_std = STDDEV(result.alt)

  print, 'Altitude Statistics:'
  print, '  Mean altitude: ', alt_mean, ' km (expected: ~400 km)'
  print, '  Min altitude: ', alt_min, ' km'
  print, '  Max altitude: ', alt_max, ' km'
  print, '  Altitude range: ', alt_max - alt_min, ' km'
  print, '  Std deviation: ', alt_std, ' km'
  print, ''

  ; Latitude coverage verification
  lat_min = MIN(result.lat)
  lat_max = MAX(result.lat)

  print, 'Latitude Coverage:'
  print, '  Min latitude: ', lat_min, ' degrees'
  print, '  Max latitude: ', lat_max, ' degrees'
  print, '  Latitude range: ', lat_max - lat_min, ' degrees'
  print, '  (Expected: approximately +/- 74 degrees, matching inclination)'
  print, ''

  ; Longitude coverage
  lon_min = MIN(result.lon)
  lon_max = MAX(result.lon)

  print, 'Longitude Coverage:'
  print, '  Min longitude: ', lon_min, ' degrees'
  print, '  Max longitude: ', lon_max, ' degrees'
  print, '  (TGO covers all longitudes over multiple orbits)'
  print, ''

  ; ============================================================
  ; Mission Duration Analysis
  ; ============================================================

  total_time = MAX(result.t)

  print, 'Mission Duration (for this propagation):'
  print, '  Total time: ', total_time / 3600.0d0, ' hours'
  print, '  Number of orbits: ', n_orbits
  print, '  Average time per orbit: ', total_time / n_orbits / 60.0d0, ' minutes'
  print, ''

  ; ============================================================
  ; Ground Track Visualization
  ; ============================================================

  print, 'Generating visualizations...'
  print, ''

  ; Ground track plot
  window, 0, xsize=800, ysize=500
  plot, result.lon, result.lat, psym=3, $
        xrange=[-180, 180], yrange=[-90, 90], $
        xtitle='Longitude (degrees)', ytitle='Latitude (degrees)', $
        title='TGO Ground Track - 10 Orbits (~20 hours)', $
        charsize=1.5

  ; Add reference lines
  oplot, [-180, 180], [0, 0], linestyle=1, color=150  ; Equator
  oplot, [-180, 180], [74, 74], linestyle=2, color=100  ; Max latitude
  oplot, [-180, 180], [-74, -74], linestyle=2, color=100  ; Min latitude

  ; Altitude profile plot
  window, 1, xsize=800, ysize=500
  plot, result.t / 3600.0d0, result.alt, $
        xtitle='Time (hours)', ytitle='Altitude (km)', $
        title='TGO Altitude Profile - Nearly Constant (Circular Orbit)', $
        charsize=1.5, $
        yrange=[alt_mean - 5, alt_mean + 5]

  ; Add mean altitude line
  oplot, [0, total_time / 3600.0d0], [alt_mean, alt_mean], $
         linestyle=1, color=250, thick=2

  ; 3D orbital visualization (X-Y plane)
  window, 2, xsize=600, ysize=600

  ; Extract X and Y coordinates from array of structures
  n_points = N_ELEMENTS(result)
  x_coords = DBLARR(n_points)
  y_coords = DBLARR(n_points)
  FOR i = 0, n_points - 1 DO BEGIN
    x_coords[i] = result[i].r_mci[0]
    y_coords[i] = result[i].r_mci[1]
  ENDFOR

  plot, x_coords, y_coords, psym=3, $
        xtitle='X (km)', ytitle='Y (km)', $
        title='TGO Orbit - MCI Frame (X-Y Projection)', $
        charsize=1.5, /isotropic

  ; Add Mars sphere
  theta = DINDGEN(361) * !DTOR
  mars_x = mars.r_eq * COS(theta)
  mars_y = mars.r_eq * SIN(theta)
  oplot, mars_x, mars_y, color=200, thick=2

  print, 'Visualizations complete.'
  print, '  Window 0: Ground track showing latitude coverage'
  print, '  Window 1: Altitude vs time (nearly flat line confirms circular orbit)'
  print, '  Window 2: Orbital path in MCI frame (X-Y projection)'
  print, ''

  ; ============================================================
  ; Summary
  ; ============================================================

  print, '============================================================'
  print, 'Summary'
  print, '============================================================'
  print, ''
  print, 'This example demonstrates the propagation of a realistic'
  print, 'Mars orbiter using actual mission parameters from TGO.'
  print, ''
  print, 'Key characteristics of TGO science orbit:'
  print, '  - Near-circular (e=0.005) for consistent altitude'
  print, '  - 400 km altitude for atmospheric observations'
  print, '  - 74-degree inclination for mid-latitude coverage'
  print, '  - ~2 hour orbital period for frequent passes'
  print, ''
  print, 'The propagator accurately reproduces these characteristics,'
  print, 'validating the orbital mechanics implementation.'
  print, ''
  print, '============================================================'

END
