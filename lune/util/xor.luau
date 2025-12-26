local function xor<T>(a: {T}, b: {T}): {T}
	local diff = {}

	for _, value in a do
		if not table.find(b, value) then
			table.insert(diff, value)
		end
	end
	
    for _, value in b do
		if not table.find(a, value) then
			table.insert(diff, value)
		end
	end
	
    return diff
end

return xor