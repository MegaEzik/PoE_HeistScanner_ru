#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

#include <Vis2Patched>

global configFile:="..\settings.ini", mainConfig:="..\settings.ini", prjName:="HeistScanner by MegaEzik", langMode:="eng+rus", verScript, labMode, league, ninjaLeague
If FileExist("..\..\settings.ini")
	configFile:="..\..\settings.ini"
	
If (ScriptName="tmpLoader.ahk" || A_Args[1]!="/launch") || (A_Args[1]="/exit")
	ExitApp

/*
If RegExMatch(A_Args[2], "i)/langmode=(.*)", res) && (res1!="")
	LangMode:=res1
*/

If !A_IsAdmin
	reStart()

GroupAdd, WindowGrp, ahk_exe GeForceNOW.exe
GroupAdd, WindowGrp, Path of Exile ahk_class POEWindowClass

IniRead, verScript, ..\HeistScanner.ahk, info, version, 230313
IniRead, labMode, %mainConfig%, settings, labMode, 0
IniRead, langMode, %mainConfig%, settings, langMode, eng+rus

IniRead, league, %configFile%, settings, league, %A_Space%
IniRead, hotkeyHeistScanner, %configFile%, hotkeys, hotkeyHeistScanner, %A_Space%
If (hotkeyHeistScanner="")
	ExitApp
Hotkey, % hotkeyHeistScanner, useHeistScan, On
	
setNinjaLeague()

Menu, Tray, Tip, %prjName% v%verScript%`n%league% (%ninjaLeague%)

uxtheme:=DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
SetPreferredAppMode:=DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
FlushMenuThemes:=DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
DllCall(SetPreferredAppMode, "int", 1)
DllCall(FlushMenuThemes)

Menu, Tray, NoStandard
Menu, Tray, Add, Open GitHub, openGitHub
Menu, Tray, Add
Menu, Tray, Add, Edit 'settings.ini', editConfig
Menu, Tray, Add, League, switchLeague
Menu, Tray, Add, Labyrinth Mode, changeLabMode
Menu, Tray, Add, Languages, restartWithLanguage
If labMode
	Menu, Tray, Check, Labyrinth Mode
Menu, Tray, Add
Menu, Tray, Add, Reload, reStart
Menu, Tray, Add, Exit, closeScript
Menu, Tray, Default, Labyrinth Mode


If (langMode!="eng+rus")
	TrayTip, %prjName%, Languages=%langMode%
	
pToken:=Gdip_Startup()

Return

;###############################################

#IfWinActive ahk_group WindowGrp

showScreenUI() {
	FileDelete, %A_ScriptDir%\tmp\ScreenShot.bmp
	BlockInput On
	SendInput, {Alt Down}
	Sleep 100
	Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen(1), A_ScriptDir "\tmp\ScreenShot.bmp")
	Sleep 100
	SendInput, {Alt Up}
	BlockInput Off
	Gui, ScreenUI:Destroy
	Gui, ScreenUI:Add, Picture, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %A_ScriptDir%\tmp\ScreenShot.bmp
	Gui, ScreenUI:-Caption -Border +AlwaysOnTop
	Gui, ScreenUI:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, ScreenUI
}

useHeistScan(){
	;Sleep 100
	If labMode
		showScreenUI()
	Name:=OCR(,langMode)
	
	Gui, ScreenUI:Destroy
	If (Name="")
		return
	If RegExMatch(Name, "[A-Za-z]+") && !RegExMatch(Name, "[А-Яа-яЁё]+") {
		/*
		If RegExMatch(Name, "i)(Anomalous|Divergent|Phantasmal)") {
			run, https://poe.ninja/%ninjaLeague%/skill-gems?name=%Name%&corrupted=No
			return
		}
		*/
		If RegExMatch(Name, "i)(Replica .*)", res) || RegExMatch(Name, "(.*)`r", res) {
			url:="https://www.pathofexile.com/trade/search/" league "?q={%22query%22:{%22name%22:%22" Trim(StrTitle(res1)) "%22}}"
			run, "%url%"
			return
		}
		If RegExMatch(Name, "i)Fossil"){
			run, https://poe.ninja/%ninjaLeague%/fossils?name=%Name%
			return
		}
		If RegExMatch(Name, "i)Incubator"){
			run, https://poe.ninja/%ninjaLeague%/incubators?name=%Name%
			return
		}
		If RegExMatch(Name, "i)Scarab"){
			run, https://poe.ninja/%ninjaLeague%/scarabs?name=%Name%
			return
		}
		If RegExMatch(Name, "i)Delirium Orb"){
			run, https://poe.ninja/%ninjaLeague%/delirium-orbs?name=%Name%
			return
		}
		If RegExMatch(Name, "i)(Orb|Shard|Stacked Deck)") {
			run, https://poe.ninja/%ninjaLeague%/currency?name=%Name%
			return
		}
		run, https://poe.ninja/%ninjaLeague%/skill-gems?name=%Name%&corrupted=No
		return
	}
	If RegExMatch(Name, "[А-Яа-яЁё]+") {
		/*
		If RegExMatch(Name, "(Аномальный|Искривлённый|Фантомный): (.*)", res){
			gemType:=1
			If (res1="Искривлённый")
				gemType:=2
			If (res1="Фантомный")
				gemType:=3
			url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22filters%22:{%22misc_filters%22:{%22filters%22:{%22gem_alternate_quality%22:{%22option%22:%22" gemType "%22}, %22corrupted%22: false}}},%22type%22:%22" res2 "%22}}"
			run, "%url%"
			return
		}
		*/
		If RegExMatch(Name, "(Копия .*)", res) || RegExMatch(Name, "(.*)`r", res) {
			url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22name%22:%22" res1 "%22}}"
			run, "%url%"
			return
		}
		url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22type%22:%22" Name "%22}}"
		run, "%url%"
		return
	}
}

changeLabMode(){
	If labMode {
		IniWrite, 0, %mainConfig%, settings, labMode
	} Else {
		IniWrite, 1, %mainConfig%, settings, labMode
	}
	reStart()
}

switchLeague() {
	;RunWait, curl -L -o "leagues.json" "http://api.pathofexile.com/leagues?type=main",, hide
	UrlDownloadToFile, https://api.pathofexile.com/leagues?realm=pc, tmp\leagues.json

	FileRead, html, tmp\leagues.json
	html:=StrReplace(html, "},{", "},`n{")
	
	Menu, LeaguesMenu, Add
	Menu, LeaguesMenu, DeleteAll
	
	htmlSplit:=StrSplit(html, "`n")
	For k, val in htmlSplit
		If RegExMatch(htmlSplit[k], "U)id"":""(.*)""", res) && RegExMatch(htmlSplit[k], """realm"":""pc""")
			If !RegExMatch(res1, "i)(SSF|Solo Self-Found|Ruthless)")
				Menu, LeaguesMenu, Add, %res1%, setLeague

	Menu, LeaguesMenu, Show
}

setLeague(Name){
	IniWrite, %Name%, %configFile%, settings, league
	reStart()
}

restartWithLanguage(){
	InputBox, langMode, Restart With Language,,, 300, 100,,,,,%langMode%
	If (langMode="")
		langMode:="eng+rus"
	IniWrite, %langMode%, %mainConfig%, settings, langMode
	reStart()
}

setNinjaLeague() {
	ninjaLeague:="challenge"
	If (league="Standard") {
		ninjaLeague:="standard"
		return
	}
	If (league="Hardcore") {
		ninjaLeague:="hardcore"
		return
	}
	If RegExMatch(league, "(Hardcore|HC)")	{
		ninjaLeague:="challengehc"
		return
	}
}

openGitHub() {
	run, https://github.com/MegaEzik/PoE_HeistScanner_ru
}

editConfig() {
	RunWait, notepad.exe "%configFile%"
	ReStart()
}

StrTitle(SrcText) {
	StringUpper, Result, SrcText, T
	Return Result
}

closeScript() {
	ExitApp
}

reStart() {
	;Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" /launch /langmode=%langMode%
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" /launch
	ExitApp
}
