function poly_kgon, x, y, kgon=kgon, flush=flush, onesided=onesided, $
                                     verbose=verbose, istart=istart

; Purpose:
;   Determines the minimum-area convex k-gon (k-sided polygon) that
;   circumscribes the given convex n-gon (x,y). Loosely follows the method
;   of Aggarwal et al, "Minimum area circumscribing Polygons", The Visual
;   Computer (1985) 1:112-117
;
; Inputs:
;   It is assumed that the polygon (x,y) has n vertices with n sides and the
;   edges connect the vertices in the order:
;     [(x1,y1), (x2,y2), ..., (xn,yn), (x1,y1)].
;   i.e. the last vertex is connected to the first vertex.
;
;   x: An n-element vector of x coordinate locations for the vertices
;   y: An n-element vector of y coordinate locations for the vertices
;
; Keyword Inputs:
;   kgon:     The number of sides of the min-area convex k-gon (default=4)
;
;   verbose:  Prints progress information and plots the final result
;   flush:    Steps through the flush (k-3)-sided chain search
;   onesided: Steps through the optimal one-sided chain search
;   istart:   Starts searching at n-gon edge istart (default=1)
;   Keywords verbose, flush, onesided and istart are primarily for debugging
;   purposes.
;
; Outputs:
;   POLY_KGON returns an array of dimensions (2,kgon) giving the (x,y)
;   coordinate locations of the vertices of the minimum-area convex k-gon.
;
; Method:
;   From Aggarwal et al (1985) the required minimum k-gon Q will have at least
;   k-1 edges flush with the n-gon P, and all edges of Q will be balanced (ie.
;   edge midpoints touch P). The search involves looking for two edges i and j
;   of P that touch Q and decompose Q into two chains - a flush (k-3)-sided
;   chain, and a one-sided (possibly flush) chain that both have minimum extra
;   area among all such chains.
;
; Modification History:
;   Written by: Glenn Hyland, Australian Antarctic Division & Antarctic
;   Climate & Ecosystems CRC, July 2015

@kgon_common

if (n_elements(kgon) eq 0) then kgon = 4
if (n_elements(istart) eq 0) then istart = 1

;!except = 2

px = x
py = y
np = n_elements(px)

s = ''

; Define common block elements to store edge intersects and vertex slopes
; data.

intersects = replicate({done:0, p:[0.,0.], area:-1., sfactor:-1.}, np, np)
slopes = replicate({done:0, slope_min:-1., slope_max:-1.}, np)

h = kgon - 3

total_min = -1.

; Need to look at all pairs of edges i and j of P that are separated by a
; mimimum of k-3 edges.

for i = istart, np do begin

ii = (i lt np)? i : 0
pi1 = [px[ii],py[ii]]
pi2 = [px[i-1],py[i-1]]

for jj = i+1+h, i-2+np do begin

j = ((jj-1) mod np) + 1

ij = (j lt np)? j : 0
pj1 = [px[ij],py[ij]]
pj2 = [px[j-1],py[j-1]]

if (keyword_set(verbose)) then begin
	print
	print, 'start', i, j
endif

nedges = jj - 1 - i
cindex = (nedges eq 1)? (i+1) : combigen(nedges,h) + (i+1)
ncoms = n_elements(cindex)/h

cindex = ((cindex-1) mod np) + 1

area1_min = -1.

for kk = 0, ncoms-1 do begin

	; This is the flush (k-3)-sided chain search ... consider all
	; combinations of k-3 edges between i and j. Select the combination
	; that gives the smallest extra area.

	ei = i
	area1 = 0.
	for ll = 0, h do begin
		ej = (ll lt h)? cindex[kk,ll] : j
		p = edge_intersect(ei, ej, sfactor=sfac, area=a)
		if (sfac le 0.) then begin
			area1 = area1 + a
		endif else begin
			area1 = -1.
			break
		endelse
		p1 = (ll eq 0)? p : [p1, p]
		ei = ej
	endfor

	if (keyword_set(verbose)) then $
		print, 'flush', kk, ' - ', index_format(cindex[kk,*]), area1

	if (keyword_set(flush)) then begin
		if (area1 ge 0.) then $
			plot_polygon, edges=[i,j], points=[pi1,p1,pj2] $
		else $
			plot_polygon, edges=[i,j,-reform(cindex[kk,*])]
		read, s
	endif

	if (area1 ge 0. and (area1 lt area1_min or area1_min lt 0.)) then begin
		area1_min = area1
		p1_min = p1
	endif

endfor
if (area1_min lt 0.) then goto, calc_totals

sfac2 = 1.
area2_min = -1.

for kk = jj+1, i-1+np do begin

	; This is the first step in the one-sided chain search ... consider
	; all edges k between j and i of P to find the one that gives the
	; minimum extra area. If this is a balanced edge then we are done.
	; Otherwise, move onto step 2.

	k = ((kk-1) mod np) + 1

	p3 = edge_intersect(j, k, sfactor=sfac1, area=a3)
	if (sfac1 le 0.) then p4 = edge_intersect(k, i, sfactor=sfac2, area=a4)

	intersect = sfac1 le 0. and sfac2 le 0.
	area2 = (intersect)? a3 + a4 : -1.

	if (keyword_set(verbose)) then print, '1sided', k, area2

	if (keyword_set(onesided)) then begin
		if (intersect) then begin
			plot_polygon, edges=[i,j], points=[pj1,p3,p4,pi2]
			pmid = (p3 + p4)*0.5
			plots, pmid[0], pmid[1], psym=4, symsize=2.0
		endif else begin
			plot_polygon, edges=[i,j,-k]
		endelse
		read, s
	endif

	; We can exit early if we have found the minimum - as subsequent
	; edges will either not intersect or have a greater extra area (via
	; the Interspersing Lemma from Aggarwal et al, 1985).

	if (area2_min ge 0 and (not intersect or area2 gt area2_min)) then break

	pk1 = (k lt np)? [px[k],py[k]] : [px[0],py[0]]
	pk2 = [px[k-1],py[k-1]]
	if (area2 eq area2_min and area2_min gt 0.) then begin
		pmid = (p3 + p4)*0.5
		midpos = position_on_line(pk1, pk2, pmid)
		if (midpos ge 0. and midpos le 1.) then begin
			p3_min = p3
			p4_min = p4
			pk1_min = pk1
			pk2_min = pk2
			k_min = k
		endif
	endif else if (area2 lt area2_min or area2_min lt 0) then begin
		area2_min = area2
		p3_min = p3
		p4_min = p4
		pk1_min = pk1
		pk2_min = pk2
		k_min = k
	endif
endfor

corners = -1.

if (area2_min ge 0.) then begin
	pmid = (p3_min + p4_min)*0.5
	midpos = position_on_line(pk1_min, pk2_min, pmid)
	if (midpos lt 0. or midpos gt 1.) then begin

		; This is the 2nd step in the one-sided chain search ... we
		; have found a suitable edge, but when flush the edge is not
		; balanced (ie. midpoint not touching). So try locating the
		; midpoint on the closest vertex to see if this provides a
		; solution.

		k = (midpos lt 0.)? k_min : k_min - 1
		pk = (k lt np)? [px[k],py[k]] : [px[0],py[0]]

		p = line_intersect_midpt(pi1, pi2, pj2, pj1, pk, $
					 slope=pslope, pol=pol)
		if (n_elements(p) gt 1 and $
			(pol[0] gt 1. and pol[1] gt 1.)) then begin

			; The only sure way to check the solution is to see
			; if the slope of the new edge is between the slopes
			; of the two edges of P forming the vertex.

			kv = (k mod np) + 1
			vslope = vertex_slopes(kv)
			if (pslope gt vslope[1]) then pslope = pslope - 180.
			if (pslope lt vslope[0]) then pslope = pslope + 180.

			if (pslope ge vslope[0] and $
				pslope le vslope[1]) then begin

				ni = (jj gt i)? (i - 2 - jj) + np : (i - 2 - jj)
				ix = (lindgen(ni) + j + 1) mod np
				area2_min = poly_area( $
					[pi2[0],reform(p[0,*]),pj1[0],px[ix]], $
					[pi2[1],reform(p[1,*]),pj1[1],py[ix]])

				if (keyword_set(verbose)) then $
					print, 'balanced', k, area2_min

				corners = [p1_min,p[*,1],p[*,0]]

			endif else area2_min = -1.

		endif else area2_min = -1.

	endif else corners = [p1_min,p3_min,p4_min]
endif

if (keyword_set(flush) or keyword_set(onesided)) then begin
	if (n_elements(corners) gt 1) then $
		plot_polygon, points=[corners,corners[0:1]] $
	else $
		plot_polygon, edges=[i,j]
endif

calc_totals:

if (area1_min ge 0. and area2_min ge 0.) then begin
	total_area = (area1_min ge 0.)? area1_min : 0.
	total_area = (area2_min ge 0.)? total_area + area2_min : total_area
	if (total_area lt total_min or total_min lt 0.) then begin
		total_min = total_area
		corners_min = corners
		i_min = i
		j_min = j
	endif
endif else $
	total_area = -1.

if (keyword_set(verbose)) then print, 'total', i, j, total_area
if (keyword_set(flush) or keyword_set(onesided)) then read, s

endfor
endfor

if (keyword_set(verbose)) then begin
	print
	print, 'final', i_min, j_min, total_min
	plot_polygon, points=[corners_min,corners_min[0:1]]
endif

return, reform(corners_min, 2, kgon)
end
