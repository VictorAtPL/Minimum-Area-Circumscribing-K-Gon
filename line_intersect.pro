function line_intersect, p1, p2, p3, p4, sfactor=sfactor, tfactor=tfactor

; Determine the intersection of the line segments (p1,p2) and (p3,p4). Only
; intersections before p3 (sfactor<=0) are considered. Optionally returns
; the intersection point as a scaling factor for each line segment.
;
; Written by: Glenn Hyland, Australian Antarctic Division & Antarctic
; Climate & Ecosystems CRC, July 2015

d12 = p1 - p2
d34 = p3 - p4

d13 = p1 - p3

d1 = d12[0]*d34[1] - d12[1]*d34[0]

s = (d1 eq 0.)? 1e+10 : (d12[0]*d13[1] - d12[1]*d13[0]) / d1

if (arg_present(sfactor)) then sfactor = s
if (arg_present(tfactor)) then $
	tfactor = (d1 eq 0.)? 1e+10 : (d34[0]*d13[1] - d34[1]*d13[0]) / d1

if (s gt 0.) then return, [-1., -1.]

p = p3 + s*d34

return, p
end
