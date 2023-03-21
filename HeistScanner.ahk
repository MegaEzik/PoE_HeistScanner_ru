;HeistScannerLoader ver230321
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

If (!A_IsAdmin) {
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
	ExitApp
}

If !FileExist(A_WinDir "\System32\curl.exe") {
	MsgBox, 0x1010,, Требуется OS Windows 10 1809 или выше!
	ExitApp
}

SplashTextOn, 300, 20, Heist Scanner, Подготовка к использованию...

update()

If !FileExist("settings.ini") {
	IniWrite, F2, settings.ini, hotkeys, hotkeyHeistScanner
	IniWrite, %A_Space%, settings.ini, settings, league
}

FileLoader("HeistScanner\bin\leptonica_util\leptonica_util.exe", "https://raw.githubusercontent.com/iseahound/Vis2/master/bin/leptonica_util/leptonica_util.exe")
FileLoader("HeistScanner\bin\leptonica_util\liblept168.dll", "https://raw.githubusercontent.com/iseahound/Vis2/master/bin/leptonica_util/liblept168.dll")
FileLoader("HeistScanner\bin\leptonica_util\Microsoft.VC90.CRT.manifest", "https://raw.githubusercontent.com/iseahound/Vis2/master/bin/leptonica_util/Microsoft.VC90.CRT.manifest")
FileLoader("HeistScanner\bin\tesseract\tesseract.exe", "https://raw.githubusercontent.com/iseahound/Vis2/master/bin/tesseract/tesseract.exe")
FileLoader("HeistScanner\bin\tesseract\tessdata_best\eng.traineddata", "https://raw.githubusercontent.com/iseahound/Vis2/master/bin/tesseract/tessdata_best/eng.traineddata")
FileLoader("HeistScanner\bin\tesseract\tessdata_fast\eng.traineddata", "https://raw.githubusercontent.com/iseahound/Vis2/master/bin/tesseract/tessdata_fast/eng.traineddata")
FileLoader("HeistScanner\lib\Gdip_All.ahk", "https://raw.githubusercontent.com/iseahound/Vis2/master/lib/Gdip_All.ahk")
FileLoader("HeistScanner\lib\ImagePut.ahk", "https://raw.githubusercontent.com/iseahound/Vis2/master/lib/ImagePut.ahk")
FileLoader("HeistScanner\lib\JSON.ahk", "https://raw.githubusercontent.com/iseahound/Vis2/master/lib/JSON.ahk")
FileLoader("HeistScanner\lib\Vis2.ahk", "https://raw.githubusercontent.com/iseahound/Vis2/master/lib/Vis2.ahk")

FileLoader("HeistScanner\bin\tesseract\tessdata_fast\rus.traineddata", "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main/rus.traineddata")
FileLoader("HeistScanner\bin\tesseract\tessdata_best\rus.traineddata", "https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/rus.traineddata")

;FileLoader("HeistScanner\resources\ahk\ItemDataConverterLib.ahk", "https://raw.githubusercontent.com/MegaEzik/LeagueOverlay_ru/master/resources/ahk/ItemDataConverterLib.ahk")

FileLoader("HeistScanner\run_HeistScanner.ahk", "https://raw.githubusercontent.com/MegaEzik/PoE_HeistScanner_ru/main/HeistScanner/run_HeistScanner.ahk")

patchVis2()

Run *RunAs "%A_AhkPath%" "%A_ScriptDir%\HeistScanner\run_HeistScanner.ahk"

ExitApp

FileLoader(Path, URL){
	If FileExist(Path)
		Return
	SplitPath, Path,, DirPath
	FileCreateDir, %DirPath%
	RunWait, curl -L -o "%Path%" "%URL%",, hide
}

patchVis2(){
	If FileExist("HeistScanner\lib\Vis2Patched.ahk")
		return
	FileRead, Vis2Data, HeistScanner\lib\Vis2.ahk
	Pattern:=" || GetKeyState(""Alt"", ""P"") "
	Vis2Data:=RegExReplace(Vis2Data, "\Q" Pattern "\E", " ")
	FileAppend, %Vis2Data%, HeistScanner\lib\Vis2Patched.ahk, UTF-8
}

update(){
	FilePath:=A_Temp "\MegaEzik\HeistScannerLoader.ahk"
	
	FormatTime, CurrentDate, %A_Now%, yyyyMMdd
	FileGetTime, LoadDate, %FilePath%, M
	FormatTime, LoadDate, %LoadDate%, yyyyMMdd
	IfNotExist, %FilePath%
		LoadDate:=0
	If (LoadDate=CurrentDate)
		return
	
	FileDelete, %FilePath%
	Sleep 50
	FileLoader(FilePath, "https://raw.githubusercontent.com/MegaEzik/PoE_HeistScanner_ru/main/HeistScanner.ahk")
	FileReadLine, verRelease, %FilePath%, 1
	RegExMatch(verRelease, "HeistScannerLoader ver(.*)", newVer)
	FileReadLine, verScript, %A_ScriptFullPath%, 1
	RegExMatch(verScript, "HeistScannerLoader ver(.*)", curVer)
	If (newVer1="") || (newVer1<=curVer1)
		return
	FileRemoveDir, %A_ScriptDir%\HeistScanner, 1
	FileMove, %FilePath%, %A_ScriptFullPath%, 1
	Sleep 1000
	Reload
}
