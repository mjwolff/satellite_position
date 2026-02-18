;+
; NAME:
;   MCI_TO_MARS_FIXED
;
; PURPOSE:
;   Transforms position vector from Mars-Centered Inertial (MCI) frame to
;   Mars-fixed (rotating) frame by accounting for Mars rotation.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   r_fixed = mci_to_mars_fixed(r_mci, t, t_ref, omega_mars)
;
; INPUTS:
;   r_mci      - Position vector in MCI frame [3] (km)
;   t          - Current time (seconds since epoch)
;   t_ref      - Reference time when Mars rotation angle is zero (seconds)
;   omega_mars - Mars rotation rate (rad/s)
;
; OUTPUTS:
;   r_fixed - Position vector in Mars-fixed frame [3] (km)
;
; ALGORITHM:
;   1. Calculate rotation angle: θ = omega_mars · (t - t_ref)
;   2. Apply rotation about Z-axis:
;      x_fixed =  x_mci·cos(θ) + y_mci·sin(θ)
;      y_fixed = -x_mci·sin(θ) + y_mci·cos(θ)
;      z_fixed =  z_mci
;
; MARS-FIXED FRAME:
;   - Rotates with Mars
;   - Longitude is defined relative to this frame
;   - Prime meridian at reference time aligns with X-axis of MCI
;
; EXAMPLE:
;   IDL> mars = mars_constants()
;   IDL> r_mci = [10000.0d0, 0.0d0, 0.0d0]
;   IDL> t = 3600.0d0  ; 1 hour
;   IDL> r_fixed = mci_to_mars_fixed(r_mci, t, 0.0d0, mars.omega_mars)
;   IDL> print, r_fixed
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION mci_to_mars_fixed, r_mci, t, t_ref, omega_mars

  COMPILE_OPT IDL2, HIDDEN

  ; Validate inputs
  if (N_ELEMENTS(r_mci) ne 3) then begin
    MESSAGE, 'r_mci must be a 3-element vector'
  endif

  ; Calculate rotation angle
  ; θ = omega_mars · (t - t_ref)
  theta = omega_mars * (t - t_ref)

  ; Pre-compute trigonometric values
  cos_theta = COS(theta)
  sin_theta = SIN(theta)

  ; Apply Z-axis rotation matrix
  ; R3(θ) = [cos(θ)   sin(θ)   0]
  ;         [-sin(θ)  cos(θ)   0]
  ;         [0        0        1]

  r_fixed = DBLARR(3)
  r_fixed[0] =  r_mci[0] * cos_theta + r_mci[1] * sin_theta
  r_fixed[1] = -r_mci[0] * sin_theta + r_mci[1] * cos_theta
  r_fixed[2] =  r_mci[2]

  RETURN, r_fixed

END


;+
; NAME:
;   MARS_FIXED_TO_MCI
;
; PURPOSE:
;   Transforms position vector from Mars-fixed (rotating) frame to
;   Mars-Centered Inertial (MCI) frame.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   r_mci = mars_fixed_to_mci(r_fixed, t, t_ref, omega_mars)
;
; INPUTS:
;   r_fixed    - Position vector in Mars-fixed frame [3] (km)
;   t          - Current time (seconds since epoch)
;   t_ref      - Reference time when Mars rotation angle is zero (seconds)
;   omega_mars - Mars rotation rate (rad/s)
;
; OUTPUTS:
;   r_mci - Position vector in MCI frame [3] (km)
;
; ALGORITHM:
;   1. Calculate rotation angle: θ = omega_mars · (t - t_ref)
;   2. Apply inverse rotation (rotation by -θ) about Z-axis
;
; EXAMPLE:
;   IDL> mars = mars_constants()
;   IDL> r_fixed = [10000.0d0, 0.0d0, 0.0d0]
;   IDL> t = 3600.0d0
;   IDL> r_mci = mars_fixed_to_mci(r_fixed, t, 0.0d0, mars.omega_mars)
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION mars_fixed_to_mci, r_fixed, t, t_ref, omega_mars

  COMPILE_OPT IDL2, HIDDEN

  ; Validate inputs
  if (N_ELEMENTS(r_fixed) ne 3) then begin
    MESSAGE, 'r_fixed must be a 3-element vector'
  endif

  ; Calculate rotation angle
  theta = omega_mars * (t - t_ref)

  ; Pre-compute trigonometric values
  cos_theta = COS(theta)
  sin_theta = SIN(theta)

  ; Apply inverse rotation (rotate by -θ)
  ; R3(-θ) = [cos(θ)  -sin(θ)   0]
  ;          [sin(θ)   cos(θ)   0]
  ;          [0        0        1]

  r_mci = DBLARR(3)
  r_mci[0] = r_fixed[0] * cos_theta - r_fixed[1] * sin_theta
  r_mci[1] = r_fixed[0] * sin_theta + r_fixed[1] * cos_theta
  r_mci[2] = r_fixed[2]

  RETURN, r_mci

END
