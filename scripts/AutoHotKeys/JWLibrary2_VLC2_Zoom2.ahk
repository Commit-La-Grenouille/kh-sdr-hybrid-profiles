#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; ++++++++++++++++++++
;  USEFUL COMMON VARS
; ++++++++++++++++++++
VLC_LIST_TITLE  := "Liste de lecture"
VLC_MAIN_TITLE  := "Lecteur multimédia VLC"
ZOOM_MAIN_TITLE := "Zoom Réunion"
ZOOM_STAGE_TITLE:= "Zoom Workplace"

JW_APP := "JWLibrary.exe"
JW_LNK := A_Desktop . "\JW Library.lnk"
ZM_APP := "Zoom.exe"
ZM_PTH := A_AppData . "\Zoom\bin\" . ZM_APP

JW_STAGE_LOG := "JWLib_stage_window.log"

; ========================
;       JW LIBRARY
; ========================

#+j::
#WinActivateForce
DetectHiddenText, On
DetectHiddenWindows, On
; -------------------------------
; Stage-side window of JW Library
; -------------------------------
WinGet, jwlib_list, List, JW Library

; We need to be careful because the full-screen secondary window may not register as a window (or not have a title)
if (jwlib_list == 1) {
	;
	; In this case, we must change strategy and play with the JW Library process itself
	;
	; NOTE: This reminder can be a liability if the window is not clicked and goes to the background,
	;       meaning that the whole automation can be stuck. Enable it ONLY when necessary !
	;MsgBox, 
;(
;FR: Tu n'as pas changé la fenêtre secondaire de JW Library en fenêtre agrandie (au lieu de plein écran).
;
;EN: You forgot to change the second JW Library window from fullscreen to maximized.
;)
	; TODO: find a trick that would work here (as the ghost window disappears when something else is on top on stage)

	; We are logging what happens here to make sure the last press failed b/c of the non-detection of the window
	FileAppend, "Unable to detect the JW stage window: " + jwlib_list, JW_STAGE_LOG

} else {
	SysGet, mainMon, MonitorPrimary
	SysGet, totalMon, MonitorCount
	; Making sure the computer-side window is activated (normaly the other one than the primary)
	otherMon := (mainMon = totalMon) ? 1 : totalMon
	FUNC_ActivateWindowFromListOnGivenMonitor(otherMon, jwlib_list1, jwlib_list2)

	; We are logging here too in case the activation method were to fail
	FileAppend, "JW stage window activated on monitor (" + otherMon + "): " + jwlib_list, JW_STAGE_LOG
}
Exit


#+k::
#WinActivateForce

; Checking first if the application is running
Process, Exist, %JW_APP%
if ! ErrorLevel {
	Run, %JW_LNK%
}

; ----------------------------------
; Computer-side window of JW Library
; ----------------------------------

WinGet, jwlib_list, List, JW Library

; If we get only 1 result, that can only be the main window (either because the secondary screen option is disabled or it is not detected)
if (jwlib_list == 1) {
	;
	; When there is only one, the decision is very simple
	;
	WinActivate, ahk_id %jwlib_list1%

} else {
	; Making sure the computer-side window is activated (as it should be the primary monitor no matter the number)
	SysGet, mainMon, MonitorPrimary
	FUNC_ActivateWindowFromListOnGivenMonitor(mainMon, jwlib_list1, jwlib_list2)
}
Exit


; ========================
;           ZOOM
; ========================

#+z::
#WinActivateForce
; -------------------------
; Stage-side window of Zoom
; -------------------------
; Tool be safe, we are looking for the second window "Zoom" while making sure the main window (Zoom Meeting) is not running interference
WinGet, zoom_stage, ID, %ZOOM_STAGE_TITLE%
WinActivate, ahk_id %zoom_stage%
Exit


#+y::
#WinActivateForce

; Checking first if the application is running
Process, Exist, %ZM_APP%
if ! ErrorLevel {
	Run, %ZM_PTH%
}

; ----------------------------
; Computer-side window of Zoom
; ----------------------------
WinGet, zoom_id, ID, %ZOOM_MAIN_TITLE%
WinActivate, ahk_id %zoom_id%
Exit


; ======================
;           VLC
; ======================

#+w::
#WinActivateForce
; ------------------------
; Stage-side window of VLC
; ------------------------
SetTitleMatchMode, 2
WinGet, vlc_id, ID, %VLC_MAIN_TITLE%
WinActivate, ahk_id %vlc_id%
Exit


#+v::
#WinActivateForce
; ---------------------------
; Computer-side window of VLC
; ---------------------------
WinGet, vlc_id, ID, %VLC_LIST_TITLE%
WinActivate, ahk_id %vlc_id%
Exit


; ...........................................................
; FUNCTION: activating the window found on a specific monitor
; ...........................................................
FUNC_ActivateWindowFromListOnGivenMonitor(MonitorTarget, Window1, Window2) {
	;
	; Crude implementation but cannot bother with the weird iteration through loop
	;    & parameters conventions in Batch/AHK script...
	;
	mon1 := FUNC_GetMonitorNumberForWindow(Window1)
	mon2 := FUNC_GetMonitorNumberForWindow(Window2)
	;MsgBox, Window (%Window1%) is on monitor (%mon1%) and (%Window2%) on (%mon2%)

	; When using an App with 2 regular windows, they should register on each monitor as long as they are displayed
	if (mon1 = MonitorTarget) {
		WinActivate, ahk_id %Window1%
		Return
	}

	if (mon2 = MonitorTarget) {
		WinActivate, ahk_id %Window2%
		Return
	}
}


; ................................................................
; FUNCTION: getting the monitor number related to the given window
; ................................................................
FUNC_GetMonitorNumberForWindow(WindowID) {
	;
	; Source: Forivin on stackoverflow (question 34338637)
	;
	; First, getting the monitor object where the given window is
	MonitorObject := DllCall("User32.dll\MonitorFromWindow", "Ptr", WindowID, "UInt", 0, "UPtr")

	; Then, extract from the monitor properties, the monitor number
	;  (might be simplified using SysGet, Var, Monitor*)
	NumPut(VarSetCapacity(MIEX, 40 + (32 << !!A_IsUnicode)), MIEX, 0, "UInt")
	If DllCall("User32.dll\GetMonitorInfo", "Ptr", MonitorObject, "Ptr", &MIEX) {
		MonitorName := StrGet(&MIEX + 40, 32)  ; CCHDEVICENAME = 32
		MonitorNumber := RegExReplace(MonitorName, ".*(\d+)$", "$1")
		Return %MonitorNumber%
	}
	Return False
}
