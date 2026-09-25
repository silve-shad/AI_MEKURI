; Auto Mekuri & capture script
AutoItSetOption("MustDeclareVars", 1)

; ESC to Exit Program
HotKeySet("{ESC}", "Abort")
; SPC to Display Position
HotKeySet("{SPACE}", "Display")

global $FLG = False
Global $XY[1]

;===========================================================
; main Function
;===========================================================
main()

func main()
   while True
	  Sleep( 50 )
   Wend
endfunc

;=====================================================

;Å@èIóπ
Func Abort()
	  ; End of Program
	  MsgBOX( 0, "Exit", "<Program End>" )
	  Exit
EndFunc

Func Display()
   local $COLOR

   if ( $FLG = True   ) Then
	  $COLOR = PixelGetColor ( $XY[0], $XY[1]  )

	  MsgBOX( 0, "position", "XÅ°"& $XY[0]&  @CRLF & "YÅ°"  & $XY[1]  & @CRLF & "COLORÅ°" & $COLOR  )
	  $FLG = False
   Else
	  $XY = MouseGetPos()
	  MsgBOX( 0, "position", "Get Position" )
	  $FLG = True
   endif

EndFunc


