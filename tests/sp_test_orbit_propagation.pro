;+
; NAME:
;   TEST_ORBIT_PROPAGATION
;
; PURPOSE:
;   Integration tests for the complete orbital propagation system.
;   Tests end-to-end functionality with realistic orbital scenarios.
;
; CATEGORY:
;   Integration Testing / Orbital Mechanics
;
; CALLING SEQUENCE:
;   sp_test_orbit_propagation
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Prints test results to console (PASS/FAIL for each test)
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

PRO sp_test_orbit_propagation

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Integration Tests for Orbital Propagation'
  print, '========================================='
  print, ''

  ; Get Mars constants
  mars = sp_mars_constants()

  ; TEST 1: Circular equatorial orbit - constant altitude
  n_tests++
  test_name = 'Circular equatorial: constant altitude ± 0.01 km'

  elements = {a: 10000.0d0, e: 0.0d0, i: 0.0d0, raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
  t = DINDGEN(100) * period / 99.0d0

  result = sp_propagate_orbit(elements, t, t0, mars)

  ; Extract altitudes
  altitudes = DBLARR(N_ELEMENTS(result))
  for idx = 0, N_ELEMENTS(result) - 1 do begin
    altitudes[idx] = result[idx].alt
  endfor

  mean_alt = MEAN(altitudes)
  max_deviation = MAX(ABS(altitudes - mean_alt))

  if (max_deviation lt 0.01d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Mean altitude: ', mean_alt, ' km'
    print, '  Max deviation: ', max_deviation, ' km'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max deviation: ', max_deviation, ' km (should be < 0.01)'
  endelse

  ; TEST 2: Circular equatorial orbit - latitude ≈ 0°
  n_tests++
  test_name = 'Circular equatorial: latitude ≈ 0° ± 0.01°'

  ; Use same result from previous test
  latitudes = DBLARR(N_ELEMENTS(result))
  for idx = 0, N_ELEMENTS(result) - 1 do begin
    latitudes[idx] = result[idx].lat
  endfor

  max_lat = MAX(ABS(latitudes))

  if (max_lat lt 0.01d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max |latitude|: ', max_lat, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max |latitude|: ', max_lat, ' degrees (should be < 0.01)'
  endelse

  ; TEST 3: Circular equatorial orbit - linear longitude change
  n_tests++
  test_name = 'Circular equatorial: linear longitude change'

  ; Check that longitude changes approximately linearly
  ; (accounting for Mars rotation)
  longitudes = DBLARR(N_ELEMENTS(result))
  times = DBLARR(N_ELEMENTS(result))
  for idx = 0, N_ELEMENTS(result) - 1 do begin
    longitudes[idx] = result[idx].lon
    times[idx] = result[idx].t
  endfor

  ; Unwrap longitude (handle 180° discontinuity)
  for idx = 1, N_ELEMENTS(longitudes) - 1 do begin
    diff = longitudes[idx] - longitudes[idx-1]
    if (diff gt 180.0d0) then longitudes[idx:*] = longitudes[idx:*] - 360.0d0
    if (diff lt -180.0d0) then longitudes[idx:*] = longitudes[idx:*] + 360.0d0
  endfor

  ; Linear fit: lon = a*t + b
  coeffs = LINFIT(times, longitudes)
  lon_fit = coeffs[0] + coeffs[1] * times
  residuals = longitudes - lon_fit
  rms_residual = SQRT(MEAN(residuals^2))

  if (rms_residual lt 1.0d0) then begin  ; Within 1 degree RMS
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  RMS residual: ', rms_residual, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  RMS residual: ', rms_residual, ' degrees (should be < 1.0)'
  endelse

  ; TEST 4: Polar orbit - latitude ranges from -90° to +90°
  n_tests++
  test_name = 'Polar orbit: latitude ranges -90° to +90°'

  elements = {a: 10000.0d0, e: 0.0d0, i: !DPI/2.0d0, raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
  t = DINDGEN(100) * period / 99.0d0

  result = sp_propagate_orbit(elements, t, t0, mars)

  latitudes = DBLARR(N_ELEMENTS(result))
  for idx = 0, N_ELEMENTS(result) - 1 do begin
    latitudes[idx] = result[idx].lat
  endfor

  min_lat = MIN(latitudes)
  max_lat = MAX(latitudes)

  ; Should cover from near -90° to near +90°
  if (min_lat lt -80.0d0 AND max_lat gt 80.0d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Latitude range: [', min_lat, ', ', max_lat, '] degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Latitude range: [', min_lat, ', ', max_lat, '] degrees'
  endelse

  ; TEST 5: Eccentric orbit - periapsis and apoapsis altitudes
  n_tests++
  test_name = 'Eccentric orbit: periapsis and apoapsis altitudes within 0.1 km'

  a = 15000.0d0
  e = 0.5d0
  elements = {a: a, e: e, i: 0.0d0, raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
  t = DINDGEN(100) * period / 99.0d0

  result = sp_propagate_orbit(elements, t, t0, mars)

  altitudes = DBLARR(N_ELEMENTS(result))
  for idx = 0, N_ELEMENTS(result) - 1 do begin
    altitudes[idx] = result[idx].alt
  endfor

  min_alt = MIN(altitudes)
  max_alt = MAX(altitudes)

  ; Theoretical values
  r_peri = a * (1.0d0 - e)
  r_apo = a * (1.0d0 + e)
  alt_peri_expected = r_peri - mars.r_eq
  alt_apo_expected = r_apo - mars.r_eq

  error_peri = ABS(min_alt - alt_peri_expected)
  error_apo = ABS(max_alt - alt_apo_expected)

  if (error_peri lt 0.1d0 AND error_apo lt 0.1d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Peri alt: ', min_alt, ' km (expected: ', alt_peri_expected, ')'
    print, '  Apo alt:  ', max_alt, ' km (expected: ', alt_apo_expected, ')'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Periapsis error: ', error_peri, ' km'
    print, '  Apoapsis error:  ', error_apo, ' km'
  endelse

  ; TEST 6: Energy conservation
  n_tests++
  test_name = 'Energy conservation: E = -μ/(2a) constant (ΔE/E < 1e-12)'

  elements = {a: 12000.0d0, e: 0.4d0, i: 0.5d0, raan: 0.1d0, omega: 0.2d0, M0: 0.0d0}
  t0 = 0.0d0
  period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
  t = DINDGEN(50) * period / 49.0d0

  result = sp_propagate_orbit(elements, t, t0, mars)

  E_expected = -mars.mu / (2.0d0 * elements.a)
  E_errors = DBLARR(N_ELEMENTS(result))

  for idx = 0, N_ELEMENTS(result) - 1 do begin
    v_mag = SQRT(TOTAL(result[idx].v_mci^2))
    r_mag = SQRT(TOTAL(result[idx].r_mci^2))
    E_actual = 0.5d0 * v_mag^2 - mars.mu / r_mag
    E_errors[idx] = ABS((E_actual - E_expected) / E_expected)
  endfor

  max_E_error = MAX(E_errors)

  if (max_E_error lt 1e-12) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max relative error: ', max_E_error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max relative error: ', max_E_error
  endelse

  ; TEST 7: Angular momentum conservation
  n_tests++
  test_name = 'Angular momentum conservation: |h| constant (Δh/h < 1e-12)'

  ; Use same result from previous test
  p = elements.a * (1.0d0 - elements.e^2)
  h_expected = SQRT(mars.mu * p)
  h_errors = DBLARR(N_ELEMENTS(result))

  for idx = 0, N_ELEMENTS(result) - 1 do begin
    ; h = r × v
    h_vec = DBLARR(3)
    h_vec[0] = result[idx].r_mci[1] * result[idx].v_mci[2] - result[idx].r_mci[2] * result[idx].v_mci[1]
    h_vec[1] = result[idx].r_mci[2] * result[idx].v_mci[0] - result[idx].r_mci[0] * result[idx].v_mci[2]
    h_vec[2] = result[idx].r_mci[0] * result[idx].v_mci[1] - result[idx].r_mci[1] * result[idx].v_mci[0]
    h_mag = SQRT(TOTAL(h_vec^2))
    h_errors[idx] = ABS((h_mag - h_expected) / h_expected)
  endfor

  max_h_error = MAX(h_errors)

  if (max_h_error lt 1e-12) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max relative error: ', max_h_error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max relative error: ', max_h_error
  endelse

  ; TEST 8: Kepler solver edge cases
  n_tests++
  test_name = 'Kepler solver: converges for e=[0, 0.1, 0.5, 0.9, 0.99]'

  e_values = [0.0d0, 0.1d0, 0.5d0, 0.9d0, 0.99d0]
  all_converged = 1b
  max_error = 0.0d0

  foreach e_val, e_values do begin
    elements_test = {a: 10000.0d0, e: e_val, i: 0.0d0, raan: 0.0d0, omega: 0.0d0, M0: !DPI/4.0d0}
    result_test = sp_propagate_orbit(elements_test, 0.0d0, 0.0d0, mars)

    ; Verify Kepler's equation: M = Ecc - e*sin(Ecc)
    M_rad = result_test.M * !DTOR
    Ecc_rad = result_test.Ecc * !DTOR
    M_computed = Ecc_rad - e_val * SIN(Ecc_rad)
    error = ABS(M_computed - M_rad)
    if (error gt max_error) then max_error = error
    if (error gt 1e-10) then all_converged = 0b
  endforeach

  if (all_converged) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max error: ', max_error, ' radians'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max error: ', max_error, ' radians'
  endelse

  ; Print summary
  print, ''
  print, '========================================='
  print, 'Test Summary'
  print, '========================================='
  print, 'Total tests: ', STRTRIM(n_tests, 2)
  print, 'Passed:      ', STRTRIM(n_passed, 2)
  print, 'Failed:      ', STRTRIM(n_tests - n_passed, 2)

  if (n_passed eq n_tests) then begin
    print, ''
    print, 'SUCCESS: All tests passed!'
    print, ''
  endif else begin
    print, ''
    print, 'FAILURE: Some tests failed.'
    print, ''
  endelse

END
