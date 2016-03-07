function line_intersect_midpt, p1, p2, p3, p4, pmid, slope=slope, pol=pol

; Given two line segments (p1,p2) and (p3,p4) determine the line segment
; that intersects these segments and has mid-point pmid.
;
; Optionally returns the slope of the line, and the intersection points
; (as a position-on-line scaling factor) on each of the two line segments.
;
; Written by: Glenn Hyland, Australian Antarctic Division & Antarctic
; Climate & Ecosystems CRC, July 2015

dxi = p2[0] - p1[0]
dyi = p2[1] - p1[1]
dxyi = p1[0]*p2[1] - p2[0]*p1[1]

dxj = p4[0] - p3[0]
dyj = p4[1] - p3[1]
dxyj = p3[0]*p4[1] - p4[0]*p3[1]

pmid2 = 2.*pmid

d = dxi*dyj - dxj*dyi
if (d eq 0.) then return, -1.

q2x = (dxj*(dxyi - pmid2[0]*dyi) + dxi*(dxyj + pmid2[1]*dxj)) / d
if (dxj eq 0.) then begin
	q1x = pmid2[0] - q2x
	q1y = (q1x*dyi - dxyi) / dxi
	q2y = pmid2[1] - q1y
	q1 = [q1x,q1y]
	q2 = [q2x,q2y]
endif else begin
	q2y = (q2x*dyj - dxyj) / dxj
	q2 = [q2x,q2y]
	q1 = pmid2 - q2
endelse

if (arg_present(pol)) then begin
	pol1 = position_on_line(p1,p2,q1)
	pol2 = position_on_line(p3,p4,q2)
	pol = [pol1,pol2]
endif

if (arg_present(slope)) then $
	slope = atan(q2[1]-pmid[1],q2[0]-pmid[0])*(180/!pi) + 360.

return, [[q1],[q2]]
end
