function vertex_slopes, k

; Determine the slopes associated with polygon vertex (k) - numbered clockwise
; starting from 1. This routines keeps a record of previously calculated
; values so a subsequent call with the same vertex (k) will return the same
; values.
;
; Written by: Glenn Hyland, Australian Antarctic Division & Antarctic
; Climate & Ecosystems CRC, July 2015

@kgon_common

kk = k - 1

if (slopes[kk].done gt 0) then begin

	slpmin = slopes[kk].slope_min
	slpmax = slopes[kk].slope_max

endif else begin

	i = k - 1
	ik = (i lt np)? i : 0

	slpmin = atan(py[i-1]-py[ik],px[i-1]-px[ik])*(180/!pi) + 360.

	j = k
	jk = (j lt np)? j : 0

	slpmax = atan(py[jk]-py[j-1],px[jk]-px[j-1])*(180/!pi) + 360.

	slpmin = min([slpmin,slpmax], max=slpmax)
	if (abs(slpmax-slpmin-180.) lt 0.01) then begin
		slpmax = slpmin
	endif else if (slpmax-slpmin lt 180.) then begin
		temp = slpmax
		slpmax = slpmin
		slpmin = temp - 180.
	endif

	slopes[kk].slope_min = slpmin
	slopes[kk].slope_max = slpmax
	slopes[kk].done = 1

endelse

return, [slpmin, slpmax]
end
