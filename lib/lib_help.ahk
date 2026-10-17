; CapsKeyPlus 帮助窗口
showHelpGui(){
    global
    if(HelpGuiHwnd && WinExist("ahk_id " . HelpGuiHwnd)) {
        WinActivate, ahk_id %HelpGuiHwnd%
        return
    }
    Gui, HelpGui:New, +AlwaysOnTop +Resize +MinSize720x480, % lang_help_title
    Gui, HelpGui:+LabelHelpGui
    Gui, HelpGui:+HwndHelpGuiHwnd
    Gui, HelpGui:Font, s9, Microsoft YaHei UI
    Gui, HelpGui:Add, ListView, vHelpCat gHelpCat Grid r16 w160 h440 -Multi -Hdr NoSortHdr, % lang_help_cat
    Gui, HelpGui:Add, Edit, vHelpContent ReadOnly Multi WantTab -Wrap r16 w540 h440
    LV_Delete()
    LV_Add("", lang_help_cat_basic)
    LV_Add("", lang_help_cat_tabscript)
    LV_Add("", lang_help_cat_winbind)
    LV_Add("", lang_help_cat_qbar)
    LV_Modify(1, "Select Focus")
    helpGuiShowContent(1)
    Gui, HelpGui:Show, Center, % lang_help_title
    return
}

helpGuiShowContent(idx){
    global
    if(idx=1)
        content := lang_help_basic
    else if(idx=2)
        content := lang_help_tabscript
    else if(idx=3)
        content := lang_help_winbind
    else
        content := lang_help_qbar
    GuiControl, , HelpContent, % content
    return
}

HelpGuiClose:
HelpGuiEscape:
Gui, HelpGui:Destroy
return

HelpGuiSize:
Gui, HelpGui:Default
GuiControl, Move, HelpCat, h%A_GuiHeight%
GuiControl, Move, HelpContent, w%A_GuiWidth% h%A_GuiHeight%
return

HelpCat:
if(A_GuiEvent = "Normal")
{
    rowNum := LV_GetNext()
    if(rowNum)
        helpGuiShowContent(rowNum)
}
return
