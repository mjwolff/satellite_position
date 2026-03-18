;+
; NAME:
;   SP_LLA_TO_MCI
;
; PURPOSE:
;   Converts Longitude/Latitude/Altitude coordinates to position vector
;   in Mars-Centered Inertial (MCI) frame.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   r_mci = sp_lla_to_mci(lon, lat, alt, t, constants)
;
; INPUTS:
;   lon       - Longitude (degrees)
;   lat       - Geodetic latitude (degrees)
;   alt       - Altitude above reference ellipsoid (km)
;   t         - Current time (seconds since epoch)
;   constants - Mars constants structure from sp_mars_constants()
;
; OUTPUTS:
;   r_mci - Position vector in MCI frame [3] (km)
;
; ALGORITHM:
;   1. Convert lon, lat, alt to Cartesian Mars-fixed coordinates
;   2. Transform from Mars-fixed to MCI frame
;
; EXAMPLE:
;   IDL> mars = sp_mars_constants()
;   IDL> lon = 45.0d0  ; degrees
;   IDL> lat = 30.0d0  ; degrees
;   IDL> alt = 1000.0d0  ; km
;   IDL> t = 0.0d0
;   IDL> r_mci = sp_lla_to_mci(lon, lat, alt, t, mars)
;   IDL> print, r_mci
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION sp_lla_to_mci, lon, lat, alt, t, constants

  COMPILE_OPT IDL2, HIDDEN

  ; Convert to radians
  lon_rad = lon * !DTOR
  lat_rad = lat * !DTOR

  ; Calculate radius of curvature in prime vertical
  sin_lat = SIN(lat_rad)
  N = constants.r_eq / SQRT(1.0d0 - constants.e2 * sin_lat^2)

  ; Calculate Cartesian coordinates in Mars-fixed frame
  cos_lat = COS(lat_rad)
  cos_lon = COS(lon_rad)
  sin_lon = SIN(lon_rad)

  r_fixed = DBLARR(3)
  r_fixed[0] = (N + alt) * cos_lat * cos_lon
  r_fixed[1] = (N + alt) * cos_lat * sin_lon
  r_fixed[2] = (N * (1.0d0 - constants.e2) + alt) * sin_lat

  ; Transform from Mars-fixed to MCI frame
  r_mci = sp_mars_fixed_to_mci(r_fixed, t, constants.ref_epoch, constants.omega_mars)

  RETURN, r_mci

END
