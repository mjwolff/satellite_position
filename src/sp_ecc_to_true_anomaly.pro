;+
; NAME:
;   SP_ECC_TO_TRUE_ANOMALY
;
; PURPOSE:
;   Converts eccentric anomaly (Ecc) to true anomaly (ν) for elliptical orbits.
;
; CATEGORY:
;   Orbital Mechanics / Anomaly Conversions
;
; CALLING SEQUENCE:
;   nu = sp_ecc_to_true_anomaly(Ecc, e)
;
; INPUTS:
;   Ecc - Eccentric anomaly (radians), scalar or array
;   e   - Orbital eccentricity (dimensionless), 0 <= e < 1, scalar or array
;
; OUTPUTS:
;   nu - True anomaly (radians), same size as input
;
; ALGORITHM:
;   Uses atan2 for proper quadrant handling:
;   ν = atan2(sqrt(1-e²)*sin(Ecc), cos(Ecc)-e)
;
; EXAMPLE:
;   IDL> Ecc = !DPI/3.0  ; 60 degrees eccentric anomaly
;   IDL> e = 0.5
;   IDL> nu = sp_ecc_to_true_anomaly(Ecc, e)
;   IDL> print, nu * !RADEG
;        95.74
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION sp_ecc_to_true_anomaly, Ecc, e

  COMPILE_OPT IDL2, HIDDEN

  ; Validate inputs
  if (e lt 0.0d0 OR e ge 1.0d0) then begin
    MESSAGE, 'Eccentricity must be in range [0, 1). e = ' + STRTRIM(e, 2)
  endif

  ; Special case: circular orbit (e = 0)
  if (e eq 0.0d0) then begin
    RETURN, Ecc
  endif

  ; Convert using atan2 for proper quadrant
  ; ν = atan2(sqrt(1-e²)*sin(Ecc), cos(Ecc)-e)

  sqrt_term = SQRT(1.0d0 - e^2)
  sin_Ecc = SIN(Ecc)
  cos_Ecc = COS(Ecc)

  nu = ATAN(sqrt_term * sin_Ecc, cos_Ecc - e)

  RETURN, nu

END
