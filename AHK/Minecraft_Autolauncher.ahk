LineNr := 0
Select := 0
Dir := A_WorkingDir
Loca := ""
SplitPath, A_ScriptName,,,, ScriptName
INIFile := ScriptName ".ini"
Loop, read, %INIFile%
{
	LineNr++
	Line%LineNr% := A_LoopReadLine
	if ((LineNr = 1)and((A_LoopReadLine = "v0.5")or(A_LoopReadLine = "v0.6")))
		LineNr := 1
	else if (LineNr = 1){
		Line2Nr := 0
		MsgBox, 4, Minecraft AutoLaucher, The %INIFile% was not writen for Minecraft AutoLaucher v0.5 or v0.6`nDelete existing file(Yes)`nStop Script(No)
		IfMsgBox, Yes
		{
		Line2Nr := 1
		}
		else
			ExitApp	
	}
}
if (Line2Nr = 1) {
		FileDelete, %INIFile%
		LineNr := 0
		Line2Nr := 0
}
if (LineNr = 0) {
	FileAppend, v0.6, %INIFile%
	LineNr++
}
if (LineNr = 1) {
	Drives := ["A:\","B:\","C:\","D:\","E:\","F:\"]
	VProgramFiles := ["Program Files (x86)\","Program Files\"]
	Loop % Drives.Length() {
		Drive := Drives[A_Index]
		Loop % VProgramFiles.Length() {
			ProgramFile := VProgramFiles[A_Index]
			Loc := Drive ProgramFile "Minecraft Launcher\MinecraftLauncher.exe"
			if FileExist(Loc){
				if (Select = 0) {
					Msgbox, 3, Minecraft AutoLaucher, Found a Minecraft Launcher at`n%Loc%`nUse it as your Minecraft Laucher Folder
					IfMsgBox, Yes 
					{
						Loca := Loc
						Select := 1
					}
					IfMsgBox, No
						Select := 3
					if (Select = 0)
						Select := 2
					if (Select = 3)
					Select := 0
				}
			}
		}
	}
	if ((Select = 2) or (Select = 0)) {
		While (Loca = "") {
			FileSelectFile, Loca, 3, MinecraftLauncher.exe, Select the Minecraft launcher, Applications (*.exe; *.jar)
			if (Loca = "")
				MsgBox, 0, Minecraft AutoLaucher, You didn't select anything, try again.
		}
		Select := 1
		}
	if (Select = 1)
	FileAppend, `n%Loca%, %INIFile%
	Line2 := Loca
	LineNr++
}
if (LineNr = 2) {
	emty := 0
	While ((Profile = "")and(emty=0))
	{
	InputBox, Profile, Minecraft AutoLaucher, Type the name of the Profile you want.`nIf there are multiple Profiles matching`nit will play the profile based on your sorting setting.`nThis setting is changeable in the next message box, , 350, 180, , , , , vivecraft
	if (Profile = "")
		MsgBox , 4, Minecraft AutoLaucher, You didn't wrote anything. Continue Anyway? 
		IfMsgBox Yes
			emty := 1
	}
	emty := 0
	FileAppend, `n%Profile%, %INIFile%
	Line3 := %Profile%
	LineNr++
}
if (LineNr = 3) {
	
	MsgBox , 4, Minecraft AutoLaucher, SortByLastPlayed`n[Self explanatory]`n(Yes) `n`nor `n`nSortByName`n[1.12 first 1.13 second, If you use the version folder serching option(Next box) it doesn't make a difference]`n(No)
	IfMsgBox, No
		Select := "Name"
	else
		Select := "Last"
	MsgBox, 3, Minecraft AutoLaucher, SortbyNameNew(Yes) `n`nSortByDateNew(No) `n`nUseOldVersion(Cancel)
		IfMsgBox, No
		{
			Select1 := "Date"
			MsgBox , 4, Minecraft AutoLaucher, SortUp	jjjj.mm.dd`n[like this first to last 2020.03.10, 2020.03.09, 2020.03.08]`n(Yes)`n`nSortDown	jjjj.mm.dd`n[like this fist to last 2020.03.08, 2020.03.09, 2020.03.10]`n(No)
			IfMsgBox, No
				Select2 := "SortDown"
			else
				Select2 := "SortUp"
		}
		IfMsgBox, Cancel
		{
			Select1 := "Old"
			Select2 := "None"
		}
		else if !(Select1 = "Date")
		{
			Select1 := "Name"
			MsgBox , 4, Minecraft AutoLaucher, SortUp[like this first to last 1.14.4, 1.13.2, 1.12](Yes)`n`nSortDown[like this fist to last 1.12, 1.13.2, 1.14.4](No)
			IfMsgBox, No
				Select2 := "SortDown"
			else
				Select2 := "SortUp"
		}
		Line4 := Select A_Tab Select1 A_Tab Select2
		FileAppend, `n%Line4%, %INIFile%
		LineNr++
}
if (LineNr = 4) {
	LineOld := False
	Loop, parse, Line4, %A_Tab%
	{
		if ((A_Index = 2) and (A_LoopField = "Old"))
			LineOld := True
	}
}

if ((LineNr = 4) and (LineOld = False)) {
	Select := 0
	MineVersions := A_AppData "\.minecraft\versions\*"
	Msgbox, 4, Minecraft AutoLaucher, Use the default Minecraft Version Folder`n%MineVersions%`nUse it as your Minecraft Version Folder
	IfMsgBox, Yes
	{
		Select := 1
	}
	if (Select = 0) {
		While (MineVersion = "") {
			FileSelectFolder, MineVersion, versions, 7, Select the Minecraft versions Folder
			if (MineVersion = "")
				MsgBox, You didn't select anything, try again.
		}
		MineVersion := MineVersion "\*"
		MineVersions := MineVersion
	}
	Line5 := MineVersions
	FileAppend, `n%MineVersions%, %INIFile%
	LineNr++
}
else if (LineNr = 4) {
	MineVersions := A_AppData "\.minecraft\versions"
	Line5 := MineVersions
	FileAppend, `n%MineVersions%, %INIFile%
	LineNr++
}
if (LineNr = 5) {
	WinWaitTime := 0
	While(WinWaitTime=0)
	{
		InputBox, TimeImput, Minecraft AutoLaucher, Type How Long This Waits for the Minecraft Laucher in ms (2000ms = 2 Seconds), , , , , , , , 2000
		if(TimeImput="")
			MsgBox, 0, Minecraft AutoLaucher, You didn't type anything, try again.
		else
			if(TimeImput*0=0)
				WinWaitTime := TimeImput	
			else
				MsgBox, 0, Minecraft AutoLaucher, Please Type a Number.
	}
	waitforwin := WinWaitTime
	Line6 := waitforwin
	FileAppend, `n%waitforwin%, %INIFile%
	LineNr++
	LineNr++
}
if (LineNr = 7){
	MsgBox, 4, Minecraft AutoLaucher, Start Minecraft Now
		IfMsgBox, No
			ExitApp
		else
			Reload
}

;Filecheck End
;Minecraft Start


Loop, parse, Line2, \
{
	Minecraftexe := A_LoopField
}
Minecraftxex := "ahk_exe " Minecraftexe
IfWinNotExist, %Minecraftxex%
{
	Run, %Line2%
	sleep, 100
}
sleep, %Line6%
IfWinNotActive, %Minecraftxex%
{
	WinActivate, %Minecraftxex%
	sleep, 100
}
IfWinActive, %Minecraftxex%
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
	WSortPlayed := Width / 2 + 20
	HSortPlayed := 190
	
	;Variablen Ende
	;Profiel Starten
	
	SFile := Line3
	Loop, parse, Line4, %A_Tab%
	{
			Index%A_Index% := A_LoopField 
	}
	if (Index2 = "Name"){
		FileList1 := ""
		R := ""
		if (Index3 = "SortDown")
			R := "R"
		Loop, Files, %Line5%, D
		{
			FileList1 = %FileList1%%A_LoopFileName%`n
		}
		Sort, FileList1 , %R%
		Loop, Parse, FileList1, `n 
		{
		if A_LoopField =
			continue
		else if (InStr(A_LoopField, Line3 , CaseSensitive := false, StartingPos := 1, Occurrence := 1))
			SFile := A_LoopField
		}
	}
	if (Index2 = "Date"){
		FileList2 := ""
		R := ""
		if (Index3 = "SortDown")
			R := "R"
		Loop, Files, %Line5%, D
		{
			FileList2 = %FileList2%%A_LoopFileTimeModified%`t%A_LoopFileName%`n
		}
		Sort, FileList2 , %R%
		Loop, Parse, FileList2, `n 
		{
		if A_LoopField =
			continue
		else if (InStr(A_LoopField, Line3 , CaseSensitive := false, StartingPos := 1, Occurrence := 1))
			SFile := A_LoopField
		}
		StringSplit, FileItem, SFile, %A_Tab%  ; Split into two parts at the tab char.
		SFile := FileItem2
	}
	
	MouseGetPos, MWidth, MHeight
	MouseClick, Left, WPlayB, HPlayB, 1, 5
	MouseClick, Left, WInstall, HInstall, 1, 5
	MouseClick, Left, WSort, HSort, 1, 5
	if (Index1 = "Last")
		MouseClick, Left, WSortPlayed, HSortPlayed, 1, 5
	else
		MouseClick, Left, WSortName, HSortName, 1, 5
	MouseClick, Left, WSearch, HSearch, 1, 5
	sleep, 50
	Send, %SFile%
	sleep, 50
	MouseClick, Left, WPlay, HPlay, 1, 5
	MouseMove, MWidth, MHeight