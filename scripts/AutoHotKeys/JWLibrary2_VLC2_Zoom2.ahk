﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; ++++++++++++++++++++
;  USEFUL COMMON VARS
; ++++++++++++++++++++
VLC_MAIN_TITLE  := "Liste de lecture"
ZOOM_MAIN_TITLE := "Zoom Réunion"


; ========================
;       JW LIBRARY
; ========================

#+j::
#WinActivateForce
; -------------------------------
; Stage-side window of JW Library
; -------------------------------
WinGet, jwlib_list, List, JW Library

; We need to be careful because the full-screen secondary window may not register as a window (or not have a title)
if (jwlib_list == 1) {
	;
	; In this case, we must change strategy and play with the JW Library process itself
	;
	WinActivate, ahk_exe JWLibrary.exe
	; TODO: find a trick that would work here (as the ghost window disappears when something else is on top on stage)
	
} else {
	SysGet, mainMon, MonitorPrimary
	SysGet, totalMon, MonitorCount
	; Making sure the computer-side window is activated (normaly the other one than the primary)
	otherMon := (mainMon = totalMon) ? 1 : totalMon
	FUNC_ActivateWindowFromListOnGivenMonitor(otherMon, jwlib_list1, jwlib_list2)	
}
Exit


#+k::
#WinActivateForce
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
WinGet, zoom_stage, ID, Zoom,, %ZOOM_MAIN_TITLE%, Chrome Legacy Window
WinActivate, ahk_id %zoom_stage%
Exit


#+y::
#WinActivateForce
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
WinGet, vlc_id, ID, VLC
WinActivate, ahk_id %vlc_id%
Exit


#+v::
#WinActivateForce
; ---------------------------
; Computer-side window of VLC
; ---------------------------
WinGet, vlc_id, ID, %VLC_MAIN_TITLE%
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
	
	if (mon1 = MonitorTarget) {
		WinActivate, ahk_id %Window1%
		Return
	}
	
	if (mon2 = MonitorTarget) {
		WinActivate, ahk_id %Window2%
		Return
	}
	
	MsgBox, None of the 2 given windows are found on monitor (%MonitorTarget%)
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
