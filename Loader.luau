getgenv().CoguHub = getgenv().CoguHub or {}
getgenv().CoguHub._ = getgenv().CoguHub._ or {}
local e = getgenv().CoguHub
local i = e._

i.Service = function(service)
	return if cloneref then cloneref(game:GetService(service)) else game:GetService(service)
end
i.Err = function(msg)
	if not isfolder("coguhub/Logs") then
		makefolder("coguhub/Logs")
	end
	local cur = ""
	if isfile("coguhub/Logs/errors.txt") then
		cur = readfile("coguhub/Logs/errors.txt")
	end
	writefile("coguhub/Logs/errors.txt", cur .. "[CoguHub] " .. msg .. "\n")
end
i.Hui = gethui() or cloneref(game.CoreGui)

if getgenv().CoguHubAutoSetRunLocal == true then
	e.DevFlags = e.DevFlags or {}
	e.DevFlags.RunLocal = true
end

local rawcloudsource = "https://raw.githubusercontent.com/Enzokas/coguhub/refs/heads/main/Source"
local localsource = "coguhub/Source"

local load
if e.DevFlags.RunLocal == true then
	local src, err = loadstring(readfile(localsource .. "/Utils/Load.luau"))
	if not src then
		i.Err("Load.luau compile: " .. tostring(err))
		return
	end
	local ok, res = pcall(src)
	if not ok then
		i.Err("Load.luau run: " .. tostring(res))
		return
	end
	load = res
else
	local src, err = loadstring(game:HttpGet(rawcloudsource .. "/Utils/Load.luau"))
	if not src then
		i.Err("Load.luau http compile: " .. tostring(err))
		return
	end
	local ok, res = pcall(src)
	if not ok then
		i.Err("Load.luau http run: " .. tostring(res))
		return
	end
	load = res
end

i.Load = load
i.Info = load("Info.luau")

if not i.Info.GamesIndex[tostring(game.GameId)] then
	i.Service("CoreGui"):SetCore("Notification", {
		Title = "CoguHub",
		Text = "This game is not supported.",
		Duration = 5,
	})
	return
end

i.UI = load("Utils/UI.luau")

load("@Main.luau")
