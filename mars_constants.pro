;+
; NAME:
;   MARS_CONSTANTS
;
; PURPOSE:
;   Returns a structure containing fundamental physical and orbital constants
;   for the planet Mars. These constants are used throughout the orbital
;   propagation calculations.
;
; CATEGORY:
;   Orbital Mechanics / Planetary Constants
;
; CALLING SEQUENCE:
;   mars = mars_constants()
;
; INPUTS:
;   None
;
; OUTPUTS:
;   Structure containing Mars constants:
;     .mu          - Standard gravitational parameter (km³/s²)
;     .r_eq        - Equatorial radius (km)
;     .r_pol       - Polar radius (km)
;     .f           - Flattening factor (dimensionless)
;     .e2          - Eccentricity squared (dimensionless)
;     .omega_mars  - Mars rotation rate (rad/s)
;     .ref_epoch   - Reference epoch for rotation (J2000.0, seconds since epoch)
;
; EXAMPLE:
;   IDL> mars = mars_constants()
;   IDL> print, mars.mu
;        42828.370
;   IDL> print, mars.r_eq
;        3396.1900
;
; REFERENCES:
;   - NASA Mars Fact Sheet: https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
;   - IAU/IAG Working Group on Cartographic Coordinates and Rotational Elements
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION mars_constants

  ; Compile options
  COMPILE_OPT IDL2, HIDDEN

  ; Define Mars physical and orbital constants
  ; All values use double precision

  ; Standard gravitational parameter: G*M_mars
  ; Source: NASA Mars Fact Sheet (GM)
  mu = 42828.37d0  ; km³/s²

  ; Mars reference ellipsoid (IAU 2015)
  r_eq = 3396.19d0   ; Equatorial radius (km)
  r_pol = 3376.20d0  ; Polar radius (km)

  ; Derived geometric parameters
  f = (r_eq - r_pol) / r_eq  ; Flattening factor
  e2 = f * (2.0d0 - f)       ; Eccentricity squared = 2f - f²

  ; Mars rotation rate
  ; Mars sidereal day = 24.6229 hours = 88642.644 seconds
  ; omega = 2π / T_sidereal
  omega_mars = 7.088218d-5  ; rad/s

  ; Reference epoch: J2000.0 (January 1, 2000, 12:00:00 TT)
  ; This is the reference time for Mars rotation calculations
  ; Set to 0.0 for simplicity (user can offset relative to this)
  ref_epoch = 0.0d0  ; seconds since J2000.0

  ; Create and return structure
  constants = { $
    mu:         mu, $
    r_eq:       r_eq, $
    r_pol:      r_pol, $
    f:          f, $
    e2:         e2, $
    omega_mars: omega_mars, $
    ref_epoch:  ref_epoch $
  }

  RETURN, constants

END
