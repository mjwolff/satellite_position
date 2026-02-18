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
;   test_orbit_propagation
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

PRO test_orbit_propagation

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
  .compile mars_constants.pro
  .compile orbital_propagator.pro
  mars = mars_constants()

  ; TEST 1: Circular equatorial orbit - constant altitude
  n_tests++
  test_name = 'Circular equatorial: constant altitude ± 0.01 km'

  elements = {a: 10000.0d0, e: 0.0d0, i: 0.0d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
  t = DINDGEN(100) * period / 99.0d0

  result = propagate_orbit(elements, t, t0, mars)

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
