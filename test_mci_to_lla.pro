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
