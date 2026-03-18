;+
; NAME:
;   TEST_KEPLER_SOLVER
;
; PURPOSE:
;   Unit test for the sp_solve_kepler() function. Verifies Newton-Raphson
;   convergence, accuracy, and correctness of the solution to Kepler's equation.
;
; CATEGORY:
;   Unit Testing / Orbital Mechanics
;
; CALLING SEQUENCE:
;   test_kepler_solver
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Prints test results to console (PASS/FAIL for each test)
;
; PROCEDURE:
;   Tests the following:
;   1. Circular orbit (e=0): Ecc should equal M
;   2. Convergence for various eccentricities (e=0, 0.5, 0.9, 0.99)
;   3. Solution accuracy: verify M = Ecc - e*sin(Ecc) within tolerance
;   4. Iteration count within max_iter limit
;   5. Multiple mean anomaly values
;   6. Edge cases and error conditions
;
; EXAMPLE:
;   IDL> test_kepler_solver
;   =========================================
;   Running Unit Tests for sp_solve_kepler()
;   =========================================
;   ...
;   All tests passed (X/X)
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

PRO test_kepler_solver

  COMPILE_OPT IDL2

  ; Initialize test counter
  n_tests = 0
  n_passed = 0

  print, ''
  print, '========================================='
  print, 'Running Unit Tests for sp_solve_kepler()'
  print, '========================================='
  print, ''

  ; TEST 1: Circular orbit (e = 0) - Ecc should equal M
  n_tests++
  test_name = 'Circular orbit: e=0, Ecc=M'
  M_test = !DPI / 4.0d0  ; 45 degrees
  e_test = 0.0d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  if (conv AND ABS(Ecc - M_test) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected: ', M_test, ' Got: ', Ecc
  endelse

  ; TEST 2: Low eccentricity (e = 0.1)
  n_tests++
  test_name = 'Low eccentricity: e=0.1 convergence'
  M_test = !DPI / 3.0d0  ; 60 degrees
  e_test = 0.1d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  ; Verify Kepler's equation: M = Ecc - e*sin(Ecc)
  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed - M_test)

  if (conv AND error lt 1e-10 AND n_iter le 50) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Iterations: ', n_iter, ', Error: ', error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Converged: ', conv, ' Error: ', error, ' Iterations: ', n_iter
  endelse

  ; TEST 3: Moderate eccentricity (e = 0.5)
  n_tests++
  test_name = 'Moderate eccentricity: e=0.5 convergence'
  M_test = !DPI / 4.0d0  ; 45 degrees
  e_test = 0.5d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed - M_test)

  if (conv AND error lt 1e-10 AND n_iter le 50) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Iterations: ', n_iter, ', Error: ', error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Converged: ', conv, ' Error: ', error, ' Iterations: ', n_iter
  endelse

  ; TEST 4: High eccentricity (e = 0.9)
  n_tests++
  test_name = 'High eccentricity: e=0.9 convergence'
  M_test = !DPI / 2.0d0  ; 90 degrees
  e_test = 0.9d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed - M_test)

  if (conv AND error lt 1e-10 AND n_iter le 50) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Iterations: ', n_iter, ', Error: ', error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Converged: ', conv, ' Error: ', error, ' Iterations: ', n_iter
  endelse

  ; TEST 5: Very high eccentricity (e = 0.99)
  n_tests++
  test_name = 'Very high eccentricity: e=0.99 convergence'
  M_test = !DPI / 6.0d0  ; 30 degrees
  e_test = 0.99d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed - M_test)

  if (conv AND error lt 1e-10 AND n_iter le 50) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Iterations: ', n_iter, ', Error: ', error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Converged: ', conv, ' Error: ', error, ' Iterations: ', n_iter
  endelse

  ; TEST 6: M = 0 (at periapsis)
  n_tests++
  test_name = 'Mean anomaly M=0 (periapsis)'
  M_test = 0.0d0
  e_test = 0.5d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed - M_test)

  if (conv AND error lt 1e-10 AND ABS(Ecc) lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Expected Ecc ≈ 0, Got: ', Ecc
  endelse

  ; TEST 7: M = π (at apoapsis for circular orbit)
  n_tests++
  test_name = 'Mean anomaly M=π'
  M_test = !DPI
  e_test = 0.3d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed - M_test)

  if (conv AND error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Error: ', error
  endelse

  ; TEST 8: M = 2π (full orbit)
  n_tests++
  test_name = 'Mean anomaly M=2π (full orbit)'
  M_test = 2.0d0 * !DPI
  e_test = 0.4d0
  Ecc = sp_solve_kepler(M_test, e_test, n_iter=n_iter, converged=conv)

  ; Should normalize to M ≈ 0, so Ecc ≈ 0
  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed)  ; Should be near 0

  if (conv AND error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
    print, '  Ecc: ', Ecc, ' Error: ', error
  endelse

  ; TEST 9: Multiple eccentricity sweep
  n_tests++
  test_name = 'Eccentricity sweep e=[0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99]'
  e_array = [0.0d0, 0.1d0, 0.3d0, 0.5d0, 0.7d0, 0.9d0, 0.99d0]
  M_test = !DPI / 4.0d0
  all_converged = 1b
  max_error = 0.0d0

  foreach e_val, e_array do begin
    Ecc = sp_solve_kepler(M_test, e_val, n_iter=n_iter, converged=conv)
    M_computed = Ecc - e_val * SIN(Ecc)
    error = ABS(M_computed - M_test)
    if (error gt max_error) then max_error = error
    if (NOT conv OR error gt 1e-10 OR n_iter gt 50) then all_converged = 0b
  endforeach

  if (all_converged) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Max error across all e: ', max_error
    n_passed++
  endif else begin
    print, 'TEST: ' + test_name + ' ... FAIL'
  endelse

  ; TEST 10: Accuracy test - verify solution satisfies Kepler's equation
  n_tests++
  test_name = 'Solution accuracy for e=0.7, M=π/3'
  M_test = !DPI / 3.0d0
  e_test = 0.7d0
  Ecc = sp_solve_kepler(M_test, e_test, tol=1e-12, n_iter=n_iter, converged=conv)

  M_computed = Ecc - e_test * SIN(Ecc)
  error = ABS(M_computed - M_test)

  if (error lt 1e-10) then begin
    print, 'TEST: ' + test_name + ' ... PASS'
    print, '  Error: ', error, ' (tolerance: 1e-10)'
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
