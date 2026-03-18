PRO run_all_tests
  COMPILE_OPT IDL2

  ; Setup path
  !PATH = 'src:tests' + ':' + !PATH

  print, ''
  print, '========================================='
  print, 'Running ALL Unit and Integration Tests'
  print, '========================================='
  print, ''

  ; Run each test
  print, '--- Test 1: Mars Constants ---'
  test_mars_constants
  print, ''

  print, '--- Test 2: Kepler Solver ---'
  test_kepler_solver
  print, ''

  print, '--- Test 3: Anomaly Conversions ---'
  test_anomaly_conversions
  print, ''

  print, '--- Test 4: Coordinate Transforms ---'
  test_coordinate_transforms
  print, ''

  print, '--- Test 5: MCI to LLA ---'
  test_mci_to_lla
  print, ''

  print, '--- Test 6: Subsolar Latitude ---'
  test_subsolar_latitude
  print, ''

  print, '--- Test 7: Propagate Orbit ---'
  test_propagate_orbit
  print, ''

  print, '--- Test 8: Orbit Propagation (Integration) ---'
  test_orbit_propagation
  print, ''

  print, '========================================='
  print, 'ALL TESTS COMPLETED'
  print, '========================================='
  print, ''

END
