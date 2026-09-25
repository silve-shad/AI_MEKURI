AutoItSetOption("MustDeclareVars", 1)

#include <Misc.au3>
#include <MsgBoxConstants.au3>

#include <Color.au3>

; 更新履歴。詳細な変更内容は Git の履歴を参照。
; 2019-08-20 から 2026-06-18 までのサイト別対応を含む。
; 対応サイト: DAYS、ヤングジャンプ、BookWalker、ebook、Komiflo、FUZ。

Const $LASTUPDATE  =  "260618"

; グローバルホットキー
HotKeySet("{ESC}", "Abort")
HotKeySet("!s", "StartStop")
HotKeySet("!e", "EndMode_Change")
HotKeySet("!w", "WaitTime_Change")
HotKeySet("!d", "DaysMode_Change")
HotKeySet("{+}", "ebook_ct_plus")

; 画面座標と動作モード
Const $XXX  =  0
Const $YYY  =  1

Const $JP_NEXT_X  =  1275
Const $JP_NEXT_Y  =  680

Const $EM_HANYOU = 0
Const $EM_DAYS = 1
Const $EM_YMWEB = 2
Const $EM_BOOKWALKER = 3
Const $EM_EBOOK = 4
Const $EM_JUMP = 5
Const $EM_KOMIFLO = 6
Const $EM_TONARIYJ = 7
Const $EM_FUZ = 8
Const $EM_MAX = 8

; Capture.ini から読み込む画面・判定設定
global $D_HEIGHT
global $D_WIDTH

global $D_CAPTURE_KEY

global $D_L_CLICK[2]

global $D_CHECK_HALF_SIZE

; 各サイトのローディング色・終了判定・ページ送り設定
global $D_JUMPPLUS_BACKCOLOR

global $D_YOUNGJUMP_BACKCOLOR

global $D_YOUNGJUMP_TEIKI_BACKCOLOR

global $D_CDAYS_BACKCOLOR

global $D_EB_BACKCOLOR
global $D_BW_BACKCOLOR[2]

; DAYS モードの処理設定
global $DCD_ENDCOLOR[2]
; DAYS モードの処理設定
global $DCD_ENDAXPOS[2]
global $DCD_ENDAYPOS
global $DCD_ENDBXPOS[2]
global $DCD_ENDBYPOS

; DAYS モードの処理設定
global $DCD_FSCREEN[2]

global $DYM_ENDPOS[2]
global $DYM_ENDCOLOR

; Komiflo の処理設定
global $DKM_END_PIXEL_X
global $DKM_END_PIXEL_Y
global $DKM_END_COL[2]

; BookWalker の処理設定
global $DBW_NEXT_POS[2]
global $DBW_NEXT_COL[2]

global $D_WAITTIMER_NORMAL
global $D_WAITTIMER_LONG
global $waittimer

; ジャンププラス、ヤングジャンプ、ebook の座標設定
global $D_JP_INDEX[2]
global $D_JP_RESET[2]
global $D_JP_TOPINDEX[2]

global $D_YJ_NEXT[2]
global $D_YJ_FULLSCREEN[2]

; ebook の処理設定
global $DEB_NEXT[2]
global $DEB_COLOR

; FUZ の処理設定
global $DFZ_NEXT_X1
global $DFZ_NEXT_X2
global $DFZ_NEXT_Y
global $DFZ_COLOR

; 実行状態とタイマー
global $Timer[10]
Global $ConfigKeys[128]
Global $ConfigValues[128]
Global $ConfigCount = 0
Global $ConfigLoaded = False

global $PageKind = 3
; NOX の処理設定

global $startstop = 0

global $DaysMode = 0

global $EndMode = 0

global $Ebook_CT = 1

global $NextPlus = False


main()

; 常駐ループ。開始状態を監視し、キャプチャとページ送りを繰り返す。
func main()
   local $befsum[3]
   local $ENDSum
   local $ebnext
   local $NextMachi
   local $NBF

   If _Singleton("CapMac", 1) = 0 Then
	   MsgBox($MB_SYSTEMMODAL, "Warning", "dN")
	   Exit
   EndIf

   $befsum[0]  = 0
   $befsum[1]  = 1
   $befsum[2]  = 2
   $NBF=false

	call ( "Proc_InitVar" )
	$waittimer =  $D_WAITTIMER_NORMAL

   while 1
			while 1
			   if $startstop=1 Then
				  If $EndMode = $EM_KOMIFLO Then
					  Sleep(3000) ; Komiflo の処理設定
				  Else
					  Sleep(1000)
				   EndIf
				  exitLoop
			   endif
			WEnd


		 if ( $NextPlus=True ) then
			$NBF=True
			$NextPlus = False
		 Endif

		 Send ($D_CAPTURE_KEY)
		 $ENDsum = call ("Proc_Mekuri")

		 if ( $NBF=True ) then
			sleep(3000)
			$NBF=False
		 Endif

		 WriteDebugLog("Mekuri -> V(END):" & $ENDsum & " | O(bef0):" & $befsum[0] & " | 2O(bef1):" & $befsum[1] & " | 3O(bef2):" & $befsum[2])

			Select
			Case $EndMode = $EM_DAYS
				  ; DAYS モードの処理設定
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				  if ( $DaysMode=1 ) then
					 if (  False = call("DaysBackColor")  ) Then
						$NextMachi = True
						sleep(5000)
					 endif
				  endif
				   ; DAYS モードの処理設定
				   $NextMachi = call ("Proc_DaysNext")
			Case $EndMode = $EM_YMWEB
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				   $NextMachi = call ("Proc_YMNext")
			Case $EndMode = $EM_FUZ
				  ; FUZ の処理設定
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				    ; FUZ の処理設定
				   $NextMachi = call ("Proc_FuzNext")
			Case $EndMode = $EM_KOMIFLO
				  ; Komiflo の処理設定
				  if (( False = Call("Func_IsColorArea",$DKM_END_PIXEL_X,$DKM_END_PIXEL_Y,$DKM_END_COL[0]) ) And _
					 ( False = Call("Func_IsColorArea",$DKM_END_PIXEL_X,$DKM_END_PIXEL_Y,$DKM_END_COL[1]) )) then
						SoundPlay(@WindowsDir & "\media\notify.wav",1)
						Send ($D_CAPTURE_KEY)
						$ENDsum = call ("Proc_Mekuri")
						; Komiflo の処理設定
						mousemove ( $D_WIDTH/2 ,($D_HEIGHT/2 )-300)
						mousemove ( $D_WIDTH/2 ,$D_HEIGHT/2  )
						mousemove ( $D_WIDTH/2 ,$D_HEIGHT/2  -150 )
						sleep ( 500 )
				  endif
			case Else
			endSelect

		   if $startstop=1 then

			   if ($ENDsum = $befsum[1]) and  ($befsum[0] = $befsum[2])  Then
				   $befsum[0]  = 9
				   $befsum[1]  = 99
				   $befsum[2]  = 999

			  SoundPlay(@WindowsDir & "\media\tada.wav",1)
				   Select
					Case $EndMode = $EM_HANYOU
							MsgBOX( 0, "PAUSE", "p Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_KOMIFLO
							MsgBOX( 0, "PAUSE", "KOMIFLO Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_DAYS
						  ; DAYS モードの処理設定
							MsgBOX( 0, "PAUSE", "DAYS Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_YMWEB
						  ; DAYS モードの処理設定
							MsgBOX( 0, "PAUSE", "}KWEB Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_EBOOK
						  ; ebook の処理設定
						  call ("Proc_EbookJapanNext")
					Case $EndMode = $EM_JUMP
						  call ("Proc_JumpPlusNext")
					Case $EndMode = $EM_TONARIYJ
						  call ("Proc_TonaJumpNext")
					Case $EndMode = $EM_FUZ
					; FUZ の処理設定
							MsgBOX( 0, "PAUSE", "FUZ Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_BOOKWALKER
					; BookWalker の処理設定
						  call ("Proc_BookwalkerNext")

				case Else
				endselect
			   endif
		endif
		$befsum[2] = $befsum[1]
		$befsum[1] = $befsum[0]
		$befsum[0] = $ENDsum
	Wend
endfunc



; 画面変化とローディング状態を確認し、一回分のページめくりを完了する。
Func Proc_Mekuri()
   local $ASum
   local $ExitFLG
   local $BSum
   local $CSum
   local $FSSum

   local $EJL
   local $JPL
   local $TYJL
   local $YJTL
   local $BWL
   local $CDL
   local $TO

    call( "Proc_ResetTimer", 0 )

    sleep(500)

	$Asum = call( "KoteiSum")
	call( "Proc_Action"  )
    call( "Proc_ResetTimer", 2  )

	$ExitFLG = False
	while 1
		if $Asum <> call( "KoteiSum") then
			$Bsum = call( "KoteiSum")
			call( "Proc_ResetTimer", 1  )
			while 1
				sleep(300)
				$EJL = call( "EbookJapanLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$JPL = call( "JumpPlusLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$TYJL = call( "ToYoungJumpLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$YJTL = call( "YoungJumpTeikiLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$BWL = call( "BookWalkerLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$CDL = call( "ComicDaysLoading",  $D_WIDTH/2,$D_HEIGHT/2 )

			   $Csum = call( "KoteiSum")
				if  ( $Bsum <> $Csum ) or _
				   ( 0<$EJL ) or _
				   ( 0<$JPL ) or _
				   ( 0<$TYJL ) or _
				   ( 0<$YJTL ) or _
				   ( 0<$BWL ) or _
				   ( 0<$CDL )  Then
						$Bsum = $Csum
						$TO =3

						if ( $TO<$EJL ) Then
						   $TO = $EJL
						EndIf
						if ( $TO<$JPL ) Then
						   $TO = $JPL
						EndIf
						if ( $TO<$TYJL ) Then
						   $TO = $TYJL
						EndIf
						if ( $TO<$YJTL ) Then
						   $TO = $YJTL
						EndIf
						if ( $TO<$BWL ) Then
						   $TO = $BWL
						EndIf
						if ( $TO<$CDL ) Then
						   $TO = $CDL
						EndIf

						if ( $TO<>3 ) Then
						   $NextPlus = True
						Else
						   $NextPlus = False
						endif

						call( "Proc_ResetTimer", 2  )
						if ($TO < call( "Func_GetTimer", 1 )) Then
						   $ExitFLG = True
						   exitloop
					   endif
				Else
					 if (1 < call( "Func_GetTimer", 2 )) Then
						Sleep( $waittimer )

						$ExitFLG = True
						exitloop
					 EndIf
				EndIf
			Wend

			if $ExitFLG  Then
				exitloop
			EndIf
		Else
			if  ( 5 < call( "Func_GetTimer", 0 ) ) Then
				exitloop
			 EndIf
		  endif
	Wend

	call( "Proc_ResetTimer", 0  )

	WriteDebugLog("Mekuri -> T(Asum):" & $Asum & " | IT(Bsum):" & $Bsum & " | ExitFLG:" & $ExitFLG & " | [fBO(TO):" & $TO)

   return $Bsum
endfunc

; 表示モードを切り替え、モードに応じた画面表示を更新する。
Func EndMode_Change()
	$EndMode = $EndMode + 1

	If $EM_MAX < $EndMode Then
		$EndMode = 0
	EndIf

	Select
	Case $EndMode = $EM_HANYOU
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "ypz/DMM/" )
	Case $EndMode = $EM_DAYS
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "R~bNDAYS" )
	Case $EndMode = $EM_YMWEB
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "}KWEB" )
	Case $EndMode = $EM_EBOOK
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "EbookAi+j" )
	Case $EndMode = $EM_JUMP
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "Wv{IA" )
	Case $EndMode = $EM_KOMIFLO
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "KomiFlo" )
	Case $EndMode = $EM_TONARIYJ
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "()WA" )
	Case $EndMode = $EM_FUZ
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "COMIC FUZ" )
	Case $EndMode = $EM_BOOKWALKER
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "BookWalkerw" )
	case Else
	endselect
EndFunc


; Capture.ini を読み込み、画面サイズ・座標・色判定値を初期化する。
 Func Proc_InitVar()
	$D_HEIGHT = call( "Func_GetParaValue", "capture.ini","D_HEIGHT")
	$D_WIDTH = call( "Func_GetParaValue", "capture.ini","D_WIDTH")

	$D_CAPTURE_KEY = call( "Func_GetParaValue", "capture.ini","D_CAPTURE_KEY")

	$D_L_CLICK[$XXX] = call( "Func_GetParaValue", "capture.ini","D_L_CLICK_X")
	$D_L_CLICK[$YYY] = call( "Func_GetParaValue", "capture.ini","D_L_CLICK_Y")

	$D_CHECK_HALF_SIZE = call( "Func_GetParaValue", "capture.ini","D_CHECK_HALF_SIZE")

	$D_JUMPPLUS_BACKCOLOR = call( "Func_GetParaValue", "capture.ini","D_JUMPPLUS_BACKCOLOR")
	$D_YOUNGJUMP_BACKCOLOR = call( "Func_GetParaValue", "capture.ini","D_YOUNGJUMP_BACKCOLOR")
	$D_YOUNGJUMP_TEIKI_BACKCOLOR = call( "Func_GetParaValue", "capture.ini","D_YOUNGJUMP_TEIKI_BACKCOLOR")
	$D_CDAYS_BACKCOLOR = call( "Func_GetParaValue", "capture.ini","D_CDAYS_BACKCOLOR")
	$D_BW_BACKCOLOR[0] = call( "Func_GetParaValue", "capture.ini","D_BW_BACKCOLOR1")
	$D_BW_BACKCOLOR[1] = call( "Func_GetParaValue", "capture.ini","D_BW_BACKCOLOR2")

	$DCD_ENDCOLOR[0] = call( "Func_GetParaValue", "capture.ini","DCD_ENDCOLORA")
	$DCD_ENDCOLOR[1] = call( "Func_GetParaValue", "capture.ini","DCD_ENDCOLORB")

   $DCD_ENDAXPOS[0] = call( "Func_GetParaValue", "capture.ini","DCD_ENDAXPOSL")
   $DCD_ENDAXPOS[1] = call( "Func_GetParaValue", "capture.ini","DCD_ENDAXPOSR")
   $DCD_ENDAYPOS= call( "Func_GetParaValue", "capture.ini","DCD_ENDAYPOS")

   $DCD_ENDBXPOS[0] = call( "Func_GetParaValue", "capture.ini","DCD_ENDBXPOSL")
   $DCD_ENDBXPOS[1] = call( "Func_GetParaValue", "capture.ini","DCD_ENDBXPOSR")
   $DCD_ENDBYPOS= call( "Func_GetParaValue", "capture.ini","DCD_ENDBYPOS")

   $DYM_ENDPOS[0] = call( "Func_GetParaValue", "capture.ini","DYM_ENDXPOS")
   $DYM_ENDPOS[1] = call( "Func_GetParaValue", "capture.ini","DYM_ENDYPOS")
   $DYM_ENDCOLOR = call( "Func_GetParaValue", "capture.ini","DYM_ENDCOLOR")

	$D_WAITTIMER_NORMAL = call( "Func_GetParaValue", "capture.ini","D_WAITTIMER_NORMAL")
	$D_WAITTIMER_LONG = call( "Func_GetParaValue", "capture.ini","D_WAITTIMER_LONG")

	$DKM_END_PIXEL_X = call( "Func_GetParaValue", "capture.ini","DKM_END_PIXEL_X")
	$DKM_END_PIXEL_Y = call( "Func_GetParaValue", "capture.ini","DKM_END_PIXEL_Y")
	$DKM_END_COL[0] = call( "Func_GetParaValue", "capture.ini","DKM_END_COL1")
	$DKM_END_COL[1] = call( "Func_GetParaValue", "capture.ini","DKM_END_COL2")

	$D_EB_BACKCOLOR = call( "Func_GetParaValue", "capture.ini","D_EB_BACKCOLOR")
	$DEB_NEXT[$XXX] = call( "Func_GetParaValue", "capture.ini","DEB_NEXT_X")
	$DEB_NEXT[$YYY] = call( "Func_GetParaValue", "capture.ini","DEB_NEXT_Y")
	$DEB_COLOR = call( "Func_GetParaValue", "capture.ini","DEB_NEXT_COLOR")

	$D_YJ_NEXT[$XXX] = call( "Func_GetParaValue", "capture.ini","DYJ_NEXT_X")
	$D_YJ_NEXT[$YYY] = call( "Func_GetParaValue", "capture.ini","DYJ_NEXT_Y")
	$D_YJ_FULLSCREEN[$XXX] = call( "Func_GetParaValue", "capture.ini","DYJ_FULLSCR_X")
	$D_YJ_FULLSCREEN[$YYY] = call( "Func_GetParaValue", "capture.ini","DYJ_FULLSCR_Y")

	$D_JP_INDEX[$XXX] = call( "Func_GetParaValue", "capture.ini","D_JP_INDEX_X")
	$D_JP_INDEX[$YYY] = call( "Func_GetParaValue", "capture.ini","D_JP_INDEX_Y")
	$D_JP_RESET[$XXX] = call( "Func_GetParaValue", "capture.ini","D_JP_RESET_X")
	$D_JP_RESET[$YYY] = call( "Func_GetParaValue", "capture.ini","D_JP_RESET_Y")
	$D_JP_TOPINDEX[$XXX] = call( "Func_GetParaValue", "capture.ini","D_JP_TOPINDEX_X")
	$D_JP_TOPINDEX[$YYY] = call( "Func_GetParaValue", "capture.ini","D_JP_TOPINDEX_Y")

	$DCD_FSCREEN[$XXX] = call( "Func_GetParaValue", "capture.ini","DCD_FSCREEN_X")
	$DCD_FSCREEN[$YYY] = call( "Func_GetParaValue", "capture.ini","DCD_FSCREEN_Y")

	$DBW_NEXT_POS[$XXX] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_POS_X")
	$DBW_NEXT_POS[$YYY] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_POS_Y")
	$DBW_NEXT_COL[0] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_COL1")
	$DBW_NEXT_COL[1] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_COL2")

	$DFZ_NEXT_X1 = call( "Func_GetParaValue", "capture.ini","DFZ_NEXT_POS_X1")
	$DFZ_NEXT_X2 = call( "Func_GetParaValue", "capture.ini","DFZ_NEXT_POS_X2")
	$DFZ_NEXT_Y = call( "Func_GetParaValue", "capture.ini","DFZ_NEXT_POS_Y")
	$DFZ_COLOR = call( "Func_GetParaValue", "capture.ini","DFZ_COLOR")
EndFunc

; 指定位置が設定色と一致するかを判定する。
func Func_IsColorArea( $xx,$yy,$color )
   if  ($color=PixelGetColor ($xx-5,$yy-5)) And _
	  ($color=PixelGetColor ($xx+5,$yy-5)) And _
	  ($color=PixelGetColor ($xx-5,$yy+5)) And _
	  ($color=PixelGetColor ($xx+5,$yy+5)) Then
	  return True
   else
	  return false
   Endif
EndFunc

; 固定位置の色を合計し、画面変化の検出に使う。
Func KoteiSum( )
   local $Asum
   local $Bsum

   Select
   case $EndMode = $EM_KOMIFLO
	  $Asum =  PixelChecksum( 1150,600,1400,850)
	  $Bsum =  PixelChecksum( 650,600,900,850)
	  return $Asum + $Bsum
   case Else
	  return call( "AreaSum",  $D_WIDTH/2,$D_HEIGHT/2 )
   endselect
EndFunc

; 指定範囲の色情報を集計する。
Func AreaSum( $xx,$yy )
	return PixelChecksum( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE,$xx+$D_CHECK_HALF_SIZE ,$yy+$D_CHECK_HALF_SIZE)
EndFunc

Func LoadingBackCheck( $color,$xx,$yy )
   if  ((  _
   ( $color = PixelGetColor ( $xx-$D_CHECK_HALF_SIZE, $yy-10 ) )  And _
   ( $color = PixelGetColor ( $xx-$D_CHECK_HALF_SIZE, $yy+10 ) ) ) or _
   (( $color = PixelGetColor ( $xx+$D_CHECK_HALF_SIZE, $yy-10 ) ) And _
   ( $color = PixelGetColor ( $xx+$D_CHECK_HALF_SIZE, $yy+10 ) ) _
   )) Then
	  return True
   Else
	  return False
   endif
EndFunc

Func Func_JudgeX_Color(  $color, $xpos ,$start,$end )
   local $ypos

   For $ypos = $start To $end step 4
		 if ($color = PixelGetColor ( $xpos ,$ypos )) Then
			return $ypos
		 endif
   Next

   return -1

endfunc

Func Func_JudgeX2_Color(  $color1, $color2, $xpos ,$start,$end )
   local $ypos
   local $nn
   local $colorA
   local $colorB
   $ypos=($start+$end)/2
   $nn=1

   while( ($ypos+$nn)<$end )
		 $colorA = PixelGetColor ( $xpos , $ypos-$nn )
		 $colorB = PixelGetColor ( $xpos , $ypos+$nn )
		 if ( _
			($color1 = $colorA ) or _
			($color2 = $colorA ) or _
			($color1 = $colorB ) or _
			($color2 = $colorB )  _
			) Then
			return $ypos
		 endif
		 $nn=$nn*2
   Wend

   return -1
endfunc

; ESC キーで常駐処理を終了する。
Func Abort()
	  MsgBOX( 0, "Exit",  $LASTUPDATE & "<Program End>" )
	  Exit
EndFunc

; 自動ページ送りの開始・停止を切り替える。
Func StartStop()
	if $startstop=1 Then
		$startstop=0
		MsgBOX( 0, "STOP", "STOP(MANUAL)" )
	Else
		$startstop=1
   EndIf
EndFunc

; ページ送り後の待機時間を切り替える。
Func WaitTime_Change()
	if $waittimer=$D_WAITTIMER_NORMAL Then
		$waittimer=$D_WAITTIMER_LONG
		MsgBOX( 0, "WAIT", "LONG WAIT" )
	Else
		$waittimer=$D_WAITTIMER_NORMAL
		MsgBOX( 0, "WAIT", "NORMAL WAIT" )
	EndIf
EndFunc

; DAYS の表示形式を切り替える。
Func DaysMode_Change()
	if $DaysMode=0 Then
		$DaysMode=1
		MsgBOX( 0, "DAYSMODE", "" )
	Else
		$DaysMode=0
		MsgBOX( 0, "DAYSMODE", "" )
	EndIf
EndFunc


; 指定したタイマーを現在時刻でリセットする。
Func Proc_ResetTimer(  $Num  )
		$Timer[$Num]  = @HOUR * 3600  + @MIN*60 + @SEC
endFunc

Func Func_GetTimer(  $Num  )
	local $CurrentTime = @HOUR * 3600  + @MIN*60 + @SEC
	if  $Timer[$Num]  <= $CurrentTime Then
		return  $CurrentTime - $Timer[$Num]
	Else
		return ($CurrentTime + 86400 )- $Timer[$Num]
	EndIf
endFunc

; 現在のページ送り方式に応じて入力を実行する。
Func Proc_Action()
	Select
	Case $PageKind = 1 ; NOX の処理設定
; NOX の処理設定
	Case $PageKind = 2
		MouseClick( "left",$D_L_CLICK[$XXX],$D_L_CLICK[$YYY],1 )
	Case else
		Send ("{LEFT}")
	EndSelect
EndFunc


; INI を一度だけ読み込み、設定値をメモリ上へ保持する。
Func Func_LoadConfig($filename)
	Local $fp
	Local $line
	Local $separator
	Local $key
	Local $value

	If StringInStr($filename, "\") = 0 Then
		$filename = @ScriptDir & "\" & $filename
	EndIf

	$fp = FileOpen($filename, 0)
	If $fp = -1 Then
		MsgBox(0, "Error", "設定ファイルを開けません: " & $filename)
		Return False
	EndIf

	While 1
		$line = FileReadLine($fp)
		If @error = -1 Then ExitLoop
		$line = StringStripWS($line, 3)
		If StringLen($line) = 0 Or StringLeft($line, 1) = ";" Then ContinueLoop

		$separator = StringInStr($line, "=")
		If $separator <= 0 Or $ConfigCount >= UBound($ConfigKeys) Then ContinueLoop

		$key = StringStripWS(StringLeft($line, $separator - 1), 3)
		$value = StringStripWS(StringMid($line, $separator + 1), 3)
		If StringLeft($value, 1) = '"' And StringRight($value, 1) = '"' Then
			$value = StringTrimRight(StringTrimLeft($value, 1), 1)
		EndIf

		$ConfigKeys[$ConfigCount] = $key
		$ConfigValues[$ConfigCount] = $value
		$ConfigCount += 1
	Wend

	FileClose($fp)
	$ConfigLoaded = True
	Return True
EndFunc

; 読み込み済みの設定値をキー名から取得する。
Func Func_GetParaValue($filename, $para)
	Local $index

	If Not $ConfigLoaded Then
		If Not Func_LoadConfig($filename) Then Exit
	EndIf

	For $index = 0 To $ConfigCount - 1
		If $ConfigKeys[$index] = $para Then Return $ConfigValues[$index]
	Next

	MsgBox(0, "Error", "設定項目が見つかりません: " & $para)
	Exit
EndFunc

Func EscapeNotEqual(  $Asum ,  $Xpos, $YPos  )
	local $NewSum
	Local $timeout = TimerInit()

	while 1
		$NewSum = call( "AreaSum", $Xpos,$YPos )
		if $Asum <> $NewSum Then
			Return True
		endif
		If TimerDiff($timeout) > 30000 Then Return False
		Sleep(50)
	wend
EndFunc

Func EscapeEqualSec(   $Xpos, $YPos , $SecTimer  )
	local $TimerCt
	local $Timermax
	local $Asum
	Local $timeout = TimerInit()

	$Timermax = $SecTimer*10-1
	$TimerCt = 0
	$Asum = call( "AreaSum", $Xpos,$YPos )

	while 1
		sleep(100)
		if (  $Asum=call( "AreaSum", $Xpos,$YPos )  ) Then
				$TimerCt = $TimerCt  +1
				if ( $TimerCt >$Timermax ) Then
					exitloop
				endif
		Else
				$TimerCt = 0
				$Asum = call( "AreaSum", $Xpos,$YPos )
		EndIf
		If TimerDiff($timeout) > 60000 Then Return False
	wend
	Return True
EndFunc




; ebook の処理設定
Func Proc_ebookJapanNext()
	  ; ebook の処理設定
	  local $CenterSum

	  $CenterSum = call( "KoteiSum")

	  $Ebook_CT = $Ebook_CT - 1
	  if (  0<$Ebook_CT ) Then
; ebook の処理設定
			 MouseClick( "left",$DEB_NEXT[$XXX],$DEB_NEXT[$YYY],1 )

			call( "EscapeNotEqual", $CenterSum ,  $D_WIDTH/2 ,$D_HEIGHT/2  )
			call( "EscapeEqualSec", $D_WIDTH/2 ,$D_HEIGHT/2  ,5)

			Sleep (4000)
			MouseClick("Left")
			Sleep (1000)
			MouseClick("Left")
			Sleep (5000)
	  Else
		  MsgBOX( 0, "PAUSE", "EB Auto End Detect" )
		  $startstop=0
	  endif
endfunc

; ebook の処理設定
Func Proc_ebookNextBook()
	local $distance =0

	while 1
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]+$distance,$DEB_COLOR) Then
				MouseClick( "left",$DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]+$distance,1 )
				exitloop
	 endif
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]+10, $DEB_NEXT[$YYY]+$distance,$DEB_COLOR) Then
				MouseClick( "left",$DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]+$distance,1 )
				exitloop
	 endif

	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]-$distance,$DEB_COLOR) Then
				MouseClick( "left",$DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]-$distance,1 )
				exitloop
	 endif
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]+10, $DEB_NEXT[$YYY]-$distance,$DEB_COLOR) Then
				MouseClick( "left",$DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]-$distance,1 )
				exitloop
	 endif

	  $distance = $distance +5

   if  $distance >200 Then
			 MsgBOX( 0, "Stop", "<Can't find Button>" )
			 exitloop
	  endif
	wend
EndFunc

; ebook の処理設定
Func ebook_ct_plus()
	if $EndMode=$EM_EBOOK Then
	  $Ebook_CT = $Ebook_CT + 1
	  MsgBOX( 0, "BOOKS", $Ebook_CT )
	EndIf
 EndFunc


; ジャンププラスの次ページへ進む。
Func Proc_JumpPlusNext()
	   local $ASum

		$Asum = call( "KoteiSum")

		MouseClick( "left",$JP_NEXT_X,$JP_NEXT_Y,1 )

		call( "EscapeNotEqual", $Asum ,  $D_WIDTH /2, $D_HEIGHT/2  )
		call( "EscapeEqualSec", $D_WIDTH /2, $D_HEIGHT/2  ,5)

		call( "EscapeNotEqual", $Asum ,  $D_WIDTH /2, $D_HEIGHT/2 )
		while 1
			call( "EscapeEqualSec", $D_WIDTH /2, $D_HEIGHT/2,1 )
			if  False =call( "JumpPlusLoading", $D_WIDTH /2, $D_HEIGHT/2 ) Then
				exitloop
			endif
		wend

		MouseClick( "left",$D_JP_INDEX[$XXX],$D_JP_INDEX[$YYY],1 )
		sleep(5000 )
		MouseClick( "left",$D_JP_RESET[$XXX],$D_JP_RESET[$YYY],1 )
		sleep(2000 )
		MouseClick( "left",$D_JP_TOPINDEX[$XXX],$D_JP_TOPINDEX[$YYY],1 )
		sleep(5000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")

		sleep(15000 )

endfunc

; DAYS モードの処理設定
Func Proc_DaysNext()
   local $xOpos
   local $xTpos
   local $ypos
   if ($DaysMode=0) Then
	  $xOpos = $DCD_ENDAXPOS[0]
	  $xTpos = $DCD_ENDAXPOS[1]
	  $ypos = $DCD_ENDAYPOS
   else
	  $xOpos = $DCD_ENDBXPOS[0]
	  $xTpos = $DCD_ENDBXPOS[1]
	  $ypos = $DCD_ENDBYPOS
   endif

   if  ( _
	  (-1 <> call( "Func_JudgeX2_Color", $DCD_ENDCOLOR[0], $DCD_ENDCOLOR[1], $xOpos , $ypos-20 , $ypos+20 ))  Or _
	  (-1 <> call( "Func_JudgeX2_Color", $DCD_ENDCOLOR[0], $DCD_ENDCOLOR[1], $xTpos , $ypos-20 , $ypos+20 )) _
	  ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			return true
   else
			return false
   endif
endfunc

; ヤングマガジンWEB の次ページへ進む。
Func Proc_YMNext()
   if  (  $DYM_ENDCOLOR = PixelGetColor( $DYM_ENDPOS[$XXX], $DYM_ENDPOS[$YYY] )  And  ( 16777215 = PixelGetColor( $DYM_ENDPOS[$XXX], $DYM_ENDPOS[$YYY]  - 200 ) ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			return true
   else
			return false
   endif
endfunc

; FUZ の処理設定
Func Proc_FuzNext()
   if  ( $DFZ_COLOR = PixelGetColor( $DFZ_NEXT_X1, $DFZ_NEXT_Y ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )

			MouseClick( "left",$DFZ_NEXT_X1,$DFZ_NEXT_Y )
			sleep ( 3000 )
			MouseClick( "left",$DFZ_NEXT_X1,$DFZ_NEXT_Y )
			sleep ( 3000 )

			return true
   elseif  ( $DFZ_COLOR = PixelGetColor( $DFZ_NEXT_X2, $DFZ_NEXT_Y ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )
			Send ($D_CAPTURE_KEY)
			sleep ( 1000 )

			MouseClick( "left",$DFZ_NEXT_X2,$DFZ_NEXT_Y )
			sleep ( 3000 )
			MouseClick( "left",$DFZ_NEXT_X2,$DFZ_NEXT_Y )
			sleep ( 3000 )

			return true
   else
			return false
   endif
endfunc

; となりのヤングジャンプの次ページへ進む。
Func Proc_TonaJumpNext()
   MouseClick( "left",$D_YJ_NEXT[$XXX],$D_YJ_NEXT[$YYY],1 )
   sleep(5000)

   MouseClick( "left",$D_YJ_FULLSCREEN[$XXX],$D_YJ_FULLSCREEN[$YYY],1 )
   sleep(2000)
endfunc

; BookWalker の処理設定
Func Proc_BookwalkerNext()
	  local $result[2]
	  $result[0] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[0] , $DBW_NEXT_POS[$XXX],430,850 )
	  $result[1] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[1] , $DBW_NEXT_POS[$XXX],430,850 )
	   if  ((-1 <> $result[0] ) Or  (-1 <> $result[1] )) Then

             WriteDebugLog("BW{^m -> XW: " & $DBW_NEXT_POS[$XXX] & " | oY1: " & $result[0] & " | oY2: " & $result[1])

			 if  (-1 <> $result[0])  Then
			  MouseClick( "left",$DBW_NEXT_POS[$XXX],$result[0]+5,1 )
			  else
			  MouseClick( "left",$DBW_NEXT_POS[$XXX],$result[1]+5,1 )
			  endif
			  sleep(13000)
	  Else
			 MsgBOX( 0, "PAUSE", "BW Auto End Detect" )
			 $startstop=0
	  endif
endfunc



Func JumpPlusLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_JUMPPLUS_BACKCOLOR,$xx,$yy ) ) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

Func ToYoungJumpLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_YOUNGJUMP_BACKCOLOR,$xx,$yy ) ) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

Func YoungJumpTeikiLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_YOUNGJUMP_TEIKI_BACKCOLOR,$xx,$yy ) ) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

Func ComicDaysLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_CDAYS_BACKCOLOR,$xx,$yy ) ) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

; DAYS モードの処理設定
Func   DaysBackColor( )
   local $xx , $yy
   local $startX
   local $startY , $endY
   local $color

   $startX = $DCD_ENDBXPOS[0] - 200
   $startY = $DCD_ENDBYPOS - 200
   $endY = $DCD_ENDBYPOS + 200

   $xx = $startX
   For $yy = $startY To $endY step 10
		 $color = _ColorGetRGB(PixelGetColor ( $xx ,$yy ))
		 if ( (True = call ("SbnAbs" , $color[0] , $color[1]) ) or (True = call ("SbnAbs" , $color[0] , $color[2])) ) Then
			return False
		 endif
		 $xx = $xx + 10
   Next

   $startX = $DCD_ENDBXPOS[1] - 200
   $startY = $DCD_ENDBYPOS - 200
   $endY = $DCD_ENDBYPOS + 200

   $xx = $startX
   For $yy = $startY To $endY step 10
		 $color = _ColorGetRGB(PixelGetColor ( $xx ,$yy ))
		 if ( (True = call ("SbnAbs" , $color[0] , $color[1]) ) or (True = call ("SbnAbs" , $color[0] , $color[2])) ) Then
			return False
		 endif
		 $xx = $xx + 10
   Next

   return True
EndFunc

Func SbnAbs( $aa,$bb )
   if (  Abs($aa-$bb)<5 ) Then
	  return false
   else
	  return True
   endif
EndFunc

Func BookWalkerLoading( $xx,$yy )
   if  (( True = call( "LoadingBackCheck",$D_BW_BACKCOLOR[0],$xx,$yy ))  Or _
	  ( True = call( "LoadingBackCheck",$D_BW_BACKCOLOR[1],$xx,$yy )) ) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

Func EbookJapanLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_EB_BACKCOLOR, $xx,$yy )) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

; デバッグログにメッセージを追記する。
Func WriteDebugLog($Message)
	Local $fp = FileOpen(@ScriptDir & "\debug_log.txt", 1)
	If $fp = -1 Then Return False
	FileWriteLine($fp, @HOUR & ":" & @MIN & ":" & @SEC & " - " & $Message)
	FileClose($fp)
	Return True
EndFunc




