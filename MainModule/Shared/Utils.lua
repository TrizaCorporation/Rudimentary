local Utils = {}

function Utils.CloneTable(tab)
	local ClonedTable = {}
	for i,v in pairs (tab) do
		if typeof(v) == "table" then
			ClonedTable[i] = Utils.CloneTable(v)
		else
			ClonedTable[i] = v
		end
	end
	return ClonedTable
end

function Utils.determineListLength(list)
	local number = 0
	for _, item in (list) do
		number = number +1
	end
	return number
end

function Utils.hasProperty(item, property)
	local suc,err = pcall(function()
		local test = item[property]
	end)
	return suc
end

function Utils.clearAllChildrenExcept(item, exemptitem)
	for _, item in pairs(item:GetChildren()) do
		if item ~= exemptitem then item:Destroy() end
	end
end

function Utils.filterOutRichTextData(text)
	return text:gsub("(\\?)<[^<>]->", { [''] = '' })
end

function Utils.shortenText(text, length)
	if not text then return end
	if text:len() <= length then return text end
	return string.format("%s...",text:sub(1,length))
end

function Utils.reverseTable(tab)
	local ClonedTable = Utils.CloneTable(tab)
	local NewTab = {}
	for i, item in pairs(ClonedTable) do
		NewTab[(#ClonedTable-i)+1] = item
	end
	return NewTab
end

function Utils.addCommas(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,")
	:gsub(",(%-?)$","%1"):reverse()
end

function Utils.formatTimeFromSeconds(secs)
	local newsecs = secs
	local hrs = math.floor(newsecs/3600)
	newsecs -= hrs * 3600
	local mins = math.floor(newsecs/60)
	newsecs -= mins * 60
	newsecs = math.floor(newsecs)
	return string.format("%s:%s:%s", if tostring(hrs):len() == 1 then "0"..hrs else hrs, if tostring(mins):len() == 1 then "0"..mins else mins, if tostring(newsecs):len() == 1 then "0"..newsecs else newsecs)
end

function Utils.findUser(username)
	if username == "" or not username then return end
	username = username:lower()
	for _, user in pairs (game.Players:GetPlayers()) do
		if username == user.Name:lower():sub(1,username:len()) then
			return user
		end
	end
	for _, user in pairs (game.Players:GetPlayers()) do
		if username == user.DisplayName:lower():sub(1,username:len()) then
			return user
		end
	end
end

function Utils.textToBool(text)
	text = tostring(text)
	local texttobool = {["true"] = true, ["false"] = false, ["yes"] = true, ["no"] = false}
	return texttobool[text:lower()]
end

return Utils
