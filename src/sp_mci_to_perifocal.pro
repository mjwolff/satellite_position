;+
; NAME:
;   SP_MCI_TO_PERIFOCAL
;
; PURPOSE:
;   Transforms position and velocity vectors from Mars-Centered Inertial (MCI)
;   frame to perifocal (PQW) frame using orbital elements.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   result = sp_mci_to_perifocal(r_mci, v_mci, raan, omega, i)
;
; INPUTS:
;   r_mci - Position vector in MCI frame [3] (km)
;   v_mci - Velocity vector in MCI frame [3] (km/s)
;   raan  - Right ascension of ascending node (radians)
;   omega - Argument of periapsis (radians)
;   i     - Inclination (radians), 0 <= i <= π
;
; OUTPUTS:
;   Structure containing:
;     .r_pqw - Position vector in perifocal frame [3] (km)
;     .v_pqw - Velocity vector in perifocal frame [3] (km/s)
;
; ALGORITHM:
;   Applies inverse rotation matrix: R^T = R^-1
;   Since rotation matrices are orthogonal: R^T = R^-1
;
; EXAMPLE:
;   IDL> r_mci = [10000.0d0, 0.0d0, 0.0d0]
;   IDL> v_mci = [0.0d0, 3.0d0, 0.0d0]
;   IDL> raan = 0.0d0
;   IDL> omega = 0.0d0
;   IDL> i = 0.0d0
;   IDL> result = sp_mci_to_perifocal(r_mci, v_mci, raan, omega, i)
;   IDL> print, result.r_pqw
;        10000.0       0.0       0.0
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION sp_mci_to_perifocal, r_mci, v_mci, raan, omega, i

  COMPILE_OPT IDL2, HIDDEN

  ; Validate inputs
  if (N_ELEMENTS(r_mci) ne 3) then begin
    MESSAGE, 'r_mci must be a 3-element vector'
  endif

  if (N_ELEMENTS(v_mci) ne 3) then begin
    MESSAGE, 'v_mci must be a 3-element vector'
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

  ; Build rotation matrix R^T (transpose = inverse for orthogonal matrices)
  ; R^T = [R3(-omega)]^T * [R1(-i)]^T * [R3(-raan)]^T
  ;     = R3(omega) * R1(i) * R3(raan)

  R_T = DBLARR(3, 3)

  ; Transpose of the perifocal_to_mci matrix
  ; First row (of R^T = columns of R)
  R_T[0,0] = cos_raan * cos_omega - sin_raan * sin_omega * cos_i
  R_T[1,0] = sin_raan * cos_omega + cos_raan * sin_omega * cos_i
  R_T[2,0] = sin_omega * sin_i

  ; Second row
  R_T[0,1] = -cos_raan * sin_omega - sin_raan * cos_omega * cos_i
  R_T[1,1] = -sin_raan * sin_omega + cos_raan * cos_omega * cos_i
  R_T[2,1] = cos_omega * sin_i

  ; Third row
  R_T[0,2] = sin_raan * sin_i
  R_T[1,2] = -cos_raan * sin_i
  R_T[2,2] = cos_i

  ; Transform position and velocity vectors
  r_pqw = R_T ## r_mci
  v_pqw = R_T ## v_mci

  ; Return structure with results
  result = { $
    r_pqw: r_pqw, $
    v_pqw: v_pqw $
  }

  RETURN, result

END
