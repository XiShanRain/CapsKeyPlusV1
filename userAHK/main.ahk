; 1. Include the .ahk file(s) containing custom key functions here,
;   or just put the functions here.
;   * A key function must start with "keyFunc_" (case insensitive)

; 2. Add a setting under the [Keys] section in `CapsKeyPlusSettings.ini`

; Example:
; 1. There is a key function `keyFunc_example2` in demo.ahk.
; 2. Add below setting under the [Keys] section in `CapsKeyPlusSettings.ini`:
;   caps_f7=keyFunc_example2
; 3. Save, reload CapsKeyPlus (CapsLock+F5)
; 4. Press `CapsLock+F7` to invoke the function

#include demo.ahk
#Include mftcc_data.ahk
#Include PixPin.ahk

keyFunc_example1(){
  msgbox, example1
}

keyFunc_WeXin(){
  WeChat:="ahk_class WeChatMainWndForPC"
WeChat_path:="C:\Program Files\Tencent\WeChat\WeChat.exe"
 
if keyFunc_ProcessExist("WeChat.exe")=0
	Run, %WeChat_path%
else
{
	WinGet,wxhwnd,ID,%WeChat%
	if strlen(wxhwnd)=0
	{
		winshow,%WeChat%
		winactivate,%WeChat%
	}
	else
	{
		winhide,%WeChat%
	}
}
return
}


global array2 := {}  ; 全局数组
keyFunc_replaceSelectTableName() {
	global array2
	array2 := GetDataArray() ;获取数据库与表对应关系
	; MsgBox, % array2["after_fiveclass"]
	bakClip := Clipboard
	send, ^c
	s := Clipboard
	Clipboard := RegExReplace(s, "\s" ,"")
	;msgbox,% array2[Clipboard]
	Clipboard := array2[Clipboard]
	;msgbox,% Clipboard
	Sleep, 100
	send,^v
	Clipboard := bakClip
}

keyFunc_space(){
	click
}


keyFunc_pixpin(){
	pixPin_capture1()
}