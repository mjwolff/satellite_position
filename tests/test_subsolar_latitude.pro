;+
; NAME:
;   TEST_SUBSOLAR_LATITUDE
;
; PURPOSE:
;   Unit test for the calculate_subsolar_latitude() function. Verifies correct
;   calculation of Mars sub-solar latitude from areocentric solar longitude.
;
; CATEGORY:
;   Unit Testing / Mars Climate
;
; CALLING SEQUENCE:
;   test_subsolar_latitude
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Prints test results to console (PASS/FAIL for each test)
;
; PROCEDURE:
;   Tests the following:
;   1. Cardinal points in radians (Ls = 0, π/2, π, 3π/2)
;   2. Cardinal points in degrees (Ls = 0°, 90°, 180°, 270°)
;   3. Intermediate values (Ls = 30°, 45°, 135°)
;   4. Custom obliquity values
;   5. Array input processing
;   6. Output range validation
;   7. Precision and accuracy
;
; EXAMPLE:
;   IDL> test_subsolar_latitude
;   =========================================
;   Running Unit Tests for calculate_subsolar_latitude
;   =========================================
;   ...
;   All tests passed (X/X)
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

PRO test_subsolar_latitude

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for calculate_subsolar_latitude'
  print, '========================================='
  print, ''

  ; Get Mars constants for expected obliquity
  mars = mars_constants()
  expected_obliquity_deg = mars.obliquity * !RADEG

  ; =========================================
  ; TEST 1: Cardinal point - Spring Equinox (Ls = 0°, radians)
  ; =========================================
  n_tests++
  test_name = 'Spring equinox (Ls=0 rad): subsolar_lat=0'
  Ls_test = 0.0d0
  subsolar_lat = calculate_subsolar_latitude(Ls_test)

  if (ABS(subsolar_lat) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: 0.0, Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 2: Cardinal point - Summer Solstice (Ls = π/2, radians)
  ; =========================================
  n_tests++
  test_name = 'Summer solstice (Ls=π/2): subsolar_lat=+obliquity'
  Ls_test = !DPI / 2.0d0
  subsolar_lat = calculate_subsolar_latitude(Ls_test)
  expected = mars.obliquity

  if (ABS(subsolar_lat - expected) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, ' Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 3: Cardinal point - Autumn Equinox (Ls = π, radians)
  ; =========================================
  n_tests++
  test_name = 'Autumn equinox (Ls=π): subsolar_lat=0'
  Ls_test = !DPI
  subsolar_lat = calculate_subsolar_latitude(Ls_test)

  if (ABS(subsolar_lat) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: 0.0, Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 4: Cardinal point - Winter Solstice (Ls = 3π/2, radians)
  ; =========================================
  n_tests++
  test_name = 'Winter solstice (Ls=3π/2): subsolar_lat=-obliquity'
  Ls_test = 3.0d0 * !DPI / 2.0d0
  subsolar_lat = calculate_subsolar_latitude(Ls_test)
  expected = -mars.obliquity

  if (ABS(subsolar_lat - expected) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, ' Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 5: Cardinal points in DEGREES mode
  ; =========================================
  n_tests++
  test_name = 'Cardinal points with /DEGREES keyword'
  Ls_cardinal = [0.0d0, 90.0d0, 180.0d0, 270.0d0]
  expected_cardinal = [0.0d0, expected_obliquity_deg, 0.0d0, -expected_obliquity_deg]

  subsolar_cardinal = calculate_subsolar_latitude(Ls_cardinal, /DEGREES)

  max_error = MAX(ABS(subsolar_cardinal - expected_cardinal))

  if (max_error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max error: ', max_error, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected_cardinal
    print, '  Got:      ', subsolar_cardinal
    print, '  Max error: ', max_error
  endelse

  ; =========================================
  ; TEST 6: Intermediate value (Ls = 30°)
  ; =========================================
  n_tests++
  test_name = 'Intermediate value: Ls=30 degrees'
  Ls_test = 30.0d0
  subsolar_lat = calculate_subsolar_latitude(Ls_test, /DEGREES)
  ; Expected: 25.19 * sin(30°) = 25.19 * 0.5 = 12.595°
  expected = expected_obliquity_deg * SIN(30.0d0 * !DTOR)

  if (ABS(subsolar_lat - expected) lt 1e-8) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  subsolar_lat = ', subsolar_lat, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, ' Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 7: Intermediate value (Ls = 45°)
  ; =========================================
  n_tests++
  test_name = 'Intermediate value: Ls=45 degrees'
  Ls_test = 45.0d0
  subsolar_lat = calculate_subsolar_latitude(Ls_test, /DEGREES)
  ; Expected: 25.19 * sin(45°) = 25.19 * sqrt(2)/2 ≈ 17.81°
  expected = expected_obliquity_deg * SIN(45.0d0 * !DTOR)

  if (ABS(subsolar_lat - expected) lt 1e-8) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  subsolar_lat = ', subsolar_lat, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, ' Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 8: Intermediate value (Ls = 135°)
  ; =========================================
  n_tests++
  test_name = 'Intermediate value: Ls=135 degrees'
  Ls_test = 135.0d0
  subsolar_lat = calculate_subsolar_latitude(Ls_test, /DEGREES)
  ; Expected: 25.19 * sin(135°) = 25.19 * sqrt(2)/2 ≈ 17.81°
  expected = expected_obliquity_deg * SIN(135.0d0 * !DTOR)

  if (ABS(subsolar_lat - expected) lt 1e-8) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  subsolar_lat = ', subsolar_lat, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, ' Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 9: Custom obliquity (26 degrees)
  ; =========================================
  n_tests++
  test_name = 'Custom obliquity: 26 degrees at Ls=90'
  Ls_test = 90.0d0
  custom_obliquity = 26.0d0
  subsolar_lat = calculate_subsolar_latitude(Ls_test, /DEGREES, OBLIQUITY=custom_obliquity)
  expected = 26.0d0

  if (ABS(subsolar_lat - expected) lt 1e-5) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, ' Got: ', subsolar_lat
  endelse

  ; =========================================
  ; TEST 10: Array input processing
  ; =========================================
  n_tests++
  test_name = 'Array input: multiple Ls values'
  Ls_array = [0.0d0, 30.0d0, 60.0d0, 90.0d0, 120.0d0, 180.0d0, 270.0d0]
  subsolar_array = calculate_subsolar_latitude(Ls_array, /DEGREES)

  ; Verify array size matches
  if (N_ELEMENTS(subsolar_array) eq N_ELEMENTS(Ls_array)) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Processed ', N_ELEMENTS(Ls_array), ' elements'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Input size: ', N_ELEMENTS(Ls_array)
    print, '  Output size: ', N_ELEMENTS(subsolar_array)
  endelse

  ; =========================================
  ; TEST 11: Output range validation
  ; =========================================
  n_tests++
  test_name = 'Output range: within [-obliquity, +obliquity]'
  ; Test full seasonal cycle
  Ls_cycle = DINDGEN(361)
  subsolar_cycle = calculate_subsolar_latitude(Ls_cycle, /DEGREES)

  min_subsolar = MIN(subsolar_cycle)
  max_subsolar = MAX(subsolar_cycle)

  within_range = (min_subsolar ge -expected_obliquity_deg - 1e-6) AND $
                 (max_subsolar le expected_obliquity_deg + 1e-6)

  if (within_range) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Range: [', min_subsolar, ', ', max_subsolar, '] degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected range: [-', expected_obliquity_deg, ', +', expected_obliquity_deg, ']'
    print, '  Actual range: [', min_subsolar, ', ', max_subsolar, ']'
  endelse

  ; =========================================
  ; TEST 12: Precision test
  ; =========================================
  n_tests++
  test_name = 'High precision: analytical vs computed'
  ; Test Ls = 60° where sin(60°) = sqrt(3)/2 exactly
  Ls_test = 60.0d0 * !DTOR
  subsolar_lat = calculate_subsolar_latitude(Ls_test)
  expected = mars.obliquity * SQRT(3.0d0) / 2.0d0
  error = ABS(subsolar_lat - expected)

  if (error lt 1e-8) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Error: ', error, ' radians'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, ' Got: ', subsolar_lat
    print, '  Error: ', error
  endelse

  ; =========================================
  ; TEST 13: Negative Ls (should work)
  ; =========================================
  n_tests++
  test_name = 'Negative Ls: Ls=-90 degrees = Ls=270'
  Ls_neg = -90.0d0
  Ls_pos = 270.0d0
  subsolar_neg = calculate_subsolar_latitude(Ls_neg, /DEGREES)
  subsolar_pos = calculate_subsolar_latitude(Ls_pos, /DEGREES)

  if (ABS(subsolar_neg - subsolar_pos) lt 1e-8) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Ls=-90: ', subsolar_neg
    print, '  Ls=270: ', subsolar_pos
  endelse

  ; =========================================
  ; TEST 14: Ls > 360 degrees (should work)
  ; =========================================
  n_tests++
  test_name = 'Ls > 360: Ls=450 degrees = Ls=90'
  Ls_over = 450.0d0
  Ls_equiv = 90.0d0
  subsolar_over = calculate_subsolar_latitude(Ls_over, /DEGREES)
  subsolar_equiv = calculate_subsolar_latitude(Ls_equiv, /DEGREES)

  if (ABS(subsolar_over - subsolar_equiv) lt 1e-8) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Ls=450: ', subsolar_over
    print, '  Ls=90:  ', subsolar_equiv
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
