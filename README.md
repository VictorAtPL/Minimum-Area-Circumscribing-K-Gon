### POLY_KGON

Computes the minimum-area convex k-gon (k-sided polygon) that circumscribes the given convex n-gon (x,y). Follows the method of Aggarwal et al, "Minimum area circumscribing Polygons", The Visual Computer (1985) 1:112-117

Example:
```IDL
IDL> x = [43, 18, 19, 24, 35, 49, 56, 54]*1.
IDL> y = [24, 45, 54, 63, 69, 64, 57, 41]*1.
IDL> result = POLY_KGON(x, y, kgon=4)
IDL> print, result
      15.2727      47.2909
      28.6026      71.2848
      64.4083      58.4970
      43.5917      23.5030
```
![kgon_example](https://cloud.githubusercontent.com/assets/9730969/13654712/edf53f0c-e6ad-11e5-935d-866e70c88b83.gif)
