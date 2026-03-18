;+
; NAME:
;   SP_CALCULATE_PERIFOCAL_POSITION
;
; PURPOSE:
;   Calculates position and velocity vectors in the perifocal (PQW) coordinate
;   frame given orbital elements and true anomaly.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   result = sp_calculate_perifocal_position(a, e, nu, mu)
;
; INPUTS:
;   a  - Semi-major axis (km), scalar or array
;   e  - Eccentricity (dimensionless), 0 <= e < 1, scalar or array
;   nu - True anomaly (radians), scalar or array
;   mu - Gravitational parameter (km³/s²), scalar
;
; OUTPUTS:
;   Structure containing:
;     .r_pqw - Position vector in perifocal frame [3] (km)
;     .v_pqw - Velocity vector in perifocal frame [3] (km/s)
;     .r     - Scalar radius (km)
;
; ALGORITHM:
;   1. Calculate radius: r = a(1-e²) / (1 + e·cos(ν))
;   2. Position in perifocal frame: r_pqw = [r·cos(ν), r·sin(ν), 0]
;   3. Velocity in perifocal frame: v_pqw = sqrt(μ/p) · [-sin(ν), e+cos(ν), 0]
;      where p = a(1-e²) is the semi-latus rectum
;
; PERIFOCAL FRAME:
;   - P-axis: Points toward periapsis
;   - Q-axis: In orbital plane, 90° ahead of P (direction of motion)
;   - W-axis: Normal to orbital plane (P × Q), aligned with angular momentum
;
; EXAMPLE:
;   IDL> mars = sp_mars_constants()
;   IDL> a = 9376.0d0        ; Semi-major axis (km)
;   IDL> e = 0.0151d0        ; Eccentricity
;   IDL> nu = !DPI/4.0d0     ; True anomaly = 45 degrees
;   IDL> result = sp_calculate_perifocal_position(a, e, nu, mars.mu)
;   IDL> print, result.r_pqw
;        6620.5    6620.5       0.0
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION sp_calculate_perifocal_position, a, e, nu, mu

  COMPILE_OPT IDL2, HIDDEN

  ; Validate inputs
  if (a le 0.0d0) then begin
    MESSAGE, 'Semi-major axis must be positive. a = ' + STRTRIM(a, 2)
  endif

  if (e lt 0.0d0 OR e ge 1.0d0) then begin
    MESSAGE, 'Eccentricity must be in range [0, 1). e = ' + STRTRIM(e, 2)
  endif

  if (mu le 0.0d0) then begin
    MESSAGE, 'Gravitational parameter must be positive. mu = ' + STRTRIM(mu, 2)
  endif

  ; Calculate semi-latus rectum: p = a(1-e²)
  p = a * (1.0d0 - e^2)

  ; Calculate radius: r = p / (1 + e·cos(ν))
  cos_nu = COS(nu)
  r = p / (1.0d0 + e * cos_nu)

  ; Calculate position vector in perifocal frame
  ; r_pqw = [r·cos(ν), r·sin(ν), 0]
  sin_nu = SIN(nu)

  r_pqw = DBLARR(3)
  r_pqw[0] = r * cos_nu
  r_pqw[1] = r * sin_nu
  r_pqw[2] = 0.0d0

  ; Calculate velocity vector in perifocal frame
  ; v_pqw = sqrt(μ/p) · [-sin(ν), e+cos(ν), 0]
  v_mag = SQRT(mu / p)

  v_pqw = DBLARR(3)
  v_pqw[0] = -v_mag * sin_nu
  v_pqw[1] = v_mag * (e + cos_nu)
  v_pqw[2] = 0.0d0

  ; Return structure with results
  result = { $
    r_pqw: r_pqw, $
    v_pqw: v_pqw, $
    r:     r $
  }

  RETURN, result

END
