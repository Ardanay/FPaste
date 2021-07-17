;+Directives+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#NoEnv
#Persistent
SetBatchLines -1
SetKeyDelay,  -1
;-Directives-------------------------------------------------------------------------------------------------------------------

;+Global+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
global menu, autostartKey, isMenuEmpty
;-Global-----------------------------------------------------------------------------------------------------------------------

;+Init+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
autostartKey = HKCU\Software\Microsoft\Windows\CurrentVersion\Run
isMenuEmpty := True
;-Init-------------------------------------------------------------------------------------------------------------------------

;+Main+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SplitPath, a_ScriptFullPath,, path,, fileName
fpFile = %path%\%fileName%.txt

Menu, Tray, NoStandard
RegRead, themeMode, HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme
If(themeMode == 0)
	Menu, Tray, Icon, %A_ScriptFullPath%, 1
Else
	Menu, Tray, Icon, %A_ScriptFullPath%, 2
Menu, Tray, Tip, %fileName%
Menu, Tray, Add, % _L("Autostart"), AutostartToggle
If(IsAutostartEnable())
	Menu, Tray, Check,   % _L("Autostart")
Else
	Menu, Tray, Uncheck, % _L("Autostart")
Menu, Tray, Add
Open     := Func("Open").Bind(fpFile)
Reload   := Func("Load").Bind(fpFile)
GoToSite := Func("GoToSite")
Menu, Tray, Add, % _L("Open file"),   % Open
Menu, Tray, Add, % _L("Reload file"), % Reload
Menu, Tray, Add, % _L("Go to site"),  % GoToSite
Menu, Tray, Add
Menu, Tray, Add, % _L("Exit"),   ExitApp

If(FileExist(fpFile))
	Load(fpFile)
Else
{
	FileAppend, % _L("; Label | Value") . "`n", %fpFile%, UTF-8
	Open(fpFile)
}

Return
;-Main-------------------------------------------------------------------------------------------------------------------------

;+Hotkeys++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
<^LWin::
<#LCtrl::
	If(isMenuEmpty)
		Open(fpFile)
	Else
		Menu, thisMenu, Show
Return
;-Hotkeys----------------------------------------------------------------------------------------------------------------------

;+Functions++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MenuProc()
{
	Send, % menu[a_ThisMenuItemPos][2]
}

AutostartToggle()
{
	If(IsAutostartEnable())
	{
		RegDelete, %autostartKey%, FPaste
		Menu, Tray, Uncheck, % _L("Autostart")
	}
	Else
	{
		RegWrite, REG_SZ, %autostartKey%, FPaste, %a_ScriptFullPath%
		Menu, Tray, Check,   % _L("Autostart")
	}
}

IsAutostartEnable()
{
	RegRead, val, %autostartKey%, FPaste
	Return, StrLen(val) > 0 && val == a_ScriptFullPath
}

Open(fileName)
{
	Try
	{
		Run, open %fileName%
	}
	Catch, exception
	{
		Run, %a_WinDir%\notepad.exe %fileName%
	}
}

Load(fileName)
{
	FileRead, fileContent, *P65001 %fileName%
	If(MenuGetHandle("thisMenu"))
		Menu, thisMenu, DeleteAll
	menu := []
	idx  := 0
	For _, menu_item in StrSplit(fileContent, "`n")
	{
		If(SubStr(menu_item, 1, 1) != ";")
		{
			menuItem := StrSplit(menu_item, "|", a_Space . a_Tab . "`n`r")
			If(StrLen(menuItem[1]) > 0)
			{
				menu.Push(menuItem)
				Menu, thisMenu, Add, % menuItem[1], MenuProc
				idx++
			}
		}
	}
	isMenuEmpty := (idx == 0)? True : False
	fileContent =
}

GoToSite()
{
	Run, open https://github.com/Ardanay/FPaste
}

ExitApp:
ExitApp
;-Functions--------------------------------------------------------------------------------------------------------------------

;+Localization+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_L(string)
{
	static __L := Func("_" . _L_()).Call()
	Return, (StrLen(__L[string]) > 0)? __L[string] : string
}
_L_()
{
	Return, {
	( Join,
		0419: "ruRU"
	)}[a_Language]
}
_ruRU()
{
	Return, {
	( Join,
		"Autostart"       : "Автозапуск"
		"Open file"       : "Открыть файл"
		"Reload file"     : "Перечитать файл"
		"Go to site"      : "Перейти на сайт"
		"Exit"            : "Выход"
		"; Label | Value" : "; Метка | Содержимое"
	)}
}
;-Localization-----------------------------------------------------------------------------------------------------------------

;+Compiler Directives++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;@Ahk2Exe-AddResource .\res\white.ico, 1
;@Ahk2Exe-AddResource .\res\black.ico, 2
;-Compiler Directives----------------------------------------------------------------------------------------------------------
