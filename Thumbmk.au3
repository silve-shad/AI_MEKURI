; 一定間隔で↓キーを送り続ける補助ツール。
AutoItSetOption("MustDeclareVars", 1)

; ESC: 終了 / A: 間隔 +1 秒 / Z: 間隔 -1 秒 / S: 開始・停止
HotKeySet("{ESC}", "Abort")
HotKeySet("A", "PlusOne")
HotKeySet("Z", "MinusOne")
HotKeySet("S", "StartStop")

global $startstop = 0

; キー送信の間隔（秒）
Const $D_WAITTIMER_NORMAL =  3
global $waittimer =  $D_WAITTIMER_NORMAL

main()

func main()
   while 1
			; 開始されるまで待機する
			while 1
			   if $startstop=1 Then
				   exitLoop
			   endif
			WEnd

			Send ("{DOWN}")

			sleep( $waittimer *1000  )
Wend
endfunc

Func Abort()
	  MsgBOX( 0, "Exit", "<ThumbMk End>" )
	  Exit
EndFunc


Func PlusOne()
	$waittimer = $waittimer +1
EndFunc
Func MinusOne()
	if 	$waittimer >1 Then
		$waittimer = $waittimer -1
	endif
EndFunc

Func StartStop()
	if $startstop=1 Then
		$startstop=0
		MsgBOX( 0, "STOP", "PAUSE" )
	Else
		$startstop=1
   EndIf
EndFunc
