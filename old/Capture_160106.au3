; Auto Mekuri & capture script

; ESC to Exit Program
HotKeySet("{ESC}", "Abort")
; 3 to Loop+100
HotKeySet("3", "PlusHundred")
; 2 to Loop+10
HotKeySet("2", "Plusten")
; R to LoopReset
HotKeySet("R", "PlusReset")
; Q to UpLeft Click
HotKeySet("Q", "UpLeftClick")
; A to Left Click
HotKeySet("A", "LeftClick")
; Z to Left Cursor
HotKeySet("Z", "LeftCurSorKey")
; S to Start/Stop (Counter Reset)
HotKeySet("S", "StartStop")
; UP to SpeedUp
HotKeySet("{UP}", "SpeedUp")
; DOWN to SpeedDown
HotKeySet("{DOWN}", "SpeedDown")

; Press C to capture


; 250 pages
$CT = 250

; Interval 3000 msec
$Inval = 3000

; control flg UpLeft:1 Left:2 KeyLeft:3(default)
$ctl = 3

; control flg exit:0 Stop:1(default) running:2
$ss = 1

; Page Counter
;$pg

$pg =0

;===========================================================
; main Function
;===========================================================

main()

;===========================================================

func main()
   ; 処理頁ループ
   while 1
	  if $pg >= $CT Then
		MsgBOX( 0, "PAUSE", "<Order End> Redo Press S/End Press ESC " )
		 $ss=1 ; End (pause) & reset
		 $CT = 250
		 $pg = 1
	  endif
	  ; 待機ループ
	   while 1
		   if  $ss==0 Then
			   ; End of Program
			  MsgBOX( 0, "Exit", "<Program End>" )
			   Exit
		   endif
		   if $ss==2 Then
			   exitLoop
		   endif
	   WEnd

	  ; Press Capture Key 'C'
	   Send ("C")

	   ; Interval
	   sleep($Inval)

	   ; Action
	   Proc_Action()
	  $pg = $pg +1
   Wend
endfunc


;=====================================================
Func Proc_Action()
	Select
	Case $ctl == 1
		MouseClick( "left",100,100,1 )
	Case $ctl == 2
		MouseClick( "left",100,500,1 )
	Case $ctl == 3
		Send ("{LEFT}")
	EndSelect
EndFunc

;　終了
Func Abort()
	$ss = 0
EndFunc

; 1 to Loop+100
Func PlusHundred()
	$CT = $CT +100
EndFunc

; 2 to Loop+10
Func Plusten()
	$CT = $CT +10
EndFunc

;Counter Reset
Func PlusReset()
	$CT = 250
	 $pg=1 ; Reset
EndFunc

; Q to UpLeft Click
Func UpLeftClick()
	$ctl = 1
EndFunc

; A to Left Click
Func LeftClick()
	$ctl = 2
EndFunc

; Z to Left Cursor
Func LeftCurSorKey()
	$ctl = 3
EndFunc

; S to Start/Pause
Func StartStop()
	if $ss==1 Then
		$ss=2 ; runinng
	Else
		$ss=1	; stop
	EndIf
EndFunc

; UP to SpeedUp 200msec
Func SpeedUp()
	$Inval = $Inval - 200
EndFunc

; DOWN to SpeedDown 200msec
Func SpeedDown()
	$Inval = $Inval + 200
EndFunc

