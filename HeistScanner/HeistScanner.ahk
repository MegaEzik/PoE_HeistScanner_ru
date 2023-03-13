#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

If !A_IsAdmin {
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" %args%
	ExitApp
}

#include <Vis2>
;#Include, %A_ScriptDir%\resources\ahk\ItemDataConverterLib.ahk

GroupAdd, WindowGrp, Path of Exile ahk_class POEWindowClass
GroupAdd, WindowGrp, ahk_exe GeForceNOWStreamer.exe

global configFile:="..\settings.ini", league, prjName:="Heist Scanner"

IniRead, league, %configFile%, settings, league, %A_Space%
IniRead, hotkeyHeistScanner, %configFile%, hotkeys, hotkeyHeistScanner, %A_Space%
If (hotkeyHeistScanner!="")
	Hotkey, % hotkeyHeistScanner, useHeistScan, On

Menu, Tray, Tip, %prjName% (%league%)

uxtheme:=DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
SetPreferredAppMode:=DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
FlushMenuThemes:=DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
DllCall(SetPreferredAppMode, "int", 1)
DllCall(FlushMenuThemes)

Menu, Tray, NoStandard
Menu, Tray, Add, League, leagues
Menu, Tray, Default, League
Menu, Tray, Add
Menu, Tray, Standard

Return

;###############################################

#IfWinActive ahk_group WindowGrp

useHeistScan(){
	Name:=OCR(,"rus")
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
	If RegExMatch(Name, "(.*)`r", res) {
		url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22filters%22:{},%22name%22:%22" res1 "%22}}"
		run, "%url%"
		return
	}
	url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22filters%22:{},%22type%22:%22" Name "%22}}"
	run, "%url%"
	return
}

LeaguesList(){
	RunWait curl -L -o "leagues.json" "http://api.pathofexile.com/leagues?type=main"
	
	FileRead, html, leagues.json
	html:=StrReplace(html, "},{", "},`n{")
	
	leagues_list:=""
	
	htmlSplit:=StrSplit(html, "`n")
	For k, val in htmlSplit {
		If !RegExMatch(htmlSplit[k], "SSF") && RegExMatch(htmlSplit[k], "id"":""(.*)"",""realm", res)
			leagues_list.="|" res1
	}
	
	leagues_list:=subStr(leagues_list, 2)
	
	return leagues_list
}

leagues(){
	Menu, LeaguesMenu, Add
	Menu, LeaguesMenu, DeleteAll
	LeaguesListSplit:=strSplit(LeaguesList(), "|")
	For k, val in LeaguesListSplit {
		LeagueName:=LeaguesListSplit[k]
		Menu, LeaguesMenu, Add, %LeagueName%, setLeague
	}
	Menu, LeaguesMenu, Show
}

setLeague(Name){
	IniWrite, %Name%, %configFile%, settings, league
	Reload
}

class Globals {
	Set(name, value) {
		Globals[name] := value
	}

	Get(name, value_default="") {
		result := Globals[name]
		If (result == "") {
			result := value_default
		}
		return result
	}
}
