local e = getgenv().CoguHub
local i = e._

local UI = {
	Tabs = {},

	Groups = {},
	Elements = {},
}

UI.Lib =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

UI.Window = UI.Lib:CreateWindow({
	Title = "CoguHub",
	Footer = "Made by laninha do seu coração (Cogumeta)",
	Icon = i.Info.Icon,
	NotifySide = "Right",
})

return UI
