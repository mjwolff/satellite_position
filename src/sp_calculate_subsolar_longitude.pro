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
;   ss_lon = sp_calculate_subsolar_longitude(t, t_ref, ss_lon_ref, constants)
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
; OUTPUTS:
;   Sub-solar longitude in degrees, range [-180, 180]
;   Same size as input t
;
; ALGORITHM:
;   As Mars rotates eastward at rate omega_mars, the sub-solar footprint
;   moves westward at the same rate:
;
;     delta_lon = -(t - t_ref) * omega_mars  [radians]
;     ss_lon(t) = ss_lon_ref + delta_lon     [wrapped to -180, 180]
;
; EXAMPLE:
;   IDL> mars = sp_mars_constants()
;   IDL> ; After one full Mars sidereal day (~88,642 s), longitude returns to start
;   IDL> ss_lon = sp_calculate_subsolar_longitude(88642.0d0, 0.0d0, 0.0d0, mars)
;   IDL> print, ss_lon        ; Should be ~0.0 (full rotation)
;
;   IDL> ; After 60 seconds, longitude shifts ~-0.244 degrees
;   IDL> ss_lon = sp_calculate_subsolar_longitude(60.0d0, 0.0d0, 0.0d0, mars)
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
;-

FUNCTION sp_calculate_subsolar_longitude, t, t_ref, ss_lon_ref, constants

  COMPILE_OPT IDL2, HIDDEN

  ; Longitude shift: negative because Mars rotates east -> footprint moves west
  delta_lon = -(t - t_ref) * constants.omega_mars * !RADEG

  ; Wrap to [-180, 180].
  ; Double-MOD required: IDL's MOD preserves the sign of the dividend,
  ; so a single MOD can return negative values. Adding 360 before the
  ; second MOD ensures a positive intermediate result.
  ss_lon = ((ss_lon_ref + delta_lon + 180.0d0) MOD 360.0d0 + 360.0d0) MOD 360.0d0 - 180.0d0

  RETURN, ss_lon

END
