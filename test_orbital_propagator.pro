;+
; NAME:
;   TEST_ORBITAL_PROPAGATOR
;
; PURPOSE:
;   Unit test for orbital_propagator.pro
;
; CATEGORY:
;   Unit Testing / Orbital Mechanics
;
; CALLING SEQUENCE:
;   test_orbital_propagator
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

PRO test_orbital_propagator

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for orbital_propagator'
  print, '========================================='
  print, ''

  ; Get Mars constants
  .compile mars_constants.pro
  mars = mars_constants()

  ; TEST 1: All output fields present
  n_tests++
  test_name = 'All output fields present'

  elements = {a: 10000.0d0, e: 0.0d0, i: 0.0d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t = 0.0d0
  t0 = 0.0d0

  result = propagate_orbit(elements, t, t0, mars)

  ; Check that all expected fields exist
  has_t = TAG_EXIST(result, 't')
  has_M = TAG_EXIST(result, 'M')
  has_Ecc = TAG_EXIST(result, 'Ecc')
  has_nu = TAG_EXIST(result, 'nu')
  has_r = TAG_EXIST(result, 'r')
  has_r_pqw = TAG_EXIST(result, 'r_pqw')
  has_v_pqw = TAG_EXIST(result, 'v_pqw')
  has_r_mci = TAG_EXIST(result, 'r_mci')
  has_v_mci = TAG_EXIST(result, 'v_mci')
  has_lon = TAG_EXIST(result, 'lon')
  has_lat = TAG_EXIST(result, 'lat')
  has_alt = TAG_EXIST(result, 'alt')

  all_fields = has_t AND has_M AND has_Ecc AND has_nu AND has_r AND $
               has_r_pqw AND has_v_pqw AND has_r_mci AND has_v_mci AND $
               has_lon AND has_lat AND has_alt

  if (all_fields) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Missing fields'
  endelse

  ; TEST 2: Circular orbit - constant radius
  n_tests++
  test_name = 'Circular orbit: constant radius'

  elements = {a: 10000.0d0, e: 0.0d0, i: 0.0d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  period = 2.0d0 * !DPI * SQRT(elements.a^3 / mars.mu)
  t = DINDGEN(10) * period / 9.0d0  ; 10 points over one orbit

  result = propagate_orbit(elements, t, t0, mars)

  ; Check that radius is constant
  radii = DBLARR(N_ELEMENTS(result))
  for idx = 0, N_ELEMENTS(result) - 1 do begin
    radii[idx] = result[idx].r
  endfor

  std_dev = STDDEV(radii)
  mean_r = MEAN(radii)

  if (std_dev / mean_r lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Mean radius: ', mean_r, ' km'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Std dev / mean: ', std_dev / mean_r
  endelse

  ; TEST 3: Circular equatorial orbit - latitude ≈ 0
  n_tests++
  test_name = 'Circular equatorial: latitude ≈ 0°'

  elements = {a: 10000.0d0, e: 0.0d0, i: 0.0d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t = 0.0d0
  t0 = 0.0d0

  result = propagate_orbit(elements, t, t0, mars)

  if (ABS(result.lat) lt 1.0d0) then begin  ; Within 1 degree
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Latitude: ', result.lat, ' degrees'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Latitude: ', result.lat, ' degrees'
  endelse

  ; TEST 4: Mean anomaly progression
  n_tests++
  test_name = 'Mean anomaly increases linearly with time'

  elements = {a: 10000.0d0, e: 0.3d0, i: 0.5d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  t = DINDGEN(5) * 3600.0d0  ; Every hour for 5 hours

  result = propagate_orbit(elements, t, t0, mars)

  ; Mean anomaly should increase monotonically
  monotonic = 1b
  for idx = 1, N_ELEMENTS(result) - 1 do begin
    if (result[idx].M le result[idx-1].M) then monotonic = 0b
  endfor

  if (monotonic) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
  endelse

  ; TEST 5: Eccentric orbit - periapsis and apoapsis radii
  n_tests++
  test_name = 'Eccentric orbit: r_peri and r_apo correct'

  a = 15000.0d0
  e = 0.5d0
  elements = {a: a, e: e, i: 0.0d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0

  ; At t=0, M=0, so at periapsis
  result_peri = propagate_orbit(elements, 0.0d0, t0, mars)

  ; At apoapsis, M = π
  n = SQRT(mars.mu / a^3)
  t_apo = !DPI / n  ; Time when M = π
  result_apo = propagate_orbit(elements, t_apo, t0, mars)

  r_peri_expected = a * (1.0d0 - e)
  r_apo_expected = a * (1.0d0 + e)

  error_peri = ABS(result_peri.r - r_peri_expected)
  error_apo = ABS(result_apo.r - r_apo_expected)

  if (error_peri lt 1.0d0 AND error_apo lt 1.0d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  r_peri: ', result_peri.r, ' (expected: ', r_peri_expected, ')'
    print, '  r_apo:  ', result_apo.r, ' (expected: ', r_apo_expected, ')'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Periapsis error: ', error_peri, ' km'
    print, '  Apoapsis error:  ', error_apo, ' km'
  endelse

  ; TEST 6: Energy conservation
  n_tests++
  test_name = 'Energy conservation: E = -μ/(2a)'

  elements = {a: 12000.0d0, e: 0.4d0, i: 0.3d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  t = DINDGEN(10) * 1000.0d0

  result = propagate_orbit(elements, t, t0, mars)

  ; Calculate specific energy at each point
  E_expected = -mars.mu / (2.0d0 * elements.a)
  max_error = 0.0d0

  for idx = 0, N_ELEMENTS(result) - 1 do begin
    v_mag = SQRT(TOTAL(result[idx].v_mci^2))
    E_actual = 0.5d0 * v_mag^2 - mars.mu / result[idx].r
    error = ABS((E_actual - E_expected) / E_expected)
    if (error gt max_error) then max_error = error
  endfor

  if (max_error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max relative error: ', max_error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Max relative error: ', max_error
  endelse

  ; TEST 7: Single vs array input consistency
  n_tests++
  test_name = 'Single vs array input consistency'

  elements = {a: 10000.0d0, e: 0.2d0, i: 0.0d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t0 = 0.0d0
  t_test = 3600.0d0

  ; Single time
  result_single = propagate_orbit(elements, t_test, t0, mars)

  ; Array with one element
  result_array = propagate_orbit(elements, [t_test], t0, mars)

  ; Compare results
  error_r = MAX(ABS(result_single.r_mci - result_array[0].r_mci))
  error_v = MAX(ABS(result_single.v_mci - result_array[0].v_mci))

  if (error_r lt 1e-10 AND error_v lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Position error: ', error_r
    print, '  Velocity error: ', error_v
  endelse

  ; TEST 8: Altitude is reasonable
  n_tests++
  test_name = 'Altitude values are reasonable'

  elements = {a: 9376.0d0, e: 0.0151d0, i: 0.0d0, Omega: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  t = 0.0d0
  t0 = 0.0d0

  result = propagate_orbit(elements, t, t0, mars)

  ; Altitude should be positive and less than radius
  altitude_ok = (result.alt gt 0.0d0 AND result.alt lt elements.a)

  if (altitude_ok) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Altitude: ', result.alt, ' km'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Altitude: ', result.alt, ' km'
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

; Helper function to check if a tag exists in a structure
FUNCTION TAG_EXIST, structure, tag_name
  tags = TAG_NAMES(structure)
  return, TOTAL(tags eq STRUPCASE(tag_name)) gt 0
END
