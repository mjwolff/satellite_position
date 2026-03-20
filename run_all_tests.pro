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
  sp_test_mars_constants
  print, ''

  print, '--- Test 2: Kepler Solver ---'
  sp_test_kepler_solver
  print, ''

  print, '--- Test 3: Anomaly Conversions ---'
  sp_test_anomaly_conversions
  print, ''

  print, '--- Test 4: Coordinate Transforms ---'
  sp_test_coordinate_transforms
  print, ''

  print, '--- Test 5: MCI to LLA ---'
  sp_test_mci_to_lla
  print, ''

  print, '--- Test 6: Subsolar Latitude ---'
  sp_test_subsolar_latitude
  print, ''

  print, '--- Test 7: Propagate Orbit ---'
  sp_test_propagate_orbit
  print, ''

  print, '--- Test 8: Orbit Propagation (Integration) ---'
  sp_test_orbit_propagation
  print, ''

  print, '========================================='
  print, 'ALL TESTS COMPLETED'
  print, '========================================='
  print, ''

END
