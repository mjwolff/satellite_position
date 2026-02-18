;+
; NAME:
;   TEST_ANOMALY_CONVERSIONS
;
; PURPOSE:
;   Unit test for the anomaly conversion functions (ecc_to_true_anomaly and
;   true_to_ecc_anomaly). Verifies round-trip conversion accuracy and
;   correctness for various test cases.
;
; CATEGORY:
;   Unit Testing / Orbital Mechanics
;
; CALLING SEQUENCE:
;   test_anomaly_conversions
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Prints test results to console (PASS/FAIL for each test)
;
; PROCEDURE:
;   Tests the following:
;   1. Round-trip conversion: Ecc → ν → Ecc
;   2. Round-trip conversion: ν → Ecc → ν
;   3. Circular orbit (e=0): ν = Ecc
;   4. Known test cases with analytical solutions
;   5. Edge cases: periapsis, apoapsis
;   6. Multiple eccentricity values
;
; EXAMPLE:
;   IDL> test_anomaly_conversions
;   =========================================
;   Running Unit Tests for anomaly_conversions
;   =========================================
;   ...
;   All tests passed (X/X)
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

PRO test_anomaly_conversions

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for anomaly_conversions'
  print, '========================================='
  print, ''

  ; TEST 1: Circular orbit (e=0) - ν should equal Ecc
  n_tests++
  test_name = 'Circular orbit: e=0, ν=Ecc'
  Ecc_test = !DPI / 4.0d0  ; 45 degrees
  e_test = 0.0d0
  nu = ecc_to_true_anomaly(Ecc_test, e_test)

  if (ABS(nu - Ecc_test) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', Ecc_test, ' Got: ', nu
  endelse

  ; TEST 2: Round-trip Ecc → ν → Ecc for e=0.5
  n_tests++
  test_name = 'Round-trip Ecc → ν → Ecc for e=0.5'
  Ecc_original = !DPI / 3.0d0  ; 60 degrees
  e_test = 0.5d0

  nu = ecc_to_true_anomaly(Ecc_original, e_test)
  Ecc_final = true_to_ecc_anomaly(nu, e_test)
  error = ABS(Ecc_final - Ecc_original)

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Error: ', error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Original: ', Ecc_original, ' Final: ', Ecc_final, ' Error: ', error
  endelse

  ; TEST 3: Round-trip ν → Ecc → ν for e=0.7
  n_tests++
  test_name = 'Round-trip ν → Ecc → ν for e=0.7'
  nu_original = !DPI / 4.0d0  ; 45 degrees
  e_test = 0.7d0

  Ecc = true_to_ecc_anomaly(nu_original, e_test)
  nu_final = ecc_to_true_anomaly(Ecc, e_test)
  error = ABS(nu_final - nu_original)

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Error: ', error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Original: ', nu_original, ' Final: ', nu_final, ' Error: ', error
  endelse

  ; TEST 4: Periapsis (ν = 0, Ecc = 0)
  n_tests++
  test_name = 'Periapsis: ν=0 → Ecc=0'
  nu_test = 0.0d0
  e_test = 0.5d0
  Ecc = true_to_ecc_anomaly(nu_test, e_test)

  if (ABS(Ecc) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected Ecc ≈ 0, Got: ', Ecc
  endelse

  ; TEST 5: Apoapsis (ν = π, Ecc = π)
  n_tests++
  test_name = 'Apoapsis: ν=π → Ecc=π'
  nu_test = !DPI
  e_test = 0.5d0
  Ecc = true_to_ecc_anomaly(nu_test, e_test)

  if (ABS(Ecc - !DPI) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected Ecc ≈ π, Got: ', Ecc
  endelse

  ; TEST 6: Known analytical case - e=0.5, Ecc=π/3
  ; For e=0.5, Ecc=60°, ν should be exactly 90° (π/2)
  ; Because cos(π/3)=0.5, so cos(Ecc)-e = 0
  n_tests++
  test_name = 'Known case: e=0.5, Ecc=60° → ν=90°'
  Ecc_test = !DPI / 3.0d0  ; 60 degrees
  e_test = 0.5d0
  nu = ecc_to_true_anomaly(Ecc_test, e_test)

  ; Expected value: exactly π/2 (90 degrees)
  nu_expected = !DPI / 2.0d0
  error = ABS(nu - nu_expected)

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  ν = ', nu * !RADEG, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', nu_expected * !RADEG, ' Got: ', nu * !RADEG, ' degrees'
  endelse

  ; TEST 7: Multiple eccentricity round-trip test
  n_tests++
  test_name = 'Eccentricity sweep e=[0.1, 0.3, 0.5, 0.7, 0.9]'
  e_array = [0.1d0, 0.3d0, 0.5d0, 0.7d0, 0.9d0]
  Ecc_test = !DPI / 4.0d0  ; 45 degrees
  max_error = 0.0d0
  all_passed = 1b

  foreach e_val, e_array do begin
    nu = ecc_to_true_anomaly(Ecc_test, e_val)
    Ecc_final = true_to_ecc_anomaly(nu, e_val)
    error = ABS(Ecc_final - Ecc_test)
    if (error gt max_error) then max_error = error
    if (error gt 1e-10) then all_passed = 0b
  endforeach

  if (all_passed) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max error across all e: ', max_error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max error: ', max_error
  endelse

  ; TEST 8: Full orbit sweep - ν from 0 to just before 2π
  ; Note: 2π wraps to 0, so we test [0, π/2, π, 3π/2] instead
  n_tests++
  test_name = 'Full orbit sweep: ν=[0, π/2, π, 3π/2]'
  nu_array = [0.0d0, !DPI/2.0d0, !DPI, 3.0d0*!DPI/2.0d0]
  e_test = 0.6d0
  max_error = 0.0d0
  all_passed = 1b

  foreach nu_val, nu_array do begin
    Ecc = true_to_ecc_anomaly(nu_val, e_test)
    nu_final = ecc_to_true_anomaly(Ecc, e_test)
    error = ABS(nu_final - nu_val)
    if (error gt max_error) then max_error = error
    if (error gt 1e-10) then all_passed = 0b
  endforeach

  if (all_passed) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max error across orbit: ', max_error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max error: ', max_error
  endelse

  ; TEST 9: Symmetry test - ν and -ν should give Ecc and -Ecc (modulo 2π)
  n_tests++
  test_name = 'Symmetry: ν and -ν conversion'
  nu_test = !DPI / 6.0d0  ; 30 degrees
  e_test = 0.4d0

  Ecc_pos = true_to_ecc_anomaly(nu_test, e_test)
  Ecc_neg = true_to_ecc_anomaly(-nu_test, e_test)

  ; For elliptical orbits, Ecc(-ν) should equal -Ecc(ν) (modulo 2π)
  error = ABS(Ecc_neg + Ecc_pos)

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Ecc(+ν): ', Ecc_pos, ' Ecc(-ν): ', Ecc_neg
  endelse

  ; TEST 10: High precision round-trip for e=0.99
  n_tests++
  test_name = 'High precision round-trip: e=0.99'
  Ecc_test = !DPI / 5.0d0  ; 36 degrees
  e_test = 0.99d0

  nu = ecc_to_true_anomaly(Ecc_test, e_test)
  Ecc_final = true_to_ecc_anomaly(nu, e_test)
  error = ABS(Ecc_final - Ecc_test)

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Error: ', error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Error: ', error
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
