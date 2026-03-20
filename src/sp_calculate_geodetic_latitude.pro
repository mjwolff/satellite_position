;+
; NAME:
;   SP_CALCULATE_GEODETIC_LATITUDE
;
; PURPOSE:
;   Calculates geodetic latitude and altitude from Cartesian coordinates
;   in Mars-fixed frame using iterative algorithm.
;
; CATEGORY:
;   Orbital Mechanics / Geodetic Conversions
;
; CALLING SEQUENCE:
;   result = sp_calculate_geodetic_latitude(x_fixed, y_fixed, z_fixed, r_eq, e2, $
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
;   IDL> mars = sp_mars_constants()
;   IDL> result = sp_calculate_geodetic_latitude(10000.0d0, 0.0d0, 0.0d0, $
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

FUNCTION sp_calculate_geodetic_latitude, x_fixed, y_fixed, z_fixed, r_eq, e2, $
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
      ; Recompute h from lat_new so the returned (lat, h) pair is consistent
      sin_lat_new = SIN(lat_new)
      N_new = r_eq / SQRT(1.0d0 - e2 * sin_lat_new^2)
      cos_lat_new = COS(lat_new)
      if (ABS(cos_lat_new) gt 1e-10) then begin
        h = p / cos_lat_new - N_new
      endif else begin
        h = ABS(z_fixed) / ABS(sin_lat_new) - N_new * (1.0d0 - e2)
      endelse
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
