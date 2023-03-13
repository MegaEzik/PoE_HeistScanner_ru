#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

If !A_IsAdmin {
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" %args%
	ExitApp
}

#include <Vis2>
#Include, %A_ScriptDir%\resources\ahk\ItemDataConverterLib.ahk

GroupAdd, WindowGrp, Path of Exile ahk_class POEWindowClass
GroupAdd, WindowGrp, ahk_exe GeForceNOWStreamer.exe

global configFile:="..\settings.ini", league, prjName:="Heist Scanner powered by Vis2"

Menu, Tray, Tip, %prjName%

IniRead, league, %configFile%, settings, league, %A_Space%
IniRead, hotkeyHeistScanner, %configFile%, hotkeys, hotkeyHeistScanner, %A_Space%
If (hotkeyHeistScanner!="")
	Hotkey, % hotkeyHeistScanner, useHeistScan, On

IDCL_Init()

Return

;###############################################

#IfWinActive ahk_group WindowGrp

useHeistScan(){
	Name:=OCR(,"eng+rus")
	Name_En:=IDCL_ConvertName(Name, 11)
	If RegExMatch(Name_En, "(Anomalous|Divergent|Phantasmal)") {
		run, "https://poe.ninja/challenge/skill-gems?name=%Name_En%&corrupted=No"	
		return
	}
	If RegExMatch(Name_En, "Delirium Orb") {
		run, "https://poe.ninja/challenge/delirium-orbs?name=%Name_En%"
		return
	}
	If RegExMatch(Name_En, "(Orb|Lens)") {
		run, "https://poe.ninja/challenge/currency?name=%Name_En%"
		return
	}
	url:="https://ru.pathofexile.com/trade/search/" league "?q={%22query%22:{%22filters%22:{},%22name%22:%22" Name "%22}}"
	run, "%url%"
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
