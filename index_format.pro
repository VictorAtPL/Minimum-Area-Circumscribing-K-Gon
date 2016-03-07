function index_format, list

; Convert an array of integer values into a formatted list, "(v1,v2,...,vn)"

value = '('
slist = string(list, format='(i0)')

for i = 0, n_elements(list)-2 do value = value + slist[i] + ','
value = value + slist[-1] + ')'

return, value
end
