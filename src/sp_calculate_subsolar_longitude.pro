;+
; NAME:
;   SP_CALCULATE_SUBSOLAR_LONGITUDE
;
; PURPOSE:
;   Calculates the sub-solar longitude on Mars (longitude where the Sun is
;   directly overhead) as a function of time, given a reference epoch at
;   which the sub-solar longitude is known.
;
;   The sub-solar longitude cannot be derived from areocentric solar longitude
;   (L_s) alone — it also depends on Mars's rotational phase at a reference
;   epoch. As Mars rotates eastward, the sub-solar footprint moves westward
;   in the Mars-fixed frame.
;
; CATEGORY:
;   Mars Climate / Orbital Mechanics
;
; CALLING SEQUENCE:
;   ss_lon = sp_calculate_subsolar_longitude(t, t_ref, ss_lon_ref, constants
;                                            [, /RANGE_180])
;
; INPUTS:
;   t          - Time(s) at which to evaluate sub-solar longitude
;                (seconds from propagation epoch; scalar or array)
;   t_ref      - Reference time at which ss_lon_ref is defined
;                (seconds from propagation epoch; scalar)
;   ss_lon_ref - Sub-solar longitude at t_ref
;                (degrees, range -180 to 180; scalar)
;   constants  - Mars constants structure from sp_mars_constants()
;                Uses the .omega_mars field (Mars rotation rate, rad/s)
;
; KEYWORDS:
;   range_180  - If set, return ss_lon in the range [-180, 180].
;                By default, ss_lon is returned in the range [0, 360].
;
; OUTPUTS:
;   Sub-solar longitude in degrees, range [0, 360] by default,
;   or [-180, 180] if /RANGE_180 is set.
;   Same size as input t.
;
; ALGORITHM:
;   As Mars rotates eastward at rate omega_mars, the sub-solar footprint
;   moves westward at the same rate:
;
;     delta_lon = -(t - t_ref) * omega_mars  [radians]
;     ss_lon(t) = ss_lon_ref + delta_lon     [wrapped to -180, 180]
;
;   Unless /RANGE_180 is set, ss_lon is then converted to [0, 360]:
;
;     ss_lon = (ss_lon + 360) MOD 360
;
; EXAMPLE:
;   IDL> mars = sp_mars_constants()
;   IDL> ; After one full Mars sidereal day (~88,642 s), longitude returns to start
;   IDL> ss_lon = sp_calculate_subsolar_longitude(88642.0d0, 0.0d0, 0.0d0, mars)
;   IDL> print, ss_lon        ; Should be ~0.0 (full rotation)
;
;   IDL> ; After 60 seconds, footprint shifts ~0.244 degrees westward (0,360 default)
;   IDL> ss_lon = sp_calculate_subsolar_longitude(60.0d0, 0.0d0, 0.0d0, mars)
;   IDL> print, ss_lon        ; Should be ~359.756
;
;   IDL> ; Same result expressed in [-180, 180] convention
;   IDL> ss_lon = sp_calculate_subsolar_longitude(60.0d0, 0.0d0, 0.0d0, mars, /RANGE_180)
;   IDL> print, ss_lon        ; Should be ~-0.244
;
; NOTES:
;   - The reference sub-solar longitude ss_lon_ref is a simulation parameter
;     describing which Mars-fixed longitude faces the Sun at the epoch.
;     It must be supplied by the user based on mission geometry.
;   - Peer function: sp_calculate_subsolar_latitude gives the sub-solar
;     latitude from areocentric solar longitude L_s.
;   - Mars sidereal rotation period: 2*pi / omega_mars ~ 88,642 seconds
;
; MODIFICATION HISTORY:
;   2026-03-18: Initial implementation
;   2026-03-20: Add /RANGE_180 keyword; default output range changed to [0, 360]
;-

FUNCTION sp_calculate_subsolar_longitude, t, t_ref, ss_lon_ref, constants, $
    RANGE_180=range_180

  COMPILE_OPT IDL2, HIDDEN

  ; Longitude shift: negative because Mars rotates east -> footprint moves west
  delta_lon = -(t - t_ref) * constants.omega_mars * (180.0d0/!DPI)

  ; Wrap to [-180, 180].
  ; Double-MOD required: IDL's MOD preserves the sign of the dividend,
  ; so a single MOD can return negative values. Adding 360 before the
  ; second MOD ensures a positive intermediate result.
  ss_lon = ((ss_lon_ref + delta_lon + 180.0d0) MOD 360.0d0 + 360.0d0) MOD 360.0d0 - 180.0d0

  ; Convert to [0, 360] unless caller requested [-180, 180]
  IF ~KEYWORD_SET(range_180) THEN $
    ss_lon = (ss_lon + 360.0d0) MOD 360.0d0

  RETURN, ss_lon

END
