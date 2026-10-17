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
 


keyFunc_replaceSelectString() {
	global array2 := {}  ; 初始化全局数组
	; MsgBox,  %A_ScriptDir%\data.txt
    ;读取 data.txt 文件内容
    FileRead, fileContent, %A_ScriptDir%\data.txt
    if (ErrorLevel) {
        MsgBox, 无法读取 data.txt 文件！
        return
    } 
    Loop, Parse, fileContent, `n, `r
        {
            if (A_LoopField = "")
                continue
            StringSplit, keyValue, A_LoopField, =
            if (keyValue0 >= 2) {
                key := Trim(keyValue1)
                value := Trim(keyValue2)
                array2[key] := value
            }
        }
        str := "sys_menu_auth"
        MsgBox, % array2["sys_menu_auth"]
    ; bakClip := Clipboard
    ; send, ^c
	; s := Clipboard
    ; Clipboard := RegExReplace(s, "\s" ,"")
	; ;msgbox,% array2[Clipboard]
	; Clipboard := array2[Clipboard]
	; send,^v
	; Clipboard := bakClip
}

keyFunc_replaceSelectString()
keyFunc_space(){
	; click
	keyFunc_replaceSelectString()
}