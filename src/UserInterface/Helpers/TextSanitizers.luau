local TextSanitizers = {}

function TextSanitizers.numeric(text: string, allowNegative: boolean, allowDecimal: boolean)
	local negative = false
	if allowNegative and string.sub(text, 1, 1) == "-" then
		negative = true
		text = string.sub(text, 2)
	end

	text = string.gsub(text, "[^%.%d]", "")
	local firstDecimal = string.find(text, "%.")
	text = string.gsub(text, "[^%d]", "")

	if allowDecimal and firstDecimal then
		local before = string.sub(text, 1, firstDecimal - 1)
		local after = string.sub(text, firstDecimal)
		text = before .. "." .. after
	end

	if negative then
		text = "-" .. text
	end

	return text
end

return TextSanitizers
