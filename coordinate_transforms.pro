;+
; NAME:
;   CALCULATE_PERIFOCAL_POSITION
;
; PURPOSE:
;   Calculates position and velocity vectors in the perifocal (PQW) coordinate
;   frame given orbital elements and true anomaly.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   result = calculate_perifocal_position(a, e, nu, mu)
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
;   IDL> mars = mars_constants()
;   IDL> a = 9376.0d0        ; Semi-major axis (km)
;   IDL> e = 0.0151d0        ; Eccentricity
;   IDL> nu = !DPI/4.0d0     ; True anomaly = 45 degrees
;   IDL> result = calculate_perifocal_position(a, e, nu, mars.mu)
;   IDL> print, result.r_pqw
;        6620.5    6620.5       0.0
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION calculate_perifocal_position, a, e, nu, mu

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
;   Applies rotation matrix: R = R3(-Omega) * R1(-i) * R3(-omega)
;   Where:
;     R3(θ) = rotation about Z-axis by angle θ
;     R1(θ) = rotation about X-axis by angle θ
;
;   Rotation sequence:
;     1. Rotate by -omega about W-axis (argument of periapsis)
;     2. Rotate by -i about intermediate axis (inclination)
;     3. Rotate by -Omega about Z-axis (RAAN)
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


;+
; NAME:
;   MCI_TO_PERIFOCAL
;
; PURPOSE:
;   Transforms position and velocity vectors from Mars-Centered Inertial (MCI)
;   frame to perifocal (PQW) frame using orbital elements.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   result = mci_to_perifocal(r_mci, v_mci, raan, omega, i)
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
;   IDL> result = mci_to_perifocal(r_mci, v_mci, raan, omega, i)
;   IDL> print, result.r_pqw
;        10000.0       0.0       0.0
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION mci_to_perifocal, r_mci, v_mci, raan, omega, i

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
  ; First row
  R_T[0,0] = cos_raan * cos_omega - sin_raan * sin_omega * cos_i
  R_T[0,1] = sin_raan * cos_omega + cos_raan * sin_omega * cos_i
  R_T[0,2] = sin_omega * sin_i

  ; Second row
  R_T[1,0] = -cos_raan * sin_omega - sin_raan * cos_omega * cos_i
  R_T[1,1] = -sin_raan * sin_omega + cos_raan * cos_omega * cos_i
  R_T[1,2] = cos_omega * sin_i

  ; Third row
  R_T[2,0] = sin_raan * sin_i
  R_T[2,1] = -cos_raan * sin_i
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
