;____________________________
; \____Nice But Dim!!_____/ 

; Coded by SlimlinE.

; Last Edit:- 25/05/060

; Dimmes the screen, (nicely!).


SetTimer, TimeIdleCheck, 1000
SplitPath, A_ScriptFullPath, SYS_ScriptNameExt, SYS_ScriptDir, SYS_ScriptExt, SYS_ScriptNameNoExt, SYS_ScriptDrive
Gosub, CFG_LoadSettings
Gosub, CFG_ApplySettings

Menu, TRAY, NoStandard
Menu, TRAY, Tip, Nice But Dim!
Menu, Options, Add, &LMB Or Space, TRY_TrayEvent
Menu, Options, Add, &Tray Tip Countdown, TRY_TrayEvent
Menu, Options, Add
Menu, Options, Add, &Other Options, TRY_TrayEvent
Menu, Tray, Add, &Options, :Options
Menu, Tray, Add
Menu, Tray, Add, &Turn Monitor Off, TRY_TrayEvent
Menu, Tray, Add
Menu, Tray, Add, &Nice But Dim!, TRY_TrayEvent
Menu, Tray, Add, &Dim NOW!, TRY_TrayEvent
Menu, Tray, Add
Menu, Tray, Add, E&xit!, TRY_TrayEvent
Gosub, TRY_TrayUpdate
Return


; **CHANGE SETTINGS HERE.************

; FYI: 60000 = 1 minute. 120000 = 2 minutes. 300000 = 5 minutes. etc
Settings:                     
    IdleInterval = 30000     ; Dim the screen after xxx period of inactivity. (Set at 5 seconds for testing)   
    TrayTipCount = 5          ; Traytip counts down from this number.
    TransStart := 0           ; Starting transparency. 0 = none.
    TransStartSpeed = 1       ; How fast (or slow) to dim.
    TransEnd := 125           ; How much to dim.
    TransEndSpeed = 3         ; How fast (or slow) to restore screen.
    CustomColor = 000000      ; Set colour.
Return

; ***********************************


TRY_TrayUpdate:
    If ( NiceButDim )
      Menu, Tray, Check, &Nice But Dim!
    Else
      Menu, Tray, UnCheck, &Nice But Dim!
    If ( LMBSpace )
        Menu, Options, Check, &LMB Or Space
    Else
        Menu, Options, UnCheck, &LMB Or Space
    If ( TTipToggle )
        Menu, Options, Check, &Tray Tip Countdown
    Else
        Menu, Options, UnCheck, &Tray Tip Countdown
Return


TRY_TrayEvent:
   If ( !TRY_TrayEvent )
      TRY_TrayEvent = %A_ThisMenuItem%      
    If ( TRY_TrayEvent = "&Nice But Dim!" )
   {
        NiceButDim := !NiceButDim
        Gosub, CFG_ApplySettings
    }
    If ( TRY_TrayEvent = "&LMB Or Space" )
    {
        LMBSpace := !LMBSpace
        Gosub, CFG_ApplySettings
    }
    If ( TRY_TrayEvent = "&Tray Tip Countdown" )
    {
        TTipToggle := !TTipToggle
    }
    If ( TRY_TrayEvent = "&Other Options" )
    {
        Run, %Windir%\notepad.exe %A_ScriptFullPath%
    }
    If ( TRY_TrayEvent = "&Turn Monitor Off" )
    {
        SendMessage, 0x112, 0xF170, 2,, Program Manager
    }
    If ( TRY_TrayEvent = "&Dim NOW!" )
    {           
        Gosub, Settings
        Gosub, DimScreen           
    }
    If ( TRY_TrayEvent = "E&xit!" )
    {
        Gosub, CFG_SaveSettings
        ExitApp
    }
   Gosub, TRY_TrayUpdate
   TRY_TrayEvent =
Return


CFG_LoadSettings:
    IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
	IniRead, NiceButDim, %IniFile%, Visual, NiceButDim, 1
	IniRead, LMBSpace, %IniFile%, Visual, LMBSpace, 0
    IniRead, TTipToggle, %IniFile%, Visual, TTipToggle, 1
Return

CFG_SaveSettings:
    IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
    IfNotExist, %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
        {
            FileAppend, , %SYS_ScriptNameNoExt%.ini
        } 
   IniWrite, %NiceButDim%, %IniFile%, Visual, NiceButDim
   IniWrite, %LMBSpace%, %IniFile%, Visual, LMBSpace
    IniWrite, %TTipToggle%, %IniFile%, Visual, TTipToggle
Return

CFG_ApplySettings:
    If ( NiceButDim )
       SetTimer,TimeIdleCheck,1000
	Else
       SetTimer, TimeIdleCheck, Off
	If ( LMBSpace )
       WakeUp = LMBSpace
	Else
       WakeUp = AnyKeyMouse   
    If ( TTipToggle )
        TTipToggle = 1
    Else
        TTipToggle = 0       
Return


TimeIdleCheck:
    ; Hot-corner to keep screen on. *Credit to evl.*
    Coordmode, Mouse, Screen
    MouseGetPos, xMouseOrig, yMouseOrig
    If ((xMouseOrig <= 10) and (yMouseOrig <= 10))   
        Gosub, PauseChecking

    Gosub, Settings   
    If A_TimeIdlePhysical > %IdleInterval%              ; Check for keyboard or mouse activity.
    {
        If ( TTipToggle )                               ; Check if TrayTip is on or off.
            Gosub, TrayCountdown                        ; If on, start xx sec traytip countdown.
        Else
            Gosub, DimScreen                            ; Else off, dim now.
    }
Return


TrayCountdown:       
    Loop
    {
        If TrayTipCount < 0                             ; "<" Makes sure countdown finishes at 0 not 1.
        {
            TrayTip
            Break
        }
        Loop, 10
        {
            Sleep,100
            If A_TimeIdlePhysical < 100                 ; If countdown is interupted,
            {               
                TrayTip                                 ; remove traytip,               
                Return                                  ; and go back to the beginning.
            }               
        }
        ; Show traytip.
        TrayTip, Nice But Dim!, Screen will be dimmed in %TrayTipCount% seconds. `nMove the mouse or press any key to cancel.,,1
        TrayTipCount -=1
    }
    Gosub, DimScreen
Return


DimScreen:
    ; Setup transparent GUI.
    Gui, +AlwaysOnTop +LastFound +Owner                 ; +Owner stops taskbar button appearing.
    Gui, Color, %CustomColor%
    WinSet, TransColor, %CustomColor% %transparent%
    Gui, -Caption                                       ; Remove the title bar and window borders.
    Gui, Show, x0 y0 h%A_ScreenWidth% w%A_ScreenWidth% 
    ; Gui, Add, pic,x0 y0, I:\Work\Crass\Crass03.jpg    ; Want to add a picture?

    ; Start Gui fade out.
    Loop
    {
        WinSet, Transparent, %TransStart%, ahk_class AutoHotkeyGUI
        ;Sleep,200                                      ; Reduces Cpu usage when dimming slowly.
        TransStart += %TransStartSpeed%                 ; Speed of fadeout.
        If A_TimeIdlePhysical < 10                      ; If any activity during fade out...
        {
            Gui, Destroy                                ; ... remove partially dimmed Gui.
            Return
        }
        If TransStart > %TransEnd%
            Break
    }     
    Run, nomousy.exe /hide /freeze                      ; Hide cursor and restrict movement.
    Gosub, %WakeUp%                                     ; Wait for keyboard or mouse activity.

    ; Start GUI fade in.
    Loop, %TransEnd%
    {     
        WinSet, Transparent, %TransEnd%, ahk_class AutoHotkeyGUI
        TransEnd -= %TransEndSpeed%
        If TransEnd < 0
            Break
    }
    Gui, Destroy                                        ; Remove dimmed Gui.
Return


LMBSpace:                                               ; Cancels dimmed screen using the
    Loop                                                ; SPACE BAR or LEFT MOUSE BUTTON.
    {
        Sleep,100
        GetKeyState, LMB, LButton, P
        If LMB = D
            Break       
        GetKeyState, BAR, Space, P
        If BAR = D
            Break     
    }
    Run, nomousy.exe                                    ; Restore cursor.
Return


AnyKeyMouse:                                            ; Cancels dimmed screen using
    Loop                                                ; ANY KEY or ANY MOUSE MOVEMENT.
    {
        Sleep,100                                       ; Reduces Cpu usage while waiting.
        if A_TimeIdlePhysical < 100
            Break
    }
    Run, nomousy.exe                                    ; Restore cursor.
Return


PauseChecking:
    Coordmode, ToolTip
    SetTimer, TimeIdleCheck, off           
    ToolTip, Nice But Dim! :- PAUSED, 19, 2
    SetTimer, RemoveToolTip, 2000
    Gosub, Wait4Movement   
Return


Wait4Movement:
    Loop
    {
        Sleep, 100                                      ; Reduces Cpu usage while waiting.
        MouseGetPos, xMouseOrig, yMouseOrig
        If ((xMouseOrig >= 10) and (yMouseOrig >= 10))
            Break       
    }
    ToolTip, Nice But Dim! :- RESUMED, 19, 2
    SetTimer, RemoveToolTip, 2000
    SetTimer, TimeIdleCheck, 1000
Return


RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
Return


; LButton and CapsLock to lock and unlock the screen.
~LButton & CapsLock::
    Gui, +AlwaysOnTop +LastFound +Owner                 ; Create transparent Gui...
    Gui, Color, ffffff
    WinSet, Transparent,10
    Gui, -Caption
    Gui, Show, x0 y0 h%A_ScreenWidth% w%A_ScreenWidth%  ; that covers entire screen.
    Run, nomousy.exe /hide /freeze                      ; Hide the cursor.
    Sleep,1000                                          ; Gives time to release key before unlocking.
    Loop                                                ; Wait for LEFT MOUSE BUTTON and CAPSLOCK.
    {
        Sleep,10
        GetKeyState, LMB, LButton, P
        if LMB = D
        {
            GetKeyState, CAPS, CapsLock, P
            if CAPS = D
            Break
        }
    }
    Gui, Destroy                                        ; Show screen.
    Run, nomousy.exe                                    ; Show cursor.
Return

;_________________________
; \____End Of Code____/ 