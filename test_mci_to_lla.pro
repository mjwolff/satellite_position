;+
; NAME:
;   TEST_MCI_TO_LLA
;
; PURPOSE:
;   Unit test for mci_to_lla.pro functions
;
; CATEGORY:
;   Unit Testing / Orbital Mechanics
;
; CALLING SEQUENCE:
;   test_mci_to_lla
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

PRO test_mci_to_lla

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for mci_to_lla'
  print, '========================================='
  print, ''

  ; Get Mars constants
  .compile mars_constants.pro
  mars = mars_constants()

  print, '--- Testing MCI to Mars-Fixed Rotation ---'
  print, ''

  ; TEST 1: Zero rotation at t = t_ref
  n_tests++
  test_name = 'Zero rotation: t = t_ref'
  r_mci = [10000.0d0, 5000.0d0, 3000.0d0]
  t = 0.0d0
  t_ref = 0.0d0

  r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, mars.omega_mars)
  error = MAX(ABS(r_fixed - r_mci))

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Input:  ', r_mci
    print, '  Output: ', r_fixed
  endelse

  ; TEST 2: 90-degree rotation
  ; After Mars rotates 90°, X-axis points to where Y-axis was
  n_tests++
  test_name = '90° rotation about Z-axis'
  r_mci = [10000.0d0, 0.0d0, 0.0d0]
  ; Time for 90° rotation: t = π/(2·omega_mars)
  t = !DPI / (2.0d0 * mars.omega_mars)
  t_ref = 0.0d0

  r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, mars.omega_mars)
  expected = [0.0d0, 10000.0d0, 0.0d0]
  error = MAX(ABS(r_fixed - expected))

  if (error lt 1.0d0) then begin  ; 1 km tolerance
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected
    print, '  Got:      ', r_fixed
  endelse

  ; TEST 3: 180-degree rotation
  n_tests++
  test_name = '180° rotation about Z-axis'
  r_mci = [10000.0d0, 0.0d0, 0.0d0]
  ; Time for 180° rotation: t = π/omega_mars
  t = !DPI / mars.omega_mars
  t_ref = 0.0d0

  r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, mars.omega_mars)
  expected = [-10000.0d0, 0.0d0, 0.0d0]
  error = MAX(ABS(r_fixed - expected))

  if (error lt 1.0d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected
    print, '  Got:      ', r_fixed
  endelse

  ; TEST 4: Z-component unchanged
  n_tests++
  test_name = 'Z-component remains unchanged'
  r_mci = [10000.0d0, 5000.0d0, 7500.0d0]
  t = 1234.5d0
  t_ref = 0.0d0

  r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, mars.omega_mars)

  if (ABS(r_fixed[2] - r_mci[2]) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Input Z:  ', r_mci[2]
    print, '  Output Z: ', r_fixed[2]
  endelse

  ; TEST 5: Magnitude preservation
  n_tests++
  test_name = 'Rotation preserves magnitude'
  r_mci = [10000.0d0, 5000.0d0, 3000.0d0]
  t = 5432.1d0
  t_ref = 0.0d0

  r_mag_mci = SQRT(TOTAL(r_mci^2))
  r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, mars.omega_mars)
  r_mag_fixed = SQRT(TOTAL(r_fixed^2))

  error = ABS(r_mag_fixed - r_mag_mci)

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Magnitude error: ', error
  endelse

  ; TEST 6: Round-trip conversion
  n_tests++
  test_name = 'Round-trip: MCI → Fixed → MCI'
  r_mci_original = [10000.0d0, 5000.0d0, 3000.0d0]
  t = 3600.0d0
  t_ref = 0.0d0

  r_fixed = mci_to_mars_fixed(r_mci_original, t, t_ref, mars.omega_mars)
  r_mci_final = mars_fixed_to_mci(r_fixed, t, t_ref, mars.omega_mars)

  error = MAX(ABS(r_mci_final - r_mci_original))

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Original: ', r_mci_original
    print, '  Final:    ', r_mci_final
    print, '  Error:    ', error
  endelse

  ; TEST 7: Non-zero reference time
  n_tests++
  test_name = 'Non-zero reference time'
  r_mci = [10000.0d0, 0.0d0, 0.0d0]
  t = 3600.0d0
  t_ref = 3600.0d0  ; Same as t, so no rotation

  r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, mars.omega_mars)
  error = MAX(ABS(r_fixed - r_mci))

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected no rotation, got error: ', error
  endelse

  ; TEST 8: Full Mars rotation (one sidereal day)
  n_tests++
  test_name = 'Full Mars rotation (~24.6 hours)'
  r_mci = [10000.0d0, 5000.0d0, 3000.0d0]
  ; One Mars sidereal day = 2π / omega_mars
  t = 2.0d0 * !DPI / mars.omega_mars
  t_ref = 0.0d0

  r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, mars.omega_mars)
  error = MAX(ABS(r_fixed - r_mci))

  if (error lt 1.0d0) then begin  ; Should return to original position
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Mars day = ', t / 3600.0d0, ' hours'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Error after full rotation: ', error
  endelse

  print, ''
  print, '--- Testing Geodetic Latitude Calculator ---'
  print, ''

  ; TEST 9: Equator (lat = 0)
  n_tests++
  test_name = 'Equator: lat=0°'
  x_fixed = 10000.0d0
  y_fixed = 0.0d0
  z_fixed = 0.0d0

  result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, mars.r_eq, mars.e2)

  if (result.converged AND ABS(result.lat) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Iterations: ', result.n_iter
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Latitude: ', result.lat * !RADEG, ' degrees'
    print, '  Converged: ', result.converged
  endelse

  ; TEST 10: North pole (lat = 90°)
  n_tests++
  test_name = 'North pole: lat=90°'
  x_fixed = 0.0d0
  y_fixed = 0.0d0
  z_fixed = mars.r_pol + 1000.0d0  ; 1000 km above pole

  result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, mars.r_eq, mars.e2)
  expected_lat = !DPI / 2.0d0

  if (result.converged AND ABS(result.lat - expected_lat) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: 90°, Got: ', result.lat * !RADEG, ' degrees'
  endelse

  ; TEST 11: South pole (lat = -90°)
  n_tests++
  test_name = 'South pole: lat=-90°'
  x_fixed = 0.0d0
  y_fixed = 0.0d0
  z_fixed = -(mars.r_pol + 500.0d0)

  result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, mars.r_eq, mars.e2)
  expected_lat = -!DPI / 2.0d0

  if (result.converged AND ABS(result.lat - expected_lat) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: -90°, Got: ', result.lat * !RADEG, ' degrees'
  endelse

  ; TEST 12: Convergence speed (should converge in < 10 iterations)
  n_tests++
  test_name = 'Convergence in < 10 iterations'
  x_fixed = 8000.0d0
  y_fixed = 5000.0d0
  z_fixed = 3000.0d0

  result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, mars.r_eq, mars.e2)

  if (result.converged AND result.n_iter lt 10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Iterations: ', result.n_iter
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Iterations: ', result.n_iter, ' Converged: ', result.converged
  endelse

  ; TEST 13: Accuracy (tolerance < 1e-8 degrees)
  n_tests++
  test_name = 'Accuracy < 1e-8 degrees'
  x_fixed = 7500.0d0
  y_fixed = 4000.0d0
  z_fixed = 2500.0d0

  result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, mars.r_eq, mars.e2, tol=1e-14)

  ; Test that it converges to high precision
  if (result.converged) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Latitude: ', result.lat * !RADEG, ' degrees'
    print, '  Altitude: ', result.h, ' km'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
  endelse

  ; TEST 14: On surface (altitude ≈ 0)
  n_tests++
  test_name = 'On surface: altitude ≈ 0'
  ; Point on equator at surface
  x_fixed = mars.r_eq
  y_fixed = 0.0d0
  z_fixed = 0.0d0

  result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, mars.r_eq, mars.e2)

  if (result.converged AND ABS(result.h) lt 1.0d0) then begin  ; 1 km tolerance
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Altitude: ', result.h, ' km'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Altitude: ', result.h, ' km (expected ≈ 0)'
  endelse

  ; TEST 15: 45° latitude
  n_tests++
  test_name = '45° latitude calculation'
  lat_target = !DPI / 4.0d0  ; 45 degrees
  h_test = 1000.0d0  ; 1000 km altitude

  ; Calculate expected position for 45° latitude
  sin_lat = SIN(lat_target)
  cos_lat = COS(lat_target)
  N = mars.r_eq / SQRT(1.0d0 - mars.e2 * sin_lat^2)

  x_fixed = (N + h_test) * cos_lat
  y_fixed = 0.0d0
  z_fixed = (N * (1.0d0 - mars.e2) + h_test) * sin_lat

  result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, mars.r_eq, mars.e2)

  error_lat = ABS(result.lat - lat_target)
  error_h = ABS(result.h - h_test)

  if (result.converged AND error_lat lt 1e-8 AND error_h lt 1.0d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Lat error: ', error_lat * !RADEG, ' deg, Alt error: ', error_h, ' km'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected lat: ', lat_target * !RADEG, ' Got: ', result.lat * !RADEG
    print, '  Expected h: ', h_test, ' Got: ', result.h
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
