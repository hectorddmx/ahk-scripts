ToggleWinMinimize(TheWindowTitle)
{
  SetTitleMatchMode,2
  DetectHiddenWindows, Off
  IfWinActive, %TheWindowTitle%
  {
    WinMinimize, %TheWindowTitle%
  }
  Else
  {
    IfWinExist, %TheWindowTitle%
    {
      WinGet, winid, ID, %TheWindowTitle%
      DllCall("SwitchToThisWindow", "UInt", winid, "UInt", 1)
    }
  }
  Return
}

#q::ToggleWinMinimize("Wunderlist")
#w::ToggleWinMinimize("Sublime")
#a::ToggleWinMinimize("localhost")
#s::ToggleWinMinimize("C:")

;#a lo usa resophnotes
;#z lo usa everything
;#e lo usa explorer para abrir my computer
;#d lo usa explorer para minimizar el escritorio
;#r lo usa explorer para Run..
;#f lo usa explorer para buscar archivos

;#w::Send ^!t