; 処理の補足説明
AutoItSetOption("MustDeclareVars", 1)

; 処理の補足説明
HotKeySet("{ESC}", "Abort")
; 処理の補足説明
HotKeySet("{SPACE}", "Display")

global $FLG = False
Global $XY[1]

; 処理の補足説明
; 処理の補足説明
; 処理の補足説明
main()

func main()
   while True
	  Sleep( 50 )
   Wend
endfunc

; 処理の補足説明

; 処理の補足説明
Func Abort()
	  ; 処理の補足説明
	  MsgBOX( 0, "Exit", "<Program End>" )
	  Exit
EndFunc

Func Display()
   local $COLOR

   if ( $FLG = True   ) Then
	  $COLOR = PixelGetColor ( $XY[0], $XY[1]  )

	  MsgBOX( 0, "position", "X��"& $XY[0]&  @CRLF & "Y��"  & $XY[1]  & @CRLF & "COLOR��" & $COLOR  )
	  $FLG = False
   Else
	  $XY = MouseGetPos()
	  MsgBOX( 0, "position", "Get Position" )
	  $FLG = True
   endif

EndFunc


