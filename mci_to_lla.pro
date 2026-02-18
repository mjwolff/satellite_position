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


;+
; NAME:
;   CALCULATE_GEODETIC_LATITUDE
;
; PURPOSE:
;   Calculates geodetic latitude and altitude from Cartesian coordinates
;   in Mars-fixed frame using iterative algorithm.
;
; CATEGORY:
;   Orbital Mechanics / Geodetic Conversions
;
; CALLING SEQUENCE:
;   result = calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, r_eq, e2, $
;                                         tol=tol, max_iter=max_iter)
;
; INPUTS:
;   x_fixed - X-coordinate in Mars-fixed frame (km)
;   y_fixed - Y-coordinate in Mars-fixed frame (km)
;   z_fixed - Z-coordinate in Mars-fixed frame (km)
;   r_eq    - Equatorial radius (km)
;   e2      - Eccentricity squared of reference ellipsoid
;
; OPTIONAL KEYWORDS:
;   tol      - Convergence tolerance (radians, default: 1e-12)
;   max_iter - Maximum iterations (default: 10)
;
; OUTPUTS:
;   Structure containing:
;     .lat       - Geodetic latitude (radians)
;     .h         - Altitude above reference ellipsoid (km)
;     .n_iter    - Number of iterations taken
;     .converged - Boolean flag: 1 if converged, 0 if failed
;
; ALGORITHM:
;   Iterative method:
;   1. Calculate cylindrical radius: p = sqrt(x² + y²)
;   2. Initial guess (geocentric): lat = atan2(z, p·(1-e²))
;   3. Iterate:
;      N = r_eq / sqrt(1 - e²·sin²(lat))
;      h = p/cos(lat) - N
;      lat_new = atan2(z, p·(1 - e²·N/(N+h)))
;   4. Converge when |lat_new - lat| < tol
;
; EXAMPLE:
;   IDL> mars = mars_constants()
;   IDL> result = calculate_geodetic_latitude(10000.0d0, 0.0d0, 0.0d0, $
;                   mars.r_eq, mars.e2)
;   IDL> print, result.lat * !RADEG
;        0.0
;   IDL> print, result.h
;        6603.81
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION calculate_geodetic_latitude, x_fixed, y_fixed, z_fixed, r_eq, e2, $
                                       tol=tol, max_iter=max_iter

  COMPILE_OPT IDL2, HIDDEN

  ; Set default parameters
  if (N_ELEMENTS(tol) eq 0) then tol = 1.0d-12
  if (N_ELEMENTS(max_iter) eq 0) then max_iter = 10

  ; Calculate cylindrical radius
  p = SQRT(x_fixed^2 + y_fixed^2)

  ; Special case: at poles (p = 0)
  if (p eq 0.0d0) then begin
    if (z_fixed gt 0) then begin
      lat = !DPI / 2.0d0  ; North pole
    endif else if (z_fixed lt 0) then begin
      lat = -!DPI / 2.0d0  ; South pole
    endif else begin
      lat = 0.0d0  ; At origin
    endelse
    h = ABS(z_fixed) - r_eq * SQRT(1.0d0 - e2)
    result = {lat: lat, h: h, n_iter: 0, converged: 1b}
    RETURN, result
  endif

  ; Initial guess (geocentric latitude)
  lat = ATAN(z_fixed, p * (1.0d0 - e2))

  ; Iterate to find geodetic latitude
  converged = 0b
  for iter = 0, max_iter - 1 do begin
    ; Calculate radius of curvature in prime vertical
    sin_lat = SIN(lat)
    N = r_eq / SQRT(1.0d0 - e2 * sin_lat^2)

    ; Calculate altitude
    cos_lat = COS(lat)
    if (ABS(cos_lat) gt 1e-10) then begin
      h = p / cos_lat - N
    endif else begin
      ; Near poles, use Z-component
      h = ABS(z_fixed) / ABS(sin_lat) - N * (1.0d0 - e2)
    endelse

    ; Update latitude
    lat_new = ATAN(z_fixed, p * (1.0d0 - e2 * N / (N + h)))

    ; Check convergence
    delta = ABS(lat_new - lat)
    if (delta lt tol) then begin
      converged = 1b
      result = {lat: lat_new, h: h, n_iter: iter + 1, converged: converged}
      RETURN, result
    endif

    lat = lat_new
  endfor

  ; If we reach here, convergence failed
  ; Return last values with converged = 0
  sin_lat = SIN(lat)
  N = r_eq / SQRT(1.0d0 - e2 * sin_lat^2)
  cos_lat = COS(lat)
  if (ABS(cos_lat) gt 1e-10) then begin
    h = p / cos_lat - N
  endif else begin
    h = ABS(z_fixed) / ABS(sin_lat) - N * (1.0d0 - e2)
  endelse

  result = {lat: lat, h: h, n_iter: max_iter, converged: 0b}
  RETURN, result

END


;+
; NAME:
;   MCI_TO_LLA
;
; PURPOSE:
;   Converts position from Mars-Centered Inertial (MCI) frame to
;   Longitude/Latitude/Altitude coordinates.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   result = mci_to_lla(r_mci, t, constants)
;
; INPUTS:
;   r_mci     - Position vector in MCI frame [3] (km)
;   t         - Current time (seconds since epoch)
;   constants - Mars constants structure from mars_constants()
;
; OUTPUTS:
;   Structure containing:
;     .lon - Longitude (degrees), range [-180, 180] or [0, 360]
;     .lat - Geodetic latitude (degrees)
;     .alt - Altitude above reference ellipsoid (km)
;
; ALGORITHM:
;   1. Transform MCI to Mars-fixed frame (account for rotation)
;   2. Calculate longitude: lon = atan2(y_fixed, x_fixed)
;   3. Calculate geodetic latitude and altitude iteratively
;
; EXAMPLE:
;   IDL> mars = mars_constants()
;   IDL> r_mci = [10000.0d0, 0.0d0, 0.0d0]
;   IDL> t = 0.0d0
;   IDL> result = mci_to_lla(r_mci, t, mars)
;   IDL> print, result.lon, result.lat, result.alt
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION mci_to_lla, r_mci, t, constants

  COMPILE_OPT IDL2, HIDDEN

  ; Transform from MCI to Mars-fixed frame
  r_fixed = mci_to_mars_fixed(r_mci, t, constants.ref_epoch, constants.omega_mars)

  ; Calculate longitude
  ; lon = atan2(y, x)
  lon = ATAN(r_fixed[1], r_fixed[0])

  ; Convert to degrees and normalize to [-180, 180]
  lon_deg = lon * !RADEG
  if (lon_deg gt 180.0d0) then lon_deg = lon_deg - 360.0d0
  if (lon_deg lt -180.0d0) then lon_deg = lon_deg + 360.0d0

  ; Calculate geodetic latitude and altitude
  geo_result = calculate_geodetic_latitude(r_fixed[0], r_fixed[1], r_fixed[2], $
                                            constants.r_eq, constants.e2)

  ; Convert latitude to degrees
  lat_deg = geo_result.lat * !RADEG

  ; Return result structure
  result = { $
    lon: lon_deg, $
    lat: lat_deg, $
    alt: geo_result.h $
  }

  RETURN, result

END


;+
; NAME:
;   LLA_TO_MCI
;
; PURPOSE:
;   Converts Longitude/Latitude/Altitude coordinates to position vector
;   in Mars-Centered Inertial (MCI) frame.
;
; CATEGORY:
;   Orbital Mechanics / Coordinate Transformations
;
; CALLING SEQUENCE:
;   r_mci = lla_to_mci(lon, lat, alt, t, constants)
;
; INPUTS:
;   lon       - Longitude (degrees)
;   lat       - Geodetic latitude (degrees)
;   alt       - Altitude above reference ellipsoid (km)
;   t         - Current time (seconds since epoch)
;   constants - Mars constants structure from mars_constants()
;
; OUTPUTS:
;   r_mci - Position vector in MCI frame [3] (km)
;
; ALGORITHM:
;   1. Convert lon, lat, alt to Cartesian Mars-fixed coordinates
;   2. Transform from Mars-fixed to MCI frame
;
; EXAMPLE:
;   IDL> mars = mars_constants()
;   IDL> lon = 45.0d0  ; degrees
;   IDL> lat = 30.0d0  ; degrees
;   IDL> alt = 1000.0d0  ; km
;   IDL> t = 0.0d0
;   IDL> r_mci = lla_to_mci(lon, lat, alt, t, mars)
;   IDL> print, r_mci
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION lla_to_mci, lon, lat, alt, t, constants

  COMPILE_OPT IDL2, HIDDEN

  ; Convert to radians
  lon_rad = lon * !DTOR
  lat_rad = lat * !DTOR

  ; Calculate radius of curvature in prime vertical
  sin_lat = SIN(lat_rad)
  N = constants.r_eq / SQRT(1.0d0 - constants.e2 * sin_lat^2)

  ; Calculate Cartesian coordinates in Mars-fixed frame
  cos_lat = COS(lat_rad)
  cos_lon = COS(lon_rad)
  sin_lon = SIN(lon_rad)

  r_fixed = DBLARR(3)
  r_fixed[0] = (N + alt) * cos_lat * cos_lon
  r_fixed[1] = (N + alt) * cos_lat * sin_lon
  r_fixed[2] = (N * (1.0d0 - constants.e2) + alt) * sin_lat

  ; Transform from Mars-fixed to MCI frame
  r_mci = mars_fixed_to_mci(r_fixed, t, constants.ref_epoch, constants.omega_mars)

  RETURN, r_mci

END
