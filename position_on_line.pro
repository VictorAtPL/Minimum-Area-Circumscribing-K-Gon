function position_on_line, p1, p2, p3

; Determine position of point p3 relative to line segment (p1,p2). Assumes
; p3 is on the line. Result will be <0 if p3 is before p1, >1 if after p2,
; and between 0 and 1 if it is contained within the line segment (p1,p2).
;
; Written by: Glenn Hyland, Australian Antarctic Division & Antarctic
; Climate & Ecosystems CRC, July 2015

d21 = p2 - p1
k = (abs(d21[0]) gt abs(d21[1]))? 0 : 1

return, (p3[k] - p1[k]) / d21[k]
end
