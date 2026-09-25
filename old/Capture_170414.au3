; Auto Mekuri & capture script
AutoItSetOption("MustDeclareVars", 1)

; ESC to Exit Program
HotKeySet("{ESC}", "Abort")
; A to Left Click
HotKeySet("A", "LeftClick")
; Z to Left Cursor
HotKeySet("Z", "LeftCurSorKey")
; X to Left Cursor + MOUSEMOVE
HotKeySet("X", "LeftCurSorKeyPlusMove")
; S to Start/Stop (Counter Reset)
HotKeySet("S", "StartStop")
; W to WaitTime Change
HotKeySet("W", "WaitTime_Change")

; Press 9 to capture
Const $D_CAPTURE_KEY =  "9"

; クリック位置（左上・左）
Const $D_UL_CLICK_X =  100
Const $D_UL_CLICK_Y =  100
Const $D_L_CLICK_X =  20
Const $D_L_CLICK_Y =  1260

; ページめくり遷移確認領域（中央部500*500）
; 画面サイズを 1440*2528　と想定
; 1440/2 +-250 =  470,970
; 2528/2 +-250 =  1264  1014,1514
Const $D_CHECK_CENTER_X =  720
Const $D_CHECK_CENTER_Y =  1264

Const $D_CHECK_HALF_SIZE =  250

; ジャンププラスのLOADING背景グレー
Const $D_JUMPPLUS_BACKCOLOR = 10461087

; 内部タイマー用変数（最大10）
global $Timer[10]

; control flg UpLeft:1 Left:2 KeyLeft:3 (default)  KeyLeft;Move:4
global $PageKind = 3

; control flg Stop:0(default) running:1
global $startstop = 0

; Wait Timer Counter
Const $D_WAITTIMER_NORMAL =  7
Const $D_WAITTIMER_LONG =  14
global $waittimer =  $D_WAITTIMER_NORMAL

;===========================================================
; main Function
;===========================================================

main()

;===========================================================

func main()
   local $befsum[3]
   local $ASum
   local $BSum
   local $FSSum[4]
   local $LoopFLG
   local $LoopCt


   $befsum[0]  = 0
   $befsum[1]  = 1
   $befsum[2]  = 2

	; 大ループ（永遠）
   while 1
			; 動作待機ループ
			while 1
			   if $startstop=1 Then
				  ; 開始
				   exitLoop
			   endif
			WEnd

			if $PageKind = 4 Then
				 ; キャプチャ前に中央からマウスを動かす(komiflo対策)
				 mousemove ( 700 ,1260 )
				 mousemove ( 700 ,960 )
				 mousemove ( 700 ,1260 )
				 sleep ( 500 )
			endif

			; キャプチャキー押下
			Send ($D_CAPTURE_KEY)
			; ★Aサム値設定（めくり前基準サム）
			$Asum = call( "AreaSum", $D_CHECK_CENTER_X,$D_CHECK_CENTER_Y )
			sleep(300)						;　一応キャプチャソフトの保存動作待ち
			call( "Proc_Action"  )		;ページめくり
			call( "Proc_ResetTimer", 0  )	; タイムアウト用タイマーリセット

			; 頁めくりループ
			$LoopFlg = False
			while 1
				sleep(100)
				if $Asum <> call( "AreaSum", $D_CHECK_CENTER_X,$D_CHECK_CENTER_Y ) then
					; Aサムと異なる＝動き始め　階層
					; ★Bサム値初回設定（動き始めサム）
					$Bsum = call( "AreaSum", $D_CHECK_CENTER_X,$D_CHECK_CENTER_Y )
					$FSsum[0] = call( "AreaSum", $D_CHECK_CENTER_X+400,$D_CHECK_CENTER_Y+500 )
					$FSsum[1] = call( "AreaSum", $D_CHECK_CENTER_X+400,$D_CHECK_CENTER_Y-500 )
					$FSsum[2] = call( "AreaSum", $D_CHECK_CENTER_X-400,$D_CHECK_CENTER_Y+500 )
					$FSsum[3] = call( "AreaSum", $D_CHECK_CENTER_X-400,$D_CHECK_CENTER_Y-500 )
					$LoopCt=0
					while 1
						sleep(100)
						if  ( $Bsum <> call( "AreaSum", $D_CHECK_CENTER_X,$D_CHECK_CENTER_Y  ) ) or _
						   ( $FSsum[0] <> call( "AreaSum", $D_CHECK_CENTER_X+400,$D_CHECK_CENTER_Y+500 )   ) or _
						   ( $FSsum[1] <> call( "AreaSum", $D_CHECK_CENTER_X+400,$D_CHECK_CENTER_Y-500 )   ) or _
						   ( $FSsum[2] <> call( "AreaSum", $D_CHECK_CENTER_X-400,$D_CHECK_CENTER_Y+500 )   ) or _
						   ( $FSsum[3] <> call( "AreaSum", $D_CHECK_CENTER_X-400,$D_CHECK_CENTER_Y-500 )   ) or _
						   ( True=call( "JumpPlusLoading", $D_CHECK_CENTER_X,$D_CHECK_CENTER_Y ) ) Then
							; 動きがあったもしくは、特定のグレー　　→　遷移未完了
							; ★Bサム値最新設定（動き始めと異なる最新のサム）
							  $Bsum = call( "AreaSum", $D_CHECK_CENTER_X,$D_CHECK_CENTER_Y )
							  $FSsum[0] = call( "AreaSum", $D_CHECK_CENTER_X+400,$D_CHECK_CENTER_Y+500 )
							  $FSsum[1] = call( "AreaSum", $D_CHECK_CENTER_X+400,$D_CHECK_CENTER_Y-500 )
							  $FSsum[2] = call( "AreaSum", $D_CHECK_CENTER_X-400,$D_CHECK_CENTER_Y+500 )
							  $FSsum[3] = call( "AreaSum", $D_CHECK_CENTER_X-400,$D_CHECK_CENTER_Y-500 )
							$LoopCt=0
						Else
							;Bサムと一致階層
							$LoopCt = $LoopCt+1
							;　Bサムのまま0.8秒動きがない　= 遷移行なわれて完了した。
							if $LoopCt>7 Then
								; 脱出（一段）
								$LoopFLG = True
								exitloop
							EndIf
						EndIf
					Wend
					; 脱出（ニ段）　一段から連続する
					if $LoopFLG  then
						exitloop
					endif
				Else
					; まだ動き始めていない（動き出しを認識できない）
					; １0秒タイムアウト
					if  (9 < call( "Func_GetTimer", 0 ) ) Then
						exitloop
					EndIf
				endif
			Wend

		; 自動停止判定
		if $startstop=1 then 	; 動作停止中は自動停止しない
			; 自動停止判定 a->b->c-.>d    a=c &  b=d
			if $Bsum = $befsum[1] and  $befsum[0] = $befsum[2]  Then
				MsgBOX( 0, "PAUSE", "Auto End Detect" )
				$startstop=0
			endif
		endif
		$befsum[2] = $befsum[1]
		$befsum[1] = $befsum[0]
		$befsum[0] = $Bsum
	Wend
endfunc

Func AreaSum( $xx,$yy )
	return PixelChecksum( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE,$xx+$D_CHECK_HALF_SIZE ,$yy+$D_CHECK_HALF_SIZE)
EndFunc

; ジャンププラスのLoading中判定（背景色による） LOADING =True
Func JumpPlusLoading( $xx,$yy )
   if  ( ( $D_JUMPPLUS_BACKCOLOR = PixelGetColor ( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE ) ) and  _
   ($D_JUMPPLUS_BACKCOLOR = PixelGetColor ( $xx+$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE) ) ) Then
	  return True
   Else
	  return False
   endif
EndFunc

;=====================================================
Func Proc_Action()
	Select
	Case $PageKind = 1
		MouseClick( "left",$D_UL_CLICK_X,$D_UL_CLICK_Y,1 )
	Case $PageKind = 2
		MouseClick( "left",$D_L_CLICK_X,$D_L_CLICK_Y,1 )
	Case $PageKind = 3
		Send ("{LEFT}")
	Case $PageKind = 4
		Send ("{LEFT}")
	EndSelect
EndFunc

;　終了
Func Abort()
	  ; End of Program
	  MsgBOX( 0, "Exit", "<Program End>" )
	  Exit
EndFunc

; Q to UpLeft Click
Func UpLeftClick()
	MsgBOX( 0, "CLICK", "CLICK UPLEFT" )
	$PageKind = 1
EndFunc

; A to Left Click
Func LeftClick()
	MsgBOX( 0, "CLICK", "CLICK" )
	$PageKind = 2
EndFunc

; Z to Left Key
Func LeftCurSorKey()
	MsgBOX( 0, "PUSH", "LEFT KEY" )
	$PageKind = 3
EndFunc

; X to Left Key+CursorMove
Func LeftCurSorKeyPlusMove()
	MsgBOX( 0, "PUSH", "LEFT KEY + Cursor Move" )
	$PageKind = 4
EndFunc

; S to Start/Pause
Func StartStop()
	if $startstop=1 Then
		$startstop=0 ; STOP
		MsgBOX( 0, "STOP", "STOP(MANUAL)" )
	Else
		$startstop=1	; START
   EndIf
EndFunc


Func WaitTime_Change()
	if $waittimer=$D_WAITTIMER_NORMAL Then
		$waittimer=$D_WAITTIMER_LONG
		MsgBOX( 0, "WAIT", "LONG WAIT" )
	Else
		$waittimer=$D_WAITTIMER_NORMAL
		MsgBOX( 0, "WAIT", "NORMAL WAIT" )
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

