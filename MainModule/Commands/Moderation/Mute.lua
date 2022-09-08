local Command = {}
Command.Name = "mute"
Command.Description = "Mutes the specified user(s)."
Command.Aliases = {"stopchatting"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't mute no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			env.RemoteEvent:FireClient(
				target,
				"CanChat",
				false
			)
		end
	end
end

return Command