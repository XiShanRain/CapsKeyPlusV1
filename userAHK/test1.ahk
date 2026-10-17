; 定义一个热键（例如 Ctrl+Alt+T）
; Run("D:\PortableApp\AutoRun\PixPin\PixPin.exe -r pixpin.screenShot(ShotAction.Copy)")
keyFunc_replaceSelectTableName() {
	bakClip := Clipboard
	send, ^c
	s := Clipboard
	
	;msgbox,% s
	Clipboard := s . "abcde"
	;msgbox,% Clipboard
	send,^v
	Clipboard := bakClip
}
#x::
keyFunc_replaceSelectTableName()
return
 