﻿#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

#include <Vis2Patched>

global configFile:="..\settings.ini", prjName:="HeistScanner by MegaEzik", LangMode:="eng+rus", verScript, league, ninjaLeague
If FileExist("..\..\settings.ini")
	configFile:="..\..\settings.ini"
	
If (ScriptName="tmpLoader.ahk" || A_Args[1]!="/launch") || (A_Args[1]="/exit")
	ExitApp

If RegExMatch(A_Args[2], "i)/langmode=(.*)", res) && (res1!="")
	LangMode:=res1

If !A_IsAdmin
	reStart()

GroupAdd, WindowGrp, ahk_exe GeForceNOW.exe
GroupAdd, WindowGrp, Path of Exile ahk_class POEWindowClass

IniRead, verScript, ..\HeistScanner.ahk, info, version, 230313

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
Menu, Tray, Add, Languages, restartWithLanguage
Menu, Tray, Add, Change League, switchLeague
Menu, Tray, Add
Menu, Tray, Add, Reload, reStart
Menu, Tray, Add, Exit, closeScript
Menu, Tray, Default, Change League


If (LangMode!="eng+rus")
	TrayTip, %prjName%, Languages=%LangMode%

Return

;###############################################

#IfWinActive ahk_group WindowGrp

useHeistScan(){
	Name:=OCR(,LangMode)
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

switchLeague() {
	;RunWait, curl -L -o "leagues.json" "http://api.pathofexile.com/leagues?type=main",, hide
	UrlDownloadToFile, http://api.pathofexile.com/leagues?type=main, tmp\leagues.json

	FileRead, html, tmp\leagues.json
	html:=StrReplace(html, "},{", "},`n{")
	
	Menu, LeaguesMenu, Add
	Menu, LeaguesMenu, DeleteAll
	
	htmlSplit:=StrSplit(html, "`n")
	For k, val in htmlSplit {
		If !RegExMatch(htmlSplit[k], "(SSF|Ruthless)") && RegExMatch(htmlSplit[k], "id"":""(.*)"",""realm", res)
			Menu, LeaguesMenu, Add, %res1%, setLeague
	}

	Menu, LeaguesMenu, Show
}

setLeague(Name){
	IniWrite, %Name%, %configFile%, settings, league
	reStart()
}

restartWithLanguage(){
	InputBox, LangMode, Restart With Language,,, 300, 100,,,,,%LangMode%
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
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" /launch /langmode=%LangMode%
	ExitApp
}
