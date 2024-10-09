/*HeistScannerLoader ver230925.2
[info]
version=241010
*/
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

If (!A_IsAdmin) {
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
	ExitApp
}

SplashTextOn, 200, 20, HeistScannerLoader, Please wait...

update()

If !FileExist("HeistScanner.ini") {
	IniWrite, F2, HeistScanner.ini, hotkeys, hotkeyHeistScanner
	IniWrite, Standard, HeistScanner.ini, settings, league
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

FileLoader("HeistScanner\HeistScannerMainScript.ahk", "https://raw.githubusercontent.com/MegaEzik/PoE_HeistScanner_ru/main/HeistScanner/HeistScannerMainScript.ahk")

patchVis2()

Run *RunAs "%A_AhkPath%" "%A_ScriptDir%\HeistScanner\HeistScannerMainScript.ahk" /launch

ExitApp

FileLoader(Path, URL){
	If FileExist(Path)
		Return
	SplitPath, Path,, DirPath
	FileCreateDir, %DirPath%
	UrlDownloadToFile, %URL%, %Path%
	;RunWait, curl -L -o "%Path%" "%URL%",, hide
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
	FilePath:=A_ScriptDir "\HeistScanner\tmp\tmpLoader.ahk"
	
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
	
	IniRead, vScript, %A_ScriptFullPath%, info, version, 230313
	IniRead, vRelease, %FilePath%, info, version, 230313
	If (vScript>=vRelease)
		return
	
	RunWait *RunAs "%A_AhkPath%" "%A_ScriptDir%\HeistScanner\HeistScannerMainScript.ahk"
	Sleep 500
	FileMove, %FilePath%, %A_ScriptFullPath%, 1
	Sleep 100
	FileRemoveDir, %A_ScriptDir%\HeistScanner, 1
	Sleep 500
	Reload
}
