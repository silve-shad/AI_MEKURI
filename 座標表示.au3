; マウス位置の座標と色を表示する補助ツール（Capture.ini の設定値調べ用）。
AutoItSetOption("MustDeclareVars", 1)

; ESC: 終了
HotKeySet("{ESC}", "Abort")
; SPACE: 1 回目で座標を記録し、2 回目でその座標と現在の色を表示
HotKeySet("{SPACE}", "Display")

global $FLG = False
Global $XY[1]

main()

func main()
   while True
	  Sleep( 50 )
   Wend
endfunc

Func Abort()
	  MsgBOX( 0, "Exit", "<Program End>" )
	  Exit
EndFunc

Func Display()
   local $COLOR

   if ( $FLG = True   ) Then
	  $COLOR = PixelGetColor ( $XY[0], $XY[1]  )

	  MsgBOX( 0, "position", "X座標："& $XY[0]&  @CRLF & "Y座標："  & $XY[1]  & @CRLF & "COLOR："  & $COLOR  )
	  $FLG = False
   Else
	  $XY = MouseGetPos()
	  MsgBOX( 0, "position", "Get Position" )
	  $FLG = True
   endif

EndFunc
