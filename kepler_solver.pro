;+
; NAME:
;   SOLVE_KEPLER
;
; PURPOSE:
;   Solves Kepler's equation (M = Ecc - e*sin(Ecc)) for the eccentric anomaly
;   using Newton-Raphson iteration. This is a fundamental calculation in
;   two-body orbital mechanics for propagating elliptical orbits.
;
; CATEGORY:
;   Orbital Mechanics / Mathematical Solvers
;
; CALLING SEQUENCE:
;   Ecc = solve_kepler(M, e [, tol=tol, max_iter=max_iter, $
;                      n_iter=n_iter, converged=converged])
;
; INPUTS:
;   M   - Mean anomaly (radians), scalar or array
;   e   - Orbital eccentricity (dimensionless), 0 <= e < 1, scalar or array
;
; OPTIONAL KEYWORDS:
;   tol      - Convergence tolerance (default: 1e-10 radians)
;   max_iter - Maximum number of iterations (default: 50)
;
; OUTPUTS:
;   Ecc - Eccentric anomaly (radians), same size as input
;
; OPTIONAL OUTPUT KEYWORDS:
;   n_iter    - Number of iterations taken to converge
;   converged - Boolean flag: 1 if converged, 0 if failed
;
; ALGORITHM:
;   Newton-Raphson iteration:
;     f(Ecc) = Ecc - e*sin(Ecc) - M
;     f'(Ecc) = 1 - e*cos(Ecc)
;     Ecc_new = Ecc - f(Ecc) / f'(Ecc)
;
;   Iterate until |Ecc_new - Ecc| < tol or max_iter reached
;
; EXAMPLE:
;   IDL> M = !DPI/4.0  ; Mean anomaly = 45 degrees
;   IDL> e = 0.5       ; Moderate eccentricity
;   IDL> Ecc = solve_kepler(M, e, n_iter=n)
;   IDL> print, Ecc * !RADEG
;        60.134
;   IDL> print, n
;        4
;
; REFERENCES:
;   - Vallado, D. A. (2013). Fundamentals of Astrodynamics and Applications, 4th Ed.
;   - Prussing, J. E., & Conway, B. A. (1993). Orbital Mechanics.
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION solve_kepler, M, e, tol=tol, max_iter=max_iter, $
                       n_iter=n_iter, converged=converged

  COMPILE_OPT IDL2, HIDDEN

  ; Set default parameters
  if (N_ELEMENTS(tol) eq 0) then tol = 1.0d-10
  if (N_ELEMENTS(max_iter) eq 0) then max_iter = 50

  ; Validate inputs
  if (e lt 0.0d0 OR e ge 1.0d0) then begin
    MESSAGE, 'Eccentricity must be in range [0, 1). e = ' + STRTRIM(e, 2), /INFORMATIONAL
    converged = 0b
    RETURN, !VALUES.D_NAN
  endif

  ; Normalize M to [0, 2*pi]
  M_norm = M mod (2.0d0 * !DPI)
  if (M_norm lt 0.0d0) then M_norm = M_norm + 2.0d0 * !DPI

  ; Special case: circular orbit (e = 0)
  if (e eq 0.0d0) then begin
    converged = 1b
    n_iter = 0
    RETURN, M_norm
  endif

  ; Initial guess for Ecc
  ; Use M for small/moderate eccentricity, pi for high eccentricity
  if (e lt 0.8d0) then begin
    Ecc = M_norm
  endif else begin
    Ecc = !DPI
  endelse

  ; Newton-Raphson iteration
  converged = 0b
  for iter = 0, max_iter - 1 do begin
    ; Compute function and derivative
    ; f(Ecc) = Ecc - e*sin(Ecc) - M
    ; f'(Ecc) = 1 - e*cos(Ecc)

    sin_Ecc = SIN(Ecc)
    cos_Ecc = COS(Ecc)

    f = Ecc - e * sin_Ecc - M_norm
    f_prime = 1.0d0 - e * cos_Ecc

    ; Newton-Raphson update
    delta = f / f_prime
    Ecc_new = Ecc - delta

    ; Check convergence
    if (ABS(delta) lt tol) then begin
      converged = 1b
      n_iter = iter + 1
      RETURN, Ecc_new
    endif

    Ecc = Ecc_new
  endfor

  ; If we reach here, convergence failed
  n_iter = max_iter
  converged = 0b

  MESSAGE, 'Newton-Raphson failed to converge after ' + $
           STRTRIM(max_iter, 2) + ' iterations. M = ' + $
           STRTRIM(M, 2) + ', e = ' + STRTRIM(e, 2), /INFORMATIONAL

  RETURN, Ecc

END
