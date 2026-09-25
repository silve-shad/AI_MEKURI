; 処理の補足説明
AutoItSetOption("MustDeclareVars", 1)


; 処理の補足説明
; 処理の補足説明
; 処理の補足説明
; 処理の補足説明
; 処理の補足説明


; 処理の補足説明
HotKeySet("{ESC}", "Abort")
; 処理の補足説明
HotKeySet("A", "PlusOne")
; 処理の補足説明
HotKeySet("Z", "MinusOne")
; 処理の補足説明
HotKeySet("S", "StartStop")


; 処理の補足説明
global $startstop = 0

; 処理の補足説明
Const $D_WAITTIMER_NORMAL =  3
global $waittimer =  $D_WAITTIMER_NORMAL

; 処理の補足説明
; 処理の補足説明
; 処理の補足説明

main()

; 処理の補足説明

func main()

	; 処理の補足説明
   while 1
			; 処理の補足説明
			while 1
			   if $startstop=1 Then
				  ; 処理の補足説明
				   exitLoop
			   endif
			WEnd

			; 処理の補足説明
			Send ("{DOWN}")

			; 処理の補足説明
			sleep( $waittimer *1000  )
Wend
endfunc

; 処理の補足説明
Func Abort()
	  ; 処理の補足説明
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

; 処理の補足説明
Func StartStop()
	if $startstop=1 Then
		$startstop=0 ; 処理の補足説明
		MsgBOX( 0, "STOP", "PAUSE" )
	Else
		$startstop=1 ; 処理の補足説明
   EndIf
EndFunc
