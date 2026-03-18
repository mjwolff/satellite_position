;+
; NAME:
;   PERIFOCAL_TO_MCI
;
; PURPOSE:
;   Transforms position and velocity vectors from perifocal (PQW) frame to
;   Mars-Centered Inertial (MCI) frame using orbital elements.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   result = perifocal_to_mci(r_pqw, v_pqw, raan, omega, i)
;
; INPUTS:
;   r_pqw - Position vector in perifocal frame [3] (km)
;   v_pqw - Velocity vector in perifocal frame [3] (km/s)
;   raan  - Right ascension of ascending node (radians)
;   omega - Argument of periapsis (radians)
;   i     - Inclination (radians), 0 <= i <= π
;
; OUTPUTS:
;   Structure containing:
;     .r_mci - Position vector in MCI frame [3] (km)
;     .v_mci - Velocity vector in MCI frame [3] (km/s)
;
; ALGORITHM:
;   Applies rotation matrix: R = R3(-raan) * R1(-i) * R3(-omega)
;   Where:
;     R3(θ) = rotation about Z-axis by angle θ
;     R1(θ) = rotation about X-axis by angle θ
;
;   Rotation sequence:
;     1. Rotate by -omega about W-axis (argument of periapsis)
;     2. Rotate by -i about intermediate axis (inclination)
;     3. Rotate by -raan about Z-axis (RAAN)
;
; MCI FRAME:
;   - X-axis: Points toward vernal equinox (γ) - J2000 reference direction
;   - Z-axis: Along Mars rotation axis (north pole)
;   - Y-axis: Completes right-handed system (Z × X)
;
; EXAMPLE:
;   IDL> r_pqw = [10000.0d0, 0.0d0, 0.0d0]
;   IDL> v_pqw = [0.0d0, 3.0d0, 0.0d0]
;   IDL> raan = 0.0d0
;   IDL> omega = 0.0d0
;   IDL> i = 0.0d0
;   IDL> result = perifocal_to_mci(r_pqw, v_pqw, raan, omega, i)
;   IDL> print, result.r_mci
;        10000.0       0.0       0.0
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION perifocal_to_mci, r_pqw, v_pqw, raan, omega, i

  COMPILE_OPT IDL2, HIDDEN

  ; Validate inputs
  if (N_ELEMENTS(r_pqw) ne 3) then begin
    MESSAGE, 'r_pqw must be a 3-element vector'
  endif

  if (N_ELEMENTS(v_pqw) ne 3) then begin
    MESSAGE, 'v_pqw must be a 3-element vector'
  endif

  if (i lt 0.0d0 OR i gt !DPI) then begin
    MESSAGE, 'Inclination must be in range [0, π]. i = ' + STRTRIM(i, 2)
  endif

  ; Pre-compute trigonometric values
  cos_raan = COS(raan)
  sin_raan = SIN(raan)
  cos_omega = COS(omega)
  sin_omega = SIN(omega)
  cos_i = COS(i)
  sin_i = SIN(i)

  ; Build rotation matrix R = R3(-raan) * R1(-i) * R3(-omega)
  ; This is the combined transformation from perifocal to MCI
  ;
  ; R3(-raan) rotates about Z-axis by -raan
  ; R1(-i) rotates about X-axis by -i
  ; R3(-omega) rotates about Z-axis by -omega

  R = DBLARR(3, 3)

  ; First row
  R[0,0] = cos_raan * cos_omega - sin_raan * sin_omega * cos_i
  R[0,1] = -cos_raan * sin_omega - sin_raan * cos_omega * cos_i
  R[0,2] = sin_raan * sin_i

  ; Second row
  R[1,0] = sin_raan * cos_omega + cos_raan * sin_omega * cos_i
  R[1,1] = -sin_raan * sin_omega + cos_raan * cos_omega * cos_i
  R[1,2] = -cos_raan * sin_i

  ; Third row
  R[2,0] = sin_omega * sin_i
  R[2,1] = cos_omega * sin_i
  R[2,2] = cos_i

  ; Transform position and velocity vectors
  r_mci = R ## r_pqw
  v_mci = R ## v_pqw

  ; Return structure with results
  result = { $
    r_mci: r_mci, $
    v_mci: v_mci $
  }

  RETURN, result

END
