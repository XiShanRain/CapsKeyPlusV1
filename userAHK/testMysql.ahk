; 定义一个热键（例如 Ctrl+Alt+T）
!t::
    ; 保存当前剪贴板内容
    originalClipboard := ClipboardAll
    
    ; 清空剪贴板并复制选中的文本
    Clipboard := ""
    Send, ^c  ; 模拟 Ctrl+C 复制选中的文本
    ClipWait, 1  ; 等待剪贴板内容更新，超时时间为 1 秒

    ; 判断是否成功复制到选中文本
    if (ErrorLevel) {
        ; 如果没有选中文本，发送 Ctrl+W
        Send, ^w
        Send, ^c
        selectedText := Clipboard
        MsgBox, 没有选中任何文本，已发送 Ctrl+W。
        MsgBox, 1当前选中的文本是: %selectedText%
    } else {
        ; 如果有选中文本，获取剪贴板内容并打印
        selectedText := Clipboard
        MsgBox, 2当前选中的文本是: %selectedText%
    }

    ; 恢复原始剪贴板内容
    Clipboard := originalClipboard
    return
 