;+
; NAME:
;   SP_TEST_SUBSOLAR_LONGITUDE
;
; PURPOSE:
;   Unit test for the sp_calculate_subsolar_longitude() function. Verifies correct
;   calculation of Mars sub-solar longitude, including default [0, 360] output range
;   and the /RANGE_180 keyword for [-180, 180] output.
;
; CATEGORY:
;   Unit Testing / Mars Climate
;
; CALLING SEQUENCE:
;   sp_test_subsolar_longitude
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Prints test results to console (PASS/FAIL for each test)
;
; PROCEDURE:
;   Tests the following:
;   1. Full sidereal rotation returns to starting longitude (default [0,360])
;   2. Full sidereal rotation returns to starting longitude (/RANGE_180)
;   3. Short time step, default [0,360] output
;   4. Short time step, /RANGE_180 output
;   5. Consistency: default and /RANGE_180 encode the same angle
;   6. Reference longitude offset applied correctly
;   7. Wrapping at 0/360 boundary (default convention)
;   8. Wrapping at ±180 boundary (/RANGE_180 convention)
;   9. Output range validation, default [0, 360]
;  10. Output range validation, /RANGE_180 [-180, 180]
;  11. Array input processing
;
; EXAMPLE:
;   IDL> sp_test_subsolar_longitude
;   =========================================
;   Running Unit Tests for sp_calculate_subsolar_longitude
;   =========================================
;   ...
;   SUCCESS: All tests passed!
;
; MODIFICATION HISTORY:
;   2026-03-20: Initial implementation
;-

PRO sp_test_subsolar_longitude

  COMPILE_OPT IDL2
  COMMON sp_test_results, tc_n_tests, tc_n_passed

  n_tests  = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for sp_calculate_subsolar_longitude'
  print, '========================================='
  print, ''

  mars = sp_mars_constants()
  ; One full sidereal Mars day in seconds
  t_sol = 2.0d0 * !DPI / mars.omega_mars

  ; =========================================
  ; TEST 1: Full rotation returns to start (default [0, 360])
  ; =========================================
  n_tests++
  test_name = 'Full rotation: returns to ss_lon_ref (default [0,360])'
  ss_lon = sp_calculate_subsolar_longitude(t_sol, 0.0d0, 0.0d0, mars)
  expected = 0.0d0
  if (ABS(ss_lon - expected) lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, '  Got: ', ss_lon
  endelse

  ; =========================================
  ; TEST 2: Full rotation returns to start (/RANGE_180)
  ; =========================================
  n_tests++
  test_name = 'Full rotation: returns to ss_lon_ref (/RANGE_180)'
  ss_lon = sp_calculate_subsolar_longitude(t_sol, 0.0d0, 0.0d0, mars, /RANGE_180)
  expected = 0.0d0
  if (ABS(ss_lon - expected) lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, '  Got: ', ss_lon
  endelse

  ; =========================================
  ; TEST 3: Short time step gives westward shift, default [0, 360]
  ; After 60 s, footprint shifts ~0.244 deg west -> ~359.756 in [0,360]
  ; =========================================
  n_tests++
  test_name = 'Short step (60 s): westward shift in [0,360]'
  t_short = 60.0d0
  delta_deg = t_short * mars.omega_mars * (180.0d0/!DPI)  ; ~0.244 deg
  expected = 360.0d0 - delta_deg
  ss_lon = sp_calculate_subsolar_longitude(t_short, 0.0d0, 0.0d0, mars)
  if (ABS(ss_lon - expected) lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  ss_lon = ', ss_lon, ' deg'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, '  Got: ', ss_lon
  endelse

  ; =========================================
  ; TEST 4: Short time step, /RANGE_180 gives negative value
  ; =========================================
  n_tests++
  test_name = 'Short step (60 s): westward shift in [-180,180]'
  expected = -delta_deg
  ss_lon = sp_calculate_subsolar_longitude(t_short, 0.0d0, 0.0d0, mars, /RANGE_180)
  if (ABS(ss_lon - expected) lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  ss_lon = ', ss_lon, ' deg'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, '  Got: ', ss_lon
  endelse

  ; =========================================
  ; TEST 5: Default and /RANGE_180 encode the same angle
  ; =========================================
  n_tests++
  test_name = 'Consistency: default and /RANGE_180 encode same angle'
  ss_lon_360 = sp_calculate_subsolar_longitude(t_short, 0.0d0, 45.0d0, mars)
  ss_lon_180 = sp_calculate_subsolar_longitude(t_short, 0.0d0, 45.0d0, mars, /RANGE_180)
  ; Convert both to [0,360] for comparison
  norm_360 = ss_lon_360
  norm_180 = (ss_lon_180 + 360.0d0) MOD 360.0d0
  if (ABS(norm_360 - norm_180) lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  [0,360] = ', ss_lon_360, '  [−180,180] = ', ss_lon_180
  endelse

  ; =========================================
  ; TEST 6: Non-zero ss_lon_ref is applied correctly
  ; After half a sidereal day, footprint moves 180 deg -> ref+180 wraps to ref
  ; =========================================
  n_tests++
  test_name = 'Half rotation from 90 deg ref: result = 270 deg ([0,360])'
  t_half = t_sol / 2.0d0
  ss_lon = sp_calculate_subsolar_longitude(t_half, 0.0d0, 90.0d0, mars)
  expected = 270.0d0
  if (ABS(ss_lon - expected) lt 1e-4) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected, '  Got: ', ss_lon
  endelse

  ; =========================================
  ; TEST 7: Wrapping at 0/360 boundary (default)
  ; Starting near 0 and shifting west -> should wrap to near 360
  ; =========================================
  n_tests++
  test_name = 'Wrap at 0/360 boundary: stays in [0,360]'
  ss_lon = sp_calculate_subsolar_longitude(t_short, 0.0d0, 1.0d0, mars)
  in_range = (ss_lon ge 0.0d0) AND (ss_lon lt 360.0d0)
  if in_range then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  ss_lon = ', ss_lon, ' deg'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  ss_lon = ', ss_lon, ' (out of [0,360))'
  endelse

  ; =========================================
  ; TEST 8: Wrapping at ±180 boundary (/RANGE_180)
  ; Starting near -179, shifting west -> wraps to near +180
  ; =========================================
  n_tests++
  test_name = 'Wrap at ±180 boundary: stays in [-180,180]'
  ; t chosen so shift is ~2 deg, starting at -179 -> should wrap to +179
  t_wrap = 2.0d0 / (mars.omega_mars * (180.0d0/!DPI))
  ss_lon = sp_calculate_subsolar_longitude(t_wrap, 0.0d0, -179.0d0, mars, /RANGE_180)
  in_range = (ss_lon ge -180.0d0) AND (ss_lon le 180.0d0)
  if in_range then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  ss_lon = ', ss_lon, ' deg'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  ss_lon = ', ss_lon, ' (out of [-180,180])'
  endelse

  ; =========================================
  ; TEST 9: Output range validation, full cycle, default [0, 360]
  ; =========================================
  n_tests++
  test_name = 'Full cycle output range: all values in [0, 360)'
  t_array = DINDGEN(1000) * t_sol / 999.0d0
  ss_lon_arr = sp_calculate_subsolar_longitude(t_array, 0.0d0, 0.0d0, mars)
  all_in_range = (MIN(ss_lon_arr) ge 0.0d0) AND (MAX(ss_lon_arr) lt 360.0d0)
  if all_in_range then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Range: [', MIN(ss_lon_arr), ', ', MAX(ss_lon_arr), ']'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Min: ', MIN(ss_lon_arr), '  Max: ', MAX(ss_lon_arr)
  endelse

  ; =========================================
  ; TEST 10: Output range validation, full cycle, /RANGE_180
  ; =========================================
  n_tests++
  test_name = 'Full cycle output range: all values in [-180, 180]'
  ss_lon_arr = sp_calculate_subsolar_longitude(t_array, 0.0d0, 0.0d0, mars, /RANGE_180)
  all_in_range = (MIN(ss_lon_arr) ge -180.0d0) AND (MAX(ss_lon_arr) le 180.0d0)
  if all_in_range then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Range: [', MIN(ss_lon_arr), ', ', MAX(ss_lon_arr), ']'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Min: ', MIN(ss_lon_arr), '  Max: ', MAX(ss_lon_arr)
  endelse

  ; =========================================
  ; TEST 11: Array input: output size matches input size
  ; =========================================
  n_tests++
  test_name = 'Array input: output size matches input size'
  t_vec = [0.0d0, 1000.0d0, 5000.0d0, 10000.0d0, t_sol]
  ss_lon_vec = sp_calculate_subsolar_longitude(t_vec, 0.0d0, 0.0d0, mars)
  if (N_ELEMENTS(ss_lon_vec) eq N_ELEMENTS(t_vec)) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Processed ', N_ELEMENTS(t_vec), ' elements'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Input size: ', N_ELEMENTS(t_vec), '  Output size: ', N_ELEMENTS(ss_lon_vec)
  endelse

  ; Print summary
  print, ''
  print, '========================================='
  print, 'Test Summary'
  print, '========================================='
  print, 'Total tests: ', STRTRIM(n_tests, 2)
  print, 'Passed:      ', STRTRIM(n_passed, 2)
  print, 'Failed:      ', STRTRIM(n_tests - n_passed, 2)

  tc_n_tests  = n_tests
  tc_n_passed = n_passed

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
