#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; ++++++++++++++++++++
;  USEFUL COMMON VARS
; ++++++++++++++++++++
VLC_MAIN_TITLE  := "Lecteur multimédia VLC"
ZOOM_MAIN_TITLE := "Zoom Réunion"


; ========================
;       JW LIBRARY
; ========================

#j::
; -------------------------------
; Stage-side window of JW Library
; -------------------------------
WinGet, jwlib_list, List, JW Library

; We need to be careful because the full-screen secondary window may not register as a window (or not have a title)
if (jwlib_list == 1) {
	;
	; In this case, we must change strategy and play with the JW Library process itself
	;
	#WinActivateForce
	WinActivate, ahk_exe JWLibrary.exe
	; TODO: find a trick that would work here (as the ghost window disappears when something else is on top on stage)
	
} else {
	;
	; Apparently the stage window has an ID that is bigger than the main window (but the other way around in single screen...)
	;
	if (jwlib_list1 > jwlib_list2) {
		WinActivate, ahk_id %jwlib_list1%
	} else {
		WinActivate, ahk_id %jwlib_list2%
	}
}
Exit


#k::
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
	;
	; Apparently the laptop window has an ID that is smaller  (but the other way around in single screen...)
	;
	if (jwlib_list1 < jwlib_list2) {
		WinActivate, ahk_id %jwlib_list1%
	} else {
		WinActivate, ahk_id %jwlib_list2%
	}
}
Exit


; ========================
;           ZOOM
; ========================

#z::
; -------------------------
; Stage-side window of Zoom
; -------------------------
; Tool be safe, we are looking for the second window "Zoom" while making sure the main window (Zoom Meeting) is not running interference
WinGet, zoom_stage, ID, Zoom,, %ZOOM_MAIN_TITLE%
WinActivate, ahk_id %zoom_stage%
Exit


#y::
; ----------------------------
; Computer-side window of Zoom
; ----------------------------
WinGet, zoom_id, ID, %ZOOM_MAIN_TITLE%
WinActivate, ahk_id %zoom_id%
Exit


; ======================
;           VLC
; ======================

#v::
; ---------------------------
; Computer-side window of VLC
; ---------------------------
WinGet, vlc_id, ID, %VLC_MAIN_TITLE%
WinActivate, ahk_id %vlc_id%
Exit
