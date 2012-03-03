$^s::                                       ; only capture actual keystrokes
SetTitleMatchMode, 2                        ; match anywhere in the title
IfWinActive, Sublime Text 2                 ; find Sublime Text
{
	Send ^s                                 ; send save command
	IfWinExist, Mozilla Firefox             ; find firefox
	{
		WinActivate                         ; use the window found above
		Send ^r                             ; send browser refresh
		WinActivate, Sublime Text 2         ; get back to Sublime Text
	}
	IfWinExist, Google Chrome               ; find Chrome
	{
		WinActivate                         ; use the window found above
		Send ^r                             ; send browser refresh
		WinActivate, Sublime Text 2         ; get back to Sublime Text
	}
	IfWinExist, Internet Explorer            ; find IE
	{
		WinActivate                         ; use the window found above
		Send ^r                             ; send browser refresh
		WinActivate, Sublime Text 2         ; get back to Sublime Text
	}
}
else
{
	Send ^s                                 ; send save command
}
return