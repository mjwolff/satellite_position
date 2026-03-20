;+
; NAME:
;   TEST_MARS_CONSTANTS
;
; PURPOSE:
;   Unit test for the mars_constants() function. Verifies that all required
;   fields are present and contain physically reasonable values.
;
; CATEGORY:
;   Unit Testing / Orbital Mechanics
;
; CALLING SEQUENCE:
;   sp_test_mars_constants
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Prints test results to console (PASS/FAIL for each test)
;
; PROCEDURE:
;   Tests the following:
;   1. Function returns a structure
;   2. All required fields are present
;   3. Values are physically reasonable (positive, correct magnitude)
;   4. Derived values (f, e2) are correctly calculated
;
; EXAMPLE:
;   IDL> sp_test_mars_constants
;   TEST: mars_constants returns a structure ... PASS
;   TEST: Field 'mu' exists ... PASS
;   ...
;   All tests passed (7/7)
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

PRO sp_test_mars_constants

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for sp_mars_constants()'
  print, '========================================='
  print, ''

  ; Call the function
  mars = sp_mars_constants()

  ; TEST 1: Verify function returns a structure
  n_tests++
  test_name = 'sp_mars_constants returns a structure'
  if (SIZE(mars, /TYPE) eq 8) then begin  ; 8 = structure type
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
  endelse

  ; TEST 2: Verify all required fields exist
  required_fields = ['mu', 'r_eq', 'r_pol', 'f', 'e2', 'omega_mars', 'obliquity', 'ref_epoch']

  foreach field, required_fields do begin
    n_tests++
    test_name = "Field '" + field + "' exists"
    tag_index = WHERE(TAG_NAMES(mars) eq STRUPCASE(field), count)
    if (count eq 1) then begin
      print, 'TEST: ' + test_name + ' ... PASS'
      n_passed++
    endif else begin
      print, 'TEST: ' + test_name + ' ... FAIL'
    endelse
  endforeach

  ; TEST 3: Verify mu is positive and reasonable
  n_tests++
  test_name = 'mu is positive and in expected range'
  expected_mu = 42828.37d0
  if (mars.mu gt 0 AND ABS(mars.mu - expected_mu) lt 0.01d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected_mu, ' Got: ', mars.mu
  endelse

  ; TEST 4: Verify r_eq > r_pol (Mars is oblate)
  n_tests++
  test_name = 'r_eq > r_pol (oblate spheroid)'
  if (mars.r_eq gt mars.r_pol) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  r_eq: ', mars.r_eq, ' r_pol: ', mars.r_pol
  endelse

  ; TEST 5: Verify flattening factor calculation
  n_tests++
  test_name = 'Flattening factor f = (r_eq - r_pol) / r_eq'
  f_expected = (mars.r_eq - mars.r_pol) / mars.r_eq
  if (ABS(mars.f - f_expected) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', f_expected, ' Got: ', mars.f
  endelse

  ; TEST 6: Verify eccentricity squared calculation
  n_tests++
  test_name = 'Eccentricity squared e2 = f * (2 - f)'
  e2_expected = mars.f * (2.0d0 - mars.f)
  if (ABS(mars.e2 - e2_expected) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', e2_expected, ' Got: ', mars.e2
  endelse

  ; TEST 7: Verify omega_mars is positive and reasonable
  n_tests++
  test_name = 'omega_mars is positive and in expected range'
  expected_omega = 7.088218d-5  ; rad/s
  if (mars.omega_mars gt 0 AND ABS(mars.omega_mars - expected_omega) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected_omega, ' Got: ', mars.omega_mars
  endelse

  ; TEST 8: Verify obliquity is positive and reasonable
  n_tests++
  test_name = 'obliquity is positive and in expected range'
  expected_obliquity = 25.19d0 * (!DPI/180.0d0)  ; radians
  if (mars.obliquity gt 0 AND ABS(mars.obliquity - expected_obliquity) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', expected_obliquity, ' Got: ', mars.obliquity
  endelse

  ; TEST 9: Verify all values are double precision
  n_tests++
  test_name = 'All numeric fields use double precision'
  all_double = 1b  ; boolean flag

  if (SIZE(mars.mu, /TYPE) ne 5) then all_double = 0b
  if (SIZE(mars.r_eq, /TYPE) ne 5) then all_double = 0b
  if (SIZE(mars.r_pol, /TYPE) ne 5) then all_double = 0b
  if (SIZE(mars.f, /TYPE) ne 5) then all_double = 0b
  if (SIZE(mars.e2, /TYPE) ne 5) then all_double = 0b
  if (SIZE(mars.omega_mars, /TYPE) ne 5) then all_double = 0b
  if (SIZE(mars.obliquity, /TYPE) ne 5) then all_double = 0b
  if (SIZE(mars.ref_epoch, /TYPE) ne 5) then all_double = 0b

  if (all_double) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
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
