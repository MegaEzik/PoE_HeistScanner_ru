#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

If !A_IsAdmin {
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" %args%
	ExitApp
}

#include <Vis2Patched>

GroupAdd, WindowGrp, Path of Exile ahk_class POEWindowClass

global configFile:="..\settings.ini", league, prjName:="Heist Scanner"

IniRead, league, %configFile%, settings, league, %A_Space%
IniRead, hotkeyHeistScanner, %configFile%, hotkeys, hotkeyHeistScanner, %A_Space%
If (hotkeyHeistScanner!="")
	Hotkey, % hotkeyHeistScanner, useHeistScan, On

Menu, Tray, Tip, %prjName%

Return

;###############################################

#IfWinActive ahk_group WindowGrp

useHeistScan(){
	Name:=OCR(,"eng+rus")
	If (Name="")
		return
	If RegExMatch(Name, "[A-Za-z]+") && !RegExMatch(Name, "[А-Яа-яЁё]+") {
		If RegExMatch(Name, "i)(Anomalous|Divergent|Phantasmal)") {
			run, https://poe.ninja/challenge/skill-gems?name=%Name%&corrupted=No
			return
		}
		If RegExMatch(Name, "i)Delirium Orb"){
			run, https://poe.ninja/challenge/delirium-orbs?name=%Name%
			return
		}
		If RegExMatch(Name, "i)(Orb|Lens)"){
			run, https://poe.ninja/challenge/currency?name=%Name%
			return
		}
		return
	}
	If RegExMatch(Name, "[А-Яа-яЁё]+") {
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
			url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22name%22:%22" res1 "%22}}"
			run, "%url%"
			return
		}
		url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22type%22:%22" Name "%22}}"
		run, "%url%"
		return
	}
}
