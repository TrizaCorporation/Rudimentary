local Command = {}
Command.Name = "unnoclip"
Command.Description = "Clips the specified user(s)."
Command.Aliases = {"clip"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env : table, plr : Player, args : table)
    if not args[1] then
        env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't clip no one."})
        env.RemoteEvent:FireClient(plr, "playSound", "Error")
        return
   end 

   for _, target : Player in args[1] do
        if typeof(target) == "Instance" then
            if not target.Character:FindFirstChild("RudimentaryNoClipHandler") then
                env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s isn't noclipping.", target.Name)})
                env.RemoteEvent:FireClient(plr, "playSound", "Error")
            end
            target.Character.RudimentaryNoClipHandler:Destroy()
        end
   end
end

return Command
