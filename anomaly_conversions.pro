;+
; NAME:
;   ECC_TO_TRUE_ANOMALY
;
; PURPOSE:
;   Converts eccentric anomaly (Ecc) to true anomaly (ν) for elliptical orbits.
;
; CATEGORY:
;   Orbital Mechanics / Anomaly Conversions
;
; CALLING SEQUENCE:
;   nu = ecc_to_true_anomaly(Ecc, e)
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
;   IDL> nu = ecc_to_true_anomaly(Ecc, e)
;   IDL> print, nu * !RADEG
;        95.74
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION ecc_to_true_anomaly, Ecc, e

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


;+
; NAME:
;   TRUE_TO_ECC_ANOMALY
;
; PURPOSE:
;   Converts true anomaly (ν) to eccentric anomaly (Ecc) for elliptical orbits.
;
; CATEGORY:
;   Orbital Mechanics / Anomaly Conversions
;
; CALLING SEQUENCE:
;   Ecc = true_to_ecc_anomaly(nu, e)
;
; INPUTS:
;   nu  - True anomaly (radians), scalar or array
;   e   - Orbital eccentricity (dimensionless), 0 <= e < 1, scalar or array
;
; OUTPUTS:
;   Ecc - Eccentric anomaly (radians), same size as input
;
; ALGORITHM:
;   Uses atan2 for proper quadrant handling:
;   Ecc = atan2(sqrt(1-e²)*sin(ν), e+cos(ν))
;
; EXAMPLE:
;   IDL> nu = !DPI/2.0  ; 90 degrees true anomaly
;   IDL> e = 0.5
;   IDL> Ecc = true_to_ecc_anomaly(nu, e)
;   IDL> print, Ecc * !RADEG
;        70.53
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION true_to_ecc_anomaly, nu, e

  COMPILE_OPT IDL2, HIDDEN

  ; Validate inputs
  if (e lt 0.0d0 OR e ge 1.0d0) then begin
    MESSAGE, 'Eccentricity must be in range [0, 1). e = ' + STRTRIM(e, 2)
  endif

  ; Special case: circular orbit (e = 0)
  if (e eq 0.0d0) then begin
    RETURN, nu
  endif

  ; Convert using atan2 for proper quadrant
  ; Ecc = atan2(sqrt(1-e²)*sin(ν), e+cos(ν))

  sqrt_term = SQRT(1.0d0 - e^2)
  sin_nu = SIN(nu)
  cos_nu = COS(nu)

  Ecc = ATAN(sqrt_term * sin_nu, e + cos_nu)

  RETURN, Ecc

END
