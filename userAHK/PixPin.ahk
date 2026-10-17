; #SingleInstance Force

pixPin_capture1(){
    ; 该语句在cmd中可以正常执行, D:\PortableApp\AutoRun\PixPin\PixPin.exe -r pixpin.screenShot(ShotAction.Copy)
    ; 改为在ahk中执行
    Run "D:/PortableApp/AutoRun/PixPin/PixPin.exe"  -r pixpin.screenShotAndEdit()
}