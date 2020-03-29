IfNotExist, location.txt
{
	FileSelectFile, SelectedFile, 3, MinecraftLauncher.exe, Select the Minecraft launcher, Applications (*.exe; *.jar)
	if SelectedFile =
	{
		MsgBox, You didn't select anything, try again.
		Reload
	}
	else
	{
		FileAppend, %SelectedFile%`n, location.txt
		InputBox, OutputBox, Name of the Vivecraft instance. if just Vivecraft is enterd it will select the fist version if you search for Vivecraft and select sort by Name, , , 1000, 100, , , , , Vivecraft
		if ErrorLevel
		{
			MsgBox, You didn't wrote anything, try again.
			FileDelete, location.txt
			Reload
		}
		else
			FileAppend, %OutputBox%, location.txt
			MsgBox, Edit the launcher folder and the instance name in the location.txt if needed
			Reload
	}
}
Else
{
FileReadLine, OutputVar, location.txt, 1
FileReadLine, OutputBox, location.txt, 2
Process, Exist, "Minecraft Launcher"
if ErrorLevel
Run %comspec% /c "%OutputVar%"
Run, %OutputVar%
WinWait, ahk_exe MinecraftLauncher.exe
sleep, 500
CoordMode Window
IfWinNotActive ahk_exe MinecraftLauncher.exe
	WinActivate ahk_exe MinecraftLauncher.exe
IfWinActive ahk_exe MinecraftLauncher.exe
	WinGetActiveStats, Title, Width, Height, X, Y
	WPlayB := 260
	HPlayB := 100
	WPlay := Width / 2 + 370
	HPlay := 200
	WInstall := 340
	HInstall := 100
	WSearch := Width / 2 - 80
	HSearch := 140
	WSort := Width / 2 + 20
	HSort := 150
	WSortName := Width / 2 + 20
	HSortName := 220
	
	
	MouseGetPos, MWidth, MHeight
	MouseClick, Left, WPlayB, HPlayB, 1, 5
	MouseClick, Left, WInstall, HInstall, 1, 5
	MouseClick, Left, WSort, HSort, 1, 5
	MouseClick, Left, WSortName, HSortName, 1, 5
	MouseClick, Left, WSearch, HSearch, 1, 5
	sleep, 50
	Send, %OutputBox%
	sleep, 50
	MouseClick, Left, WPlay, HPlay, 1, 5
	MouseMove, MWidth, MHeight
}