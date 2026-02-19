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
