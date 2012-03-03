;Ghoster - A Multi-Monitor Variation
; Shows a transparent image across the desktop, dims inactive windows
; Skrommel @2005
; Brad McIntosh (BigMac) 2008-03-30  - Mods for multi-monitor shading
;    Image and other options not tested.  Just tried to get the multi-monitor
;    shading to work.

#NoEnv
#SingleInstance,Force
SetBatchLines,-1
SetWindelay,0
OnExit,QUIT

START:
Gosub,READINI
Gosub,TRAYMENU
CoordMode,Mouse,Screen
WinGet,progmanid,Id,ahk_class Progman
WinGet,oldid,ID,A
WinGet,oldtop,ExStyle,ahk_id %oldid%
oldtop:=oldtop & 0x8

params=

; Get the virtual screen limits over the
; *possible* multiple monitors...  (BigMac)
;    "Borrowed" from source for "Dropcloth.AHK"
;      by Adam Pash <adam@lifehacker.com>
SysGet,monitorcount,MonitorCount
l=0
t=0
r=0
b=0
Loop,%monitorcount%
{
SysGet,monitor,MonitorWorkArea,%A_Index%
If (monitorLeft<l)
l:=monitorLeft
If (monitorTop<t)
t:=monitorTop
If (monitorRight>r)
r:=monitorRight
If (monitorBottom>b)
b:=monitorBottom
}
resolutionRight:=r+Abs(l)
resolutionBottom:=b+Abs(t)

; Shove the width and height into the old variables
; for some of the older routines.  (BigMac)
;  (temporary)
desktopw:=resolutionRight
desktoph:=resolutionBottom

If stretchwidth=1
{
  width=%desktopw%
  x:=l
}
If stretchheight=1
{
  height=%desktoph%
  y:=t
}
If keepaspect=1
  If width<>
    height=-1
  Else
    width=-1
If x<>
  params=%params% X%x%
If y<>
  params=%params% Y%y%
If width<>
  params=%params% W%width%
If height<>
  params=%params% H%height%
 
Gui,+ToolWindow -Disabled -SysMenu -Caption +E0x20 ;+AlwaysOnTop
Gui,Margin,0,0
If backcolor<>
  Gui,Color,%backcolor%
If image<>
  Gui,Add,Picture,%params%,%image%
; use the new virtual screen limits and width/height...  (BigMac)
Gui,Show,X%l% Y%t% W%resolutionRight% H%resolutionBottom%,GhosterWindow
Gui,+LastFound
guiid:=WinExist("A")
WinSet,Transparent,%transparency%,GhosterWindow

LOOP:
Sleep,50
WinGet,winid,ID,A
If winid<>%oldid%
{
  WinGet,wintop,ExStyle,ahk_id %winid%
  wintop:=wintop & 0x8

  If showdesktop
    If winid=%progmanid%
      ; use the new virtual screen limits...  (BigMac)
      WinMove,%r%,%b%,,,GhosterWindow
    Else
      If oldid=%progmanid%
        ; use the new virtual screen limits...  (BigMac)
        WinMove,%l%,%t%,,,GhosterWindow

  If jump
  If !wintop
    WinSet,AlwaysOnTop,On,ahk_id %winid%

  If showontop
    WinSet,Top,,GhosterWindow
  Else
  {
    SWP_NOMOVE=2
    SWP_NOSIZE=1
    SWP_NOACTIVATE=0x10
    DllCall("SetWindowPos",Uint,guiid
      ,Uint,winid,Int,0,Int,0,Int,0,Int,0
      ,Uint,SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE)
;    DllCall("SetWindowPos",Uint,WinExist("ahk_class Shell_TrayWnd")
;      ,Uint,guiid,Int,0,Int,0,Int,0,Int,0
;      ,Uint,SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE)
  }

  If !oldtop
    WinSet,AlwaysOnTop,Off,ahk_id %oldid%
;  Else
;    WinSet,AlwaysOnTop,Off,ahk_id %oldid%

  oldid=%winid%
  oldtop=%wintop%
}

Goto,LOOP


ABOUT:
Gosub,DESTROY
about=Ghoster shows a transparent image across the screen and dims inactive windows.
about=%about%`n
about=%about%`nChange the image and other settings by editing the Ghoster.ini-file.
about=%about%`n
about=%about%`nSkrommel @2005    http://www.donationcoders.com/skrommel
MsgBox,0,Ghoster,%about%
about=
Goto,START
Return


READINI:
IfNotExist,Ghoster.ini
{
ini=;Ghoster.ini
ini=%ini%`n`;backcolor=000000-FFFFFF or leave blank to speed up screen redraw.
ini=%ini%`n`;image=                     Path to image or leave blank to speed up screen redraw.
ini=%ini%`n`;x=any number or blank      Moves the image to the right.
ini=%ini%`n`;y=any number or blank      Moves the image down.
ini=%ini%`n`;width=any number or blank  Makes the image wider.
ini=%ini%`n`;height=any number or blank Makes the image taller.
ini=%ini%`n`;stretchwidth=1 or 0        Makes the image fill the width of the screen.
ini=%ini%`n`;stretchheight=1 or 0       Makes the image fill the height of the screen.
ini=%ini%`n`;keepaspect=1               Keeps the image from distorting.
ini=%ini%`n`;transparency=0-255         Makes the ghosting more or less translucent.
ini=%ini%`n`;jump=1 or 0                Makes the active window show through the ghosting.
ini=%ini%`n`;showdesktop=1 or 0         Removes the ghosting when the desktop is active.
ini=%ini%`n`;showontop=1 or 0           Removes ghosting from ontop windows like the taskbar.
/*
No longer needed.
ini=%ini%`n`;multimon=1 or 0            Dim all monitors in a multimonitor system
*/
ini=%ini%`n
ini=%ini%`n[Settings]
ini=%ini%`nbackcolor=000000
ini=%ini%`nimage=C:\Windows\Bubbles.bmp
ini=%ini%`nx=
ini=%ini%`ny=
ini=%ini%`nwidth=
ini=%ini%`nheight=
ini=%ini%`nstretchwidth=1
ini=%ini%`nstretchheight=1
ini=%ini%`nkeepaspect=1
ini=%ini%`ntransparency=150
ini=%ini%`njump=1
ini=%ini%`nshowdesktop=1
ini=%ini%`nshowontop=0
/*
No longer needed.
ini=%ini%`nmultimon=1
*/
ini=%ini%`n
FileAppend,%ini%,Ghoster.ini
ini=
}
IniRead,backcolor,Ghoster.ini,Settings,backcolor
IniRead,image,Ghoster.ini,Settings,image
IniRead,x,Ghoster.ini,Settings,x
IniRead,y,Ghoster.ini,Settings,y

IniRead,width,Ghoster.ini,Settings,width
IniRead,height,Ghoster.ini,Settings,height
IniRead,stretchwidth,Ghoster.ini,Settings,stretchwidth
IniRead,stretchheight,Ghoster.ini,Settings,stretchheight
IniRead,keepaspect,Ghoster.ini,Settings,keepaspect
IniRead,transparency,Ghoster.ini,Settings,transparency
IniRead,jump,Ghoster.ini,Settings,jump
IniRead,showdesktop,Ghoster.ini,Settings,showdesktop
IniRead,showontop,Ghoster.ini,Settings,showontop
IniRead,multimon,Ghoster.ini,Settings,multimon
Return


TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
Menu,Tray,Add,Ghoster,ABOUT
Menu,Tray,Add,
Menu,Tray,Add,&Settings,SETTINGS
Menu,Tray,Add,&About,ABOUT
Menu,Tray,Add,&Restart,RESTART
Menu,Tray,Add,E&xit,QUIT
Menu,Tray,Default,Ghoster
Return


SETTINGS:
Run,Ghoster.ini
Return


RESTART:
Gosub,DESTROY
Goto,START


DESTROY:
If oldtop
  WinSet,AlwaysOnTop,On,ahk_id %oldid%
Else
  WinSet,AlwaysOnTop,Off,ahk_id %oldid%
Gui,Destroy
Return


QUIT:
WinActivate,ahk_class Shell_TrayWnd
WinWaitActive,ahk_class Shell_TrayWnd,,1
Gosub,DESTROY
WinActivate,ahk_id %oldid%
ExitApp 