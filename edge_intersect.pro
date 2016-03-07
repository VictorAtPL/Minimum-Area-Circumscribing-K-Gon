function edge_intersect, i, j, sfactor=sfactor, area=area

; Determine the intersection of polygon edges (i,j) - numbered clockwise
; starting from 1. This routines keeps a record of previously calculated
; values so a subsequent call with the same (i,j) pair will return the
; stored values. Only intersections between (i,j) in a clockwise direction
; are returned (call with (j,i) for anti-clockwise intersections).
;
; Optionally returns the intersection point on edge j as a scaling factor,
; and the extra area bounded by the original polygon and the intersection
; vertex.
;
; Written by: Glenn Hyland, Australian Antarctic Division & Antarctic
; Climate & Ecosystems CRC, July 2015

@kgon_common

ii = i - 1
ij = j - 1

if (intersects[ii,ij].done gt 0) then begin

	p = intersects[ii,ij].p
	if (arg_present(sfactor)) then $
		sfactor = intersects[ii,ij].sfactor
	if (arg_present(area)) then area = intersects[ii,ij].area

endif else begin

	pi1 = (i lt np)? [px[i],py[i]] : [px[0],py[0]]
	pi2 = [px[i-1],py[i-1]]

	pj1 = (j lt np)? [px[j],py[j]] : [px[0],py[0]]
	pj2 = [px[j-1],py[j-1]]

	; Firstly check for the redundant case of adjacent edges.

	if (j-1 eq i) then begin
		p = pi1
		area = 0.
		sfactor = -1.
	endif else if (i-1 eq j) then begin
		p = pi2
		area = 0.
		sfactor = -1.
	endif else begin
		p = line_intersect(pi1, pi2, pj1, pj2, sfactor=sfactor)
		if (sfactor le 0.) then begin
			ni = (j gt i)? j - 2 - i : j - 2 - i + np
			if (ni gt 0) then begin
				ix = (lindgen(ni) + i + 1) mod np
				area = poly_area([pj2[0],p[0],pi1[0],px[ix]], $
			 			[pj2[1],p[1],pi1[1],py[ix]])
			endif else begin
				area = poly_area([pj2[0],p[0],pi1[0]], $
			 			[pj2[1],p[1],pi1[1]])
			endelse
		endif else area = -1.
	endelse

	intersects[ii,ij].p = p
	intersects[ii,ij].area = area
	intersects[ii,ij].sfactor = sfactor
	intersects[ii,ij].done = 1
endelse

return, p
end
