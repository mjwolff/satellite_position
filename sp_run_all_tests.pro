PRO sp_run_all_tests
  COMPILE_OPT IDL2
  COMMON sp_test_results, tc_n_tests, tc_n_passed

  ; Setup path
  !PATH = 'src:tests' + ':' + !PATH

  ; Storage for tabular summary
  n_suites = 8
  suite_names  = ['Mars Constants', 'Kepler Solver', 'Anomaly Conversions', $
                  'Coordinate Transforms', 'MCI to LLA', 'Subsolar Latitude', $
                  'Propagate Orbit', 'Orbit Propagation (Integration)']
  suite_passed = INTARR(n_suites)
  suite_total  = INTARR(n_suites)

  print, ''
  print, '========================================='
  print, 'Running ALL Unit and Integration Tests'
  print, '========================================='
  print, ''

  ; Run each test suite and capture counts via COMMON block
  print, '--- Test 1: Mars Constants ---'
  sp_test_mars_constants
  suite_passed[0] = tc_n_passed  &  suite_total[0] = tc_n_tests
  print, ''

  print, '--- Test 2: Kepler Solver ---'
  sp_test_kepler_solver
  suite_passed[1] = tc_n_passed  &  suite_total[1] = tc_n_tests
  print, ''

  print, '--- Test 3: Anomaly Conversions ---'
  sp_test_anomaly_conversions
  suite_passed[2] = tc_n_passed  &  suite_total[2] = tc_n_tests
  print, ''

  print, '--- Test 4: Coordinate Transforms ---'
  sp_test_coordinate_transforms
  suite_passed[3] = tc_n_passed  &  suite_total[3] = tc_n_tests
  print, ''

  print, '--- Test 5: MCI to LLA ---'
  sp_test_mci_to_lla
  suite_passed[4] = tc_n_passed  &  suite_total[4] = tc_n_tests
  print, ''

  print, '--- Test 6: Subsolar Latitude ---'
  sp_test_subsolar_latitude
  suite_passed[5] = tc_n_passed  &  suite_total[5] = tc_n_tests
  print, ''

  print, '--- Test 7: Propagate Orbit ---'
  sp_test_propagate_orbit
  suite_passed[6] = tc_n_passed  &  suite_total[6] = tc_n_tests
  print, ''

  print, '--- Test 8: Orbit Propagation (Integration) ---'
  sp_test_orbit_propagation
  suite_passed[7] = tc_n_passed  &  suite_total[7] = tc_n_tests
  print, ''

  ; =========================================
  ; Tabular summary
  ; =========================================
  total_passed = TOTAL(suite_passed)
  total_tests  = TOTAL(suite_total)
  divider = '-----  --------------------------------  ------  -----  ------'

  print, '========================================='
  print, 'ALL TESTS COMPLETED'
  print, '========================================='
  print, ''
  print, 'Suite  Name                              Passed  Total  Status'
  print, divider
  for idx = 0, n_suites - 1 do begin
    status = (suite_passed[idx] eq suite_total[idx]) ? 'PASS' : 'FAIL'
    print, FORMAT='(I4, "  ", A-32, "  ", I4, "  ", I4, "   ", A)', $
           idx+1, suite_names[idx], suite_passed[idx], suite_total[idx], status
  endfor
  print, divider
  overall = (total_passed eq total_tests) ? 'PASS' : 'FAIL'
  print, FORMAT='("TOTAL  ", A-32, "  ", I4, "  ", I4, "   ", A)', $
         '', FIX(total_passed), FIX(total_tests), overall
  print, ''

END
