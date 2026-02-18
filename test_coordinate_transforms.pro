;+
; NAME:
;   TEST_COORDINATE_TRANSFORMS
;
; PURPOSE:
;   Unit test for coordinate transformation functions in coordinate_transforms.pro
;
; CATEGORY:
;   Unit Testing / Orbital Mechanics
;
; CALLING SEQUENCE:
;   test_coordinate_transforms
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

PRO test_coordinate_transforms

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for coordinate_transforms'
  print, '========================================='
  print, ''

  ; Get Mars constants
  .compile mars_constants.pro
  mars = mars_constants()

  ; TEST 1: Circular orbit at periapsis (nu=0)
  n_tests++
  test_name = 'Circular orbit: nu=0, r=a'
  a = 9376.0d0
  e = 0.0d0
  nu = 0.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)

  ; For circular orbit, r should equal a
  if (ABS(result.r - a) lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected r=', a, ' Got:', result.r
  endelse

  ; TEST 2: Circular orbit position vector at nu=0
  n_tests++
  test_name = 'Circular orbit: position at nu=0 is [a, 0, 0]'
  a = 9376.0d0
  e = 0.0d0
  nu = 0.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  expected_pos = [a, 0.0d0, 0.0d0]
  error = MAX(ABS(result.r_pqw - expected_pos))

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected:', expected_pos
    print, '  Got:     ', result.r_pqw
  endelse

  ; TEST 3: Circular orbit velocity at nu=0
  ; For circular orbit, v = sqrt(μ/a) tangent to radius
  n_tests++
  test_name = 'Circular orbit: velocity at nu=0 is [0, v_circ, 0]'
  a = 9376.0d0
  e = 0.0d0
  nu = 0.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  v_circ = SQRT(mars.mu / a)
  expected_vel = [0.0d0, v_circ, 0.0d0]
  error = MAX(ABS(result.v_pqw - expected_vel))

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  v_circ = ', v_circ, ' km/s'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected:', expected_vel
    print, '  Got:     ', result.v_pqw
  endelse

  ; TEST 4: Eccentric orbit at periapsis
  ; r_periapsis = a(1-e)
  n_tests++
  test_name = 'Eccentric orbit: periapsis radius r=a(1-e)'
  a = 10000.0d0
  e = 0.5d0
  nu = 0.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  r_periapsis = a * (1.0d0 - e)
  error = ABS(result.r - r_periapsis)

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  r_peri = ', result.r, ' km (expected: ', r_periapsis, ')'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected:', r_periapsis, ' Got:', result.r
  endelse

  ; TEST 5: Eccentric orbit at apoapsis
  ; r_apoapsis = a(1+e)
  n_tests++
  test_name = 'Eccentric orbit: apoapsis radius r=a(1+e)'
  a = 10000.0d0
  e = 0.5d0
  nu = !DPI

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  r_apoapsis = a * (1.0d0 + e)
  error = ABS(result.r - r_apoapsis)

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  r_apo = ', result.r, ' km (expected: ', r_apoapsis, ')'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected:', r_apoapsis, ' Got:', result.r
  endelse

  ; TEST 6: Position vector perpendicular to velocity vector
  ; r · v should be zero at periapsis and apoapsis
  n_tests++
  test_name = 'At periapsis: r ⊥ v (dot product = 0)'
  a = 10000.0d0
  e = 0.3d0
  nu = 0.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  dot_product = TOTAL(result.r_pqw * result.v_pqw)

  if (ABS(dot_product) lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Dot product:', dot_product, ' (should be ~0)'
  endelse

  ; TEST 7: Specific energy conservation
  ; E = v²/2 - μ/r = -μ/(2a) for elliptical orbits
  n_tests++
  test_name = 'Specific energy E = -μ/(2a) at nu=π/4'
  a = 10000.0d0
  e = 0.4d0
  nu = !DPI / 4.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  v_mag = SQRT(TOTAL(result.v_pqw^2))
  E_actual = 0.5d0 * v_mag^2 - mars.mu / result.r
  E_expected = -mars.mu / (2.0d0 * a)
  error = ABS(E_actual - E_expected)

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  E = ', E_actual, ' km²/s²'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected:', E_expected, ' Got:', E_actual
  endelse

  ; TEST 8: Angular momentum magnitude
  ; h = sqrt(μ·a·(1-e²)) = sqrt(μ·p)
  n_tests++
  test_name = 'Angular momentum h = sqrt(μ·p)'
  a = 10000.0d0
  e = 0.6d0
  nu = !DPI / 3.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  ; h = r × v
  h_vec = DBLARR(3)
  h_vec[0] = result.r_pqw[1] * result.v_pqw[2] - result.r_pqw[2] * result.v_pqw[1]
  h_vec[1] = result.r_pqw[2] * result.v_pqw[0] - result.r_pqw[0] * result.v_pqw[2]
  h_vec[2] = result.r_pqw[0] * result.v_pqw[1] - result.r_pqw[1] * result.v_pqw[0]

  h_mag = SQRT(TOTAL(h_vec^2))
  p = a * (1.0d0 - e^2)
  h_expected = SQRT(mars.mu * p)
  error = ABS(h_mag - h_expected)

  if (error lt 1e-6) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  h = ', h_mag, ' km²/s'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected:', h_expected, ' Got:', h_mag
  endelse

  ; TEST 9: Angular momentum direction (should be in +W direction)
  n_tests++
  test_name = 'Angular momentum in +W direction: h = [0, 0, h_z]'
  a = 10000.0d0
  e = 0.3d0
  nu = !DPI / 6.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)
  ; h = r × v
  h_vec = DBLARR(3)
  h_vec[0] = result.r_pqw[1] * result.v_pqw[2] - result.r_pqw[2] * result.v_pqw[1]
  h_vec[1] = result.r_pqw[2] * result.v_pqw[0] - result.r_pqw[0] * result.v_pqw[2]
  h_vec[2] = result.r_pqw[0] * result.v_pqw[1] - result.r_pqw[1] * result.v_pqw[0]

  ; For perifocal frame, h should be purely in W (z) direction
  error_xy = SQRT(h_vec[0]^2 + h_vec[1]^2)

  if (error_xy lt 1e-6 AND h_vec[2] gt 0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  h vector:', h_vec
  endelse

  ; TEST 10: W-component is always zero
  n_tests++
  test_name = 'Position and velocity W-components are zero'
  a = 10000.0d0
  e = 0.7d0
  nu = !DPI / 2.0d0

  result = calculate_perifocal_position(a, e, nu, mars.mu)

  if (result.r_pqw[2] eq 0.0d0 AND result.v_pqw[2] eq 0.0d0) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  r_pqw[2]:', result.r_pqw[2], ' v_pqw[2]:', result.v_pqw[2]
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
