pro plot_polygon, continue=continue, edges=edges, points=points

@kgon_common

if (not keyword_set(continue)) then begin
	if (n_elements(points) gt 1) then $
		plot, [px,points[0:*:2]], [py,points[1:*:2]], /iso, /nodata $
	else $
		plot, px, py, /isotropic, /nodata
	plots, [px,px[0]], [py,py[0]], psym=-6, linestyle=1
endif

for i = 0, n_elements(edges)-1 do begin
	k = abs(edges[i])
	kk = (k lt np)? k : 0
	lstyle = (edges[i] lt 0)? 0 : 2
	plots, [px[k-1],px[kk]], [py[k-1],py[kk]], psym=-4, linestyle=lstyle
endfor

if (n_elements(points) gt 1) then plots, points[0:*:2], points[1:*:2], psym=-4

end
