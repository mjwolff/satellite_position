;+
; NAME:
;   SP_CALCULATE_SUBSOLAR_LATITUDE
;
; PURPOSE:
;   Calculates the sub-solar latitude on Mars (latitude where the Sun is
;   directly overhead at solar noon) from areocentric solar longitude (L_s).
;
; CATEGORY:
;   Mars Climate / Orbital Mechanics
;
; CALLING SEQUENCE:
;   subsolar_lat = sp_calculate_subsolar_latitude(Ls [, /DEGREES] [, OBLIQUITY=value])
;
; INPUTS:
;   Ls - Areocentric solar longitude (radians by default, degrees if /DEGREES set)
;        L_s defines Mars' position in its orbit around the Sun
;        L_s = 0° at northern spring equinox
;        Scalar or array
;
; KEYWORDS:
;   DEGREES   - If set, input/output in degrees instead of radians
;   OBLIQUITY - Optional custom Mars obliquity (radians or degrees based on DEGREES)
;               Default: uses current epoch value from sp_mars_constants()
;
; OUTPUTS:
;   Sub-solar latitude in same units as input (radians or degrees)
;   Range: [-obliquity, +obliquity], typically [-25.19°, +25.19°]
;   Same size as input Ls
;
; ALGORITHM:
;   subsolar_latitude = obliquity × sin(L_s)
;
;   where:
;   - L_s = 0° → northern spring equinox → subsolar_lat = 0°
;   - L_s = 90° → northern summer solstice → subsolar_lat = +25.19°
;   - L_s = 180° → northern autumn equinox → subsolar_lat = 0°
;   - L_s = 270° → northern winter solstice → subsolar_lat = -25.19°
;
; EXAMPLE:
;   IDL> ; Northern summer solstice
;   IDL> subsolar_lat = sp_calculate_subsolar_latitude(90.0d0, /DEGREES)
;   IDL> print, subsolar_lat
;        25.19
;
;   IDL> ; Seasonal cycle
;   IDL> Ls_array = DINDGEN(361) * !DTOR
;   IDL> subsolar_lat_array = sp_calculate_subsolar_latitude(Ls_array)
;   IDL> plot, Ls_array * !RADEG, subsolar_lat_array * !RADEG
;
; REFERENCES:
;   - NASA Mars Fact Sheet: https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
;   - IAU 2015 Mars constants
;
; NOTES:
;   - Sub-solar latitude drives Mars seasonal cycles, polar ice cap extent,
;     and atmospheric circulation
;   - Mars obliquity varies on ~120,000 year timescale; current implementation
;     uses present epoch value (25.19°) unless custom obliquity is specified
;
; MODIFICATION HISTORY:
;   2026-02-18: Initial implementation
;-

FUNCTION sp_calculate_subsolar_latitude, Ls, DEGREES=degrees, OBLIQUITY=obliquity

  COMPILE_OPT IDL2, HIDDEN

  ; Get obliquity from mars_constants if not provided
  if (N_ELEMENTS(obliquity) eq 0) then begin
    mars = sp_mars_constants()
    obliquity_rad = mars.obliquity
  endif else begin
    ; Convert custom obliquity to radians if needed
    if KEYWORD_SET(degrees) then begin
      obliquity_rad = obliquity * (!DPI/180.0d0)
    endif else begin
      obliquity_rad = obliquity
    endelse

    ; Validate obliquity range (must be between 0 and π/2 radians)
    if (obliquity_rad le 0.0d0 OR obliquity_rad ge !DPI/2.0d0) then begin
      MESSAGE, 'Obliquity must be in range (0, 90) degrees or (0, π/2) radians. ' + $
               'obliquity = ' + STRTRIM(obliquity, 2)
    endif
  endelse

  ; Convert Ls to radians if input is in degrees
  if KEYWORD_SET(degrees) then begin
    Ls_rad = Ls * (!DPI/180.0d0)
  endif else begin
    Ls_rad = Ls
  endelse

  ; Calculate sub-solar latitude
  ; δ = obliquity × sin(Ls)
  subsolar_lat_rad = obliquity_rad * SIN(Ls_rad)

  ; Convert output to degrees if requested
  if KEYWORD_SET(degrees) then begin
    RETURN, subsolar_lat_rad * (180.0d0/!DPI)
  endif else begin
    RETURN, subsolar_lat_rad
  endelse

END
