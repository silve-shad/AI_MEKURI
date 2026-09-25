; Auto Mekuri & capture script

; ESC to Exit Program
HotKeySet("{ESC}", "Abort")
; 4 to Loop Reset
HotKeySet("4", "ResetTeisu")
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
HotKeySet("D", "StartStop")

; Press K to capture


; 1440*2528
; 1440/2 +-250 =  470,970
; 2528/2 +-250 =  1264  1014,1514

Const $D_LEFT = 470
Const $D_RIGHT = 1014
Const $D_TOP = 970
Const $D_BOTTOM =  1430


; 内部タイマー用変数（最大10）
global $Timer[10]

; 250 pages
$CT = 9999

; control flg UpLeft:1 Left:2 KeyLeft:3(default)
$ctl = 3

; control flg Stop:1(default) running:1
$ss = 0

; Page Counter
;$pg

$pg =0

;===========================================================
; main Function
;===========================================================

main()

;===========================================================

func main()
   local $befsum = 54321
   local $befbefsum = 12345

; 処理頁ループ
   while 1
	  ; ページ終了
	  if $pg >= $CT Then
		MsgBOX( 0, "PAUSE", "<Order End> Redo Press S/End Press ESC " )
		 $CT = 9999
		 $ss = 0 ; End (pause) & reset
		 $pg = 1
	  endif

	  ; 動作待機ループ
	   while 1
		   if $ss==1 Then
			  ; 開始
			   ; Press Capture Key 'C'　キャプチャ
			   exitLoop
		   endif
	   WEnd

	  Send ("9")
	  $pg = $pg +1
	   ; Aサム値取得
	  $sumvalue = PixelChecksum( $D_LEFT,$D_TOP,$D_RIGHT,$D_BOTTOM )
	  sleep(300)						;　一応キャプチャソフトの保存動作待ち
	  call( "Proc_Action"  )		;ページめくり
	  call( "Proc_ResetTimer", 0  )	; タイムアウト用タイマーリセット

	  ; 頁めくり待ち
	   while 1
			sleep(100)
			$LoopB = False
			if $sumvalue <> PixelChecksum( $D_LEFT,$D_TOP,$D_RIGHT,$D_BOTTOM) then
			   ; Aサムと異なる＝動き始め　階層
			   ; Bサム(1)
			   $Tvalue = PixelChecksum( $D_LEFT,$D_TOP,$D_RIGHT,$D_BOTTOM)
			   $nn=0
			   while 1
					 sleep(100)
					 if  ( $Tvalue <> PixelChecksum($D_LEFT,$D_TOP,$D_RIGHT,$D_BOTTOM) ) or ( ( 10461087 = PixelGetColor ( $D_LEFT, $D_TOP ) ) and  (10461087 = PixelGetColor ( $D_RIGHT , $D_TOP ) ) ) Then
						; 動きがあったので待ち開始処理やり直し
						; Bサム　取り直し
						$Tvalue = PixelChecksum( $D_LEFT,$D_TOP,$D_RIGHT,$D_BOTTOM)
						$nn=0
					 Else
						;Bサムと一致階層
						$nn = $nn+1
						if $nn>7 Then
						   ;　Bサムのまま0.8秒動きがない
						   $LoopB = True
						   exitloop
						EndIf
				  EndIf
			   Wend
			   ; 脱出
			   if $LoopB  then
				  exitloop
			   endif
			Else
				  ; まだ動き始めていない　or 動き出しを認識できない
				  ; ページめくって10秒タイムアウト
				  if  (9 < call( "Func_GetTimer", 0 ) ) Then
					 exitloop
				  EndIf
			endif
	  Wend
	  if $ss=1 then 	; 動作停止中は判定しない
			; Bサムが２頁前と一致＝終了
			if $Tvalue = $BefBefSum Then
			   MsgBOX( 0, "PAUSE", "Auto End Detect" )
			   $ss=0
			endif
	  endif
	  $befbefsum = $befsum
	  $befsum = $Tvalue
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
	  ; End of Program
	  MsgBOX( 0, "Exit", "<Program End>" )
	  Exit
EndFunc

; 3 to Loop+100
Func PlusHundred()
	$CT = $CT +100
EndFunc

; 2 to Loop+10
Func Plusten()
	$CT = $CT +10
EndFunc

;Counter Reset unlmit
Func PlusReset()
	$CT = 9999
	 $pg=1 ; Reset
EndFunc

;Counter Reset 250
Func ResetTeisu()
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
		$ss=0 ; runinng
	Else
		$ss=1	; stop
	EndIf
EndFunc

;========================================================================
; タイマーのリセット（０－９）: Timer 番号
Func Proc_ResetTimer(  $Num  )
		$Timer[$Num]  = @HOUR * 3600  + @MIN*60 + @SEC
endFunc

;========================================================================
;　前回のProc_ResetTimer　から何 sec たったかを返す（システム時計依存・24時間(86400)以上のインターバルは正しい値を返さない）　（０－９）: Timer 番号 は個別に取得
Func Func_GetTimer(  $Num  )
	local $CurrentTime = @HOUR * 3600  + @MIN*60 + @SEC
	if  $Timer[$Num]  <= $CurrentTime Then
		return  $CurrentTime - $Timer[$Num]
	Else
		return ($CurrentTime + 86400 )- $Timer[$Num]
	EndIf
endFunc

