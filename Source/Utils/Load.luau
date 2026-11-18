local e = getgenv().CoguHub
local i = e._

local rawcloudsource = "https://raw.githubusercontent.com/Enzokas/coguhub/refs/heads/main/Source"
local localsource = "coguhub/Source"

local runninglocal = e.DevFlags.RunLocal == true

return function(file)
	if file:match("@") then
		local gameName = i.Info.GamesIndex[tostring(game.GameId)]
		file = (file:gsub("@", `/Scripts/Games/{gameName}/` or "/null/error/"))
	end

	if runninglocal then
		local fullPath = `{localsource}/{file}`
		local src, err = loadstring(readfile(fullPath))
		if not src then
			i.Err(`compile {fullPath}: {err}`)
			error("compile failed")
		end
		local ok, res = pcall(src)
		if not ok then
			i.Err(`run {fullPath}: {res}`)
			error("run failed")
		end
		return res
	else
		local src, err = loadstring(game:HttpGet(`{rawcloudsource}/{file}`))
		if not src then
			i.Err(`http compile {file}: {err}`)
			error("http compile failed")
		end
		local ok, res = pcall(src)
		if not ok then
			i.Err(`http run {file}: {res}`)
			error("http run failed")
		end
		return res
	end
end
