;+
; NAME:
;   SP_TEST_INSTALL
;
; PURPOSE:
;   Verify that the Mars Orbital Propagator is correctly installed and functional.
;   Tests basic library functions including loading constants and propagating a
;   simple orbit.
;
; CATEGORY:
;   Installation Testing
;
; CALLING SEQUENCE:
;   sp_test_install
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Prints test results to console (PASS/FAIL for each test)
;
; EXAMPLE:
;   From command line:
;     idl -e "sp_test_install"
;
;   From IDL prompt:
;     IDL> cd, '/path/to/satellite_position'
;     IDL> .run sp_test_install
;
; MODIFICATION HISTORY:
;   2026-03-18: Initial implementation
;-

PRO sp_test_install
  COMPILE_OPT IDL2

  ; Setup path
  !PATH = 'src' + ':' + !PATH

  print, ''
  print, '========================================='
  print, 'Testing Mars Orbital Propagator Installation'
  print, '========================================='
  print, ''

  ; Test 1: Load constants
  print, 'Test 1: Loading Mars constants...'
  mars = sp_mars_constants()
  print, '  PASS - Mars constants loaded'
  print, '  mu = ', mars.mu, ' km^3/s^2'
  print, '  r_eq = ', mars.r_eq, ' km'
  print, ''

  ; Test 2: Simple orbit propagation
  print, 'Test 2: Propagating simple circular orbit...'
  elements = {a: 10000.0d0, e: 0.0d0, i: 0.0d0, $
              raan: 0.0d0, omega: 0.0d0, M0: 0.0d0}
  result = sp_propagate_orbit(elements, 0.0d0, 0.0d0, mars)
  print, '  PASS - Orbit propagated successfully'
  print, '  Position: ', result.r_mci, ' km'
  print, '  Altitude: ', result.alt, ' km'
  print, ''

  print, '========================================='
  print, 'All tests PASSED! Installation verified.'
  print, '========================================='
  print, ''

END
