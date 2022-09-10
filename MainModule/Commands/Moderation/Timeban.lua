local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "timeban"
Command.Description = "Bans a user from the game for a specified amount of time."
Command.Aliases = {"tban"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Time (mins)", ["Type"] = "String"}, {["Name"] = "Reason", ["Type"] = "String"}}
Command.RequiredAdminLevel = 2
Command.ArgsToReplace = {1}

Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to ban."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
  if not args[2] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify an amount of time."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local Target = args[1]
  local Mins = tonumber(args[2])
  local UnbanTime = os.time() + (Mins*60)
	local BanReason = "You've been time banned."
	local nt = {}
	if #args >= 3 then
		for i = 3,#args do
			table.insert(nt, args[i])
		end
	end
	BanReason = string.format("%s\nReason: %s",BanReason,if #args >= 2 then table.concat(nt," ") else "No reason provided.")
	BanReason = string.format("%s\nModerator:\n%s",Chat:FilterStringForBroadcast(BanReason, plr),plr.Name)
  BanReason = string.format("%s\nExpires:%s", os.date("%A, %b %w @ %H:%M (UTC)", UnbanTime))
	if not Target[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to ban."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	else
		if #Target > 5 then
			if env.API.requestAuth(plr, "You're attempting to time ban more than 5 people at a time, are you sure you want to contunue?") == false then
				return
			end
		end
		for _, tgt in Target do
			local UserId = nil
			if typeof(tgt) == "Instance" then
				UserId = tgt.UserId
			elseif tonumber(tgt) ~= nil then
				UserId = tonumber(tgt)
			else
				local suc = pcall(function()
					UserId = Players:GetUserIdFromNameAsync(tgt)
				end)
				if not suc then
					env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s isn't a valid user.", tgt)})
					env.RemoteEvent:FireClient(plr, "playSound", "Error")
					return
				end
			end
			if UserId == plr.UserId then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't server ban yourself."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			if (env.Admins[UserId] or 0) < env.API.getAdminLevel(plr) then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Success", Text = string.format("Successfully server banned %s.", Players:GetNameFromUserIdAsync(UserId))})
				env.RemoteEvent:FireClient(plr, "playSound", "Success")
				local tgtplr = Players:GetPlayerByUserId(tonumber(UserId))
				if tgtplr then
					env.API.removePlayerFromServer(tgtplr, BanReason)
				end
				env.API.addUserToBans(UserId, {Type = "Time", Reason = BanReason, UnbanTime = UnbanTime})
				env.API.addToBanHistory(UserId, 
					string.format("[{time:%s:sdi}] Time Banned at {time:%s:ampm} by %s for reason %s", 
						os.time(),
						os.time(),
						plr.Name,
						if #args >= 2 then table.concat(nt," ") else "No reason provided."
					)
				)
			else
				env.RemoteEvent:FireClient(plr,"showHint", {
					Title = "Permissions Error", 
					Text = string.format("%s has a higher admin level or the same as you.", Players:GetNameFromUserIdAsync(UserId))
				})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		end
	end
end

return Command