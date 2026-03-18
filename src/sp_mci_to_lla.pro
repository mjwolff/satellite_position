;+
; NAME:
;   SP_MCI_TO_LLA
;
; PURPOSE:
;   Converts position from Mars-Centered Inertial (MCI) frame to
;   Longitude/Latitude/Altitude coordinates.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   result = sp_mci_to_lla(r_mci, t, constants)
;
; INPUTS:
;   r_mci     - Position vector in MCI frame [3] (km)
;   t         - Current time (seconds since epoch)
;   constants - Mars constants structure from sp_mars_constants()
;
; OUTPUTS:
;   Structure containing:
;     .lon - Longitude (degrees), range [-180, 180] or [0, 360]
;     .lat - Geodetic latitude (degrees)
;     .alt - Altitude above reference ellipsoid (km)
;
; ALGORITHM:
;   1. Transform MCI to Mars-fixed frame (account for rotation)
;   2. Calculate longitude: lon = atan2(y_fixed, x_fixed)
;   3. Calculate geodetic latitude and altitude iteratively
;
; EXAMPLE:
;   IDL> mars = sp_mars_constants()
;   IDL> r_mci = [10000.0d0, 0.0d0, 0.0d0]
;   IDL> t = 0.0d0
;   IDL> result = sp_mci_to_lla(r_mci, t, mars)
;   IDL> print, result.lon, result.lat, result.alt
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION sp_mci_to_lla, r_mci, t, constants

  COMPILE_OPT IDL2, HIDDEN

  ; Transform from MCI to Mars-fixed frame
  r_fixed = sp_mci_to_mars_fixed(r_mci, t, constants.ref_epoch, constants.omega_mars)

  ; Calculate longitude
  ; lon = atan2(y, x)
  lon = ATAN(r_fixed[1], r_fixed[0])

  ; Convert to degrees and normalize to [-180, 180]
  lon_deg = lon * !RADEG
  if (lon_deg gt 180.0d0) then lon_deg = lon_deg - 360.0d0
  if (lon_deg lt -180.0d0) then lon_deg = lon_deg + 360.0d0

  ; Calculate geodetic latitude and altitude
  geo_result = sp_calculate_geodetic_latitude(r_fixed[0], r_fixed[1], r_fixed[2], $
                                               constants.r_eq, constants.e2)

  ; Convert latitude to degrees
  lat_deg = geo_result.lat * !RADEG

  ; Return result structure
  result = { $
    lon: lon_deg, $
    lat: lat_deg, $
    alt: geo_result.h $
  }

  RETURN, result

END
