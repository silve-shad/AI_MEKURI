; Thumbnail make Script
AutoItSetOption("MustDeclareVars", 1)


; ショートカットまとめ
;　「ESC」終了
; A: ウェイト時間＋１秒
; Z: ウェイト時間-１秒
; S: Start/Stop


; ESC to Exit Program
HotKeySet("{ESC}", "Abort")
; A 
HotKeySet("A", "PlusOne")
; Z 
HotKeySet("Z", "MinusOne")
; S to Start/Stop (Counter Reset)
HotKeySet("S", "StartStop")


; control flg Stop:0(default) running:1
global $startstop = 0

; Wait Timer Counter
Const $D_WAITTIMER_NORMAL =  3
global $waittimer =  $D_WAITTIMER_NORMAL

;===========================================================
; main Function
;===========================================================

main()

;===========================================================

func main()

	; 大ループ（永遠）
   while 1
			; 動作待機ループ
			while 1
			   if $startstop=1 Then
				  ; 開始
				   exitLoop
			   endif
			WEnd

			; 下キー押下
			Send ("{DOWN}")

			; 指定時間スリープ
			sleep( $waittimer *1000  )
Wend
endfunc

;　終了
Func Abort()
	  ; End of Program
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

; S to Start/Pause
Func StartStop()
	if $startstop=1 Then
		$startstop=0 ; STOP
		MsgBOX( 0, "STOP", "PAUSE" )
	Else
		$startstop=1	; START
   EndIf
EndFunc
