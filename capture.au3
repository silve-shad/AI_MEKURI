AutoItSetOption("MustDeclareVars", 1)

#AutoIt3Wrapper_Change2CUI=N

#include <Misc.au3>
#include <MsgBoxConstants.au3>

#include <Color.au3>

; 更新履歴。詳細な変更内容は Git の履歴を参照。
; 2019-08-20 から 2026-06-18 までのサイト別対応を含む。
; 対応サイト: DAYS、ヤングジャンプ、BookWalker、ebook、Komiflo、FUZ。


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
Const $EM_YJBLUE = 9
Const $EM_MAX = 9

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
global $DCD_ENDAXPOS[2]
global $DCD_ENDAYPOS
global $DCD_ENDBXPOS[2]
global $DCD_ENDBYPOS

global $DYM_ENDPOS[2]
global $DYM_ENDCOLOR

; ヤンジャン(BLUE) の終了判定・ローディング色
global $DYJB_ENDCOLOR
global $DYJB_ENDAREA_W	; 終端色エリアとみなす最小の幅
global $DYJB_ENDAREA_H	; 終端色エリアとみなす最小の高さ
global $DYJB_FULLSCREEN[2]	; 「全画面」ボタン位置
global $D_YJB_BACKCOLOR

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

; ジャンププラス、となりのヤングジャンプの座標設定
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

global $startstop = 0

global $DaysMode = 0

global $EndMode = 0

global $Ebook_CT = 1

global $NextPlus = False

global $MekuriResultValid = False

; True の間はローディング色の判定を広い範囲で行う（タイムアウト後の再判定用）
global $WideCheck = False


main()

; 常駐ループ。開始状態を監視し、キャプチャとページ送りを繰り返す。
func main()
   local $befsum[3]
   local $ENDSum
   local $ebnext
   local $NextMachi
   local $NBF
   local $TimeoutCount = 0
   local $YJBMoved = False	; YJBLUE: 終端エリアから遷移した後、まだ有効なページ遷移がない

   If _Singleton("CapMac", 1) = 0 Then
	   MsgBox($MB_SYSTEMMODAL, "Warning", "二重起動はできません")
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
		 ; 直前がタイムアウトなら、偶然の色一致を避けるためローディング色を広く調べる
		 $WideCheck = ( $TimeoutCount >= 1 )
		 $ENDsum = call ("Proc_Mekuri")
		 $WideCheck = False

		 if ( $NBF=True ) then
			sleep(3000)
			$NBF=False
		 Endif

			 WriteDebugLog("Mekuri完了 -> 最新(END):" & $ENDsum & " | Valid:" & $MekuriResultValid & " | 前(bef0):" & $befsum[0] & " | 2回前(bef1):" & $befsum[1] & " | 3回前(bef2):" & $befsum[2])

			Proc_HandleMode($NextMachi, $ENDsum)

		   if $startstop=1 then

			   if $MekuriResultValid And ($ENDsum = $befsum[1]) and  ($befsum[0] = $befsum[2])  Then
				   $befsum[0]  = 9
				   $befsum[1]  = 99
				   $befsum[2]  = 999

			  SoundPlay(@WindowsDir & "\media\tada.wav",1)
				   Select
					Case $EndMode = $EM_HANYOU
							MsgBOX( 0, "PAUSE", "汎用 Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_KOMIFLO
							MsgBOX( 0, "PAUSE", "KOMIFLO Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_DAYS
							MsgBOX( 0, "PAUSE", "DAYS Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_YMWEB
							MsgBOX( 0, "PAUSE", "ヤングマガジンWEB Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_EBOOK
						  call ("Proc_EbookJapanNext")
					Case $EndMode = $EM_JUMP
						  call ("Proc_JumpPlusNext")
					Case $EndMode = $EM_TONARIYJ
						  call ("Proc_TonaJumpNext")
					Case $EndMode = $EM_FUZ
							MsgBOX( 0, "PAUSE", "FUZ Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_YJBLUE
							MsgBOX( 0, "PAUSE", "ヤンジャン(BLUE) Auto End Detect" )
							$startstop=0
					Case $EndMode = $EM_BOOKWALKER
						  call ("Proc_BookwalkerNext")

				case Else
				endselect
			   endif
		endif
		; ページ遷移なし（タイムアウト）が 3 回続いたら終端とみなす。
		; 有効なページ遷移が 1 回でもあれば数え直す。
		; YJBLUE は画面全体から終端色エリアを探し、見つかれば次の話へ遷移して継続する。
		; 遷移後に一度も有効なページ遷移がないまま再び 3 回タイムアウトした場合は停止する（無限ループ防止）。
		If $MekuriResultValid Then
			$TimeoutCount = 0
			$YJBMoved = False
		Else
			$TimeoutCount += 1
		EndIf
		If $startstop = 1 And $TimeoutCount >= 3 Then
			If $EndMode = $EM_YJBLUE And Not $YJBMoved And Proc_YJBlueNext() Then
				$YJBMoved = True
				$TimeoutCount = 0
			Else
				WriteDebugLog("Timeout Auto End -> 連続タイムアウト:" & $TimeoutCount)
				SoundPlay(@WindowsDir & "\media\tada.wav",1)
				MsgBOX( 0, "PAUSE", "Timeout Auto End Detect（ページ遷移なし 3回）" )
				$startstop = 0
			EndIf
		EndIf
		If $startstop = 0 Then
			$TimeoutCount = 0
			$YJBMoved = False
		EndIf

		If $MekuriResultValid Then
			$befsum[2] = $befsum[1]
			$befsum[1] = $befsum[0]
			$befsum[0] = $ENDsum
               Else
			$befsum[0] = 0
			$befsum[1] = 1
			$befsum[2] = 2
		EndIf
	Wend
endfunc



; モードごとのページ送りと終了判定を実行する。
Func Proc_HandleMode(ByRef $NextMachi, ByRef $ENDsum)
	Select
	Case $EndMode = $EM_DAYS
		If $NextMachi Then
			$NextMachi = False
			Sleep(5000)
		EndIf
		If $DaysMode = 1 And Not DaysBackColor() Then
			$NextMachi = True
			Sleep(5000)
		EndIf
		$NextMachi = Proc_DaysNext()
	Case $EndMode = $EM_YMWEB
		If $NextMachi Then
			$NextMachi = False
			Sleep(5000)
		EndIf
		$NextMachi = Proc_YMNext()
	Case $EndMode = $EM_FUZ
		If $NextMachi Then
			$NextMachi = False
			Sleep(5000)
		EndIf
		$NextMachi = Proc_FuzNext()
	Case $EndMode = $EM_YJBLUE
		; 終端判定はページごとには行わず、3 回連続タイムアウト時にメインループから行う
		$NextMachi = False
	Case $EndMode = $EM_KOMIFLO
		If Not Func_IsColorArea($DKM_END_PIXEL_X, $DKM_END_PIXEL_Y, $DKM_END_COL[0]) And _
			Not Func_IsColorArea($DKM_END_PIXEL_X, $DKM_END_PIXEL_Y, $DKM_END_COL[1]) Then
			SoundPlay(@WindowsDir & "\media\notify.wav", 1)
			Send($D_CAPTURE_KEY)
			$ENDsum = Proc_Mekuri()
			MouseMove($D_WIDTH / 2, ($D_HEIGHT / 2) - 300)
			MouseMove($D_WIDTH / 2, $D_HEIGHT / 2)
			MouseMove($D_WIDTH / 2, ($D_HEIGHT / 2) - 150)
			Sleep(500)
		EndIf
	EndSelect
EndFunc

; 画面変化とローディング状態を確認し、一回分のページめくりを完了する。
Func Proc_Mekuri()
   local $ASum
   local $ExitFLG
   local $BSum
   local $CSum
   local $FSSum

   local $LDL
   local $TO

   $MekuriResultValid = False
   $Bsum = 0

    call( "Proc_ResetTimer", 0 )

    sleep(500)

	$Asum = call( "KoteiSum")
	$Bsum = $Asum
	call( "Proc_Action"  )
    call( "Proc_ResetTimer", 2  )

	$ExitFLG = False
	while 1
		if $Asum <> call( "KoteiSum") then
			$Bsum = call( "KoteiSum")
			call( "Proc_ResetTimer", 1  )
			while 1
				sleep(300)
				$LDL = Func_ModeLoading( $D_WIDTH/2,$D_HEIGHT/2 )

			   $Csum = call( "KoteiSum")
				if  ( $Bsum <> $Csum ) or ( 0<$LDL ) Then
						$Bsum = $Csum
						$TO =3

						if ( $TO<$LDL ) Then
						   $TO = $LDL
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

						$MekuriResultValid = True
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

	WriteDebugLog("Mekuri詳細 -> 初期サム(Asum):" & $Asum & " | 最終サム(Bsum):" & $Bsum & " | ExitFLG:" & $ExitFLG & " | ローディング延長(TO):" & $TO & " | 広域判定:" & $WideCheck)

   return $Bsum
endfunc

; 表示モードを切り替え、モード名と使用可能なホットキーを表示する。
Func EndMode_Change()
	Local $name = ""
	Local $extra = ""
	Local $note = ""

	$EndMode = $EndMode + 1

	If $EM_MAX < $EndMode Then
		$EndMode = 0
	EndIf

	$PageKind = 3

	Select
	Case $EndMode = $EM_HANYOU
		$name = "汎用 (DMM)"
	Case $EndMode = $EM_DAYS
		$name = "コミック DAYS"
		$extra = "  Alt+D : 通常／定期購読モード切替（現在: " & Func_DaysModeName() & "）" & @CRLF
	Case $EndMode = $EM_YMWEB
		$name = "ヤングマガジンWEB"
	Case $EndMode = $EM_EBOOK
		$name = "ebookjapan"
		$extra = "  +     : 処理冊数を 1 増やす（現在: " & $Ebook_CT & "）" & @CRLF
	Case $EndMode = $EM_JUMP
		$name = "少年ジャンププラス"
	Case $EndMode = $EM_KOMIFLO
		$name = "KomiFlo"
	Case $EndMode = $EM_TONARIYJ
		$name = "となりのヤングジャンプ"
	Case $EndMode = $EM_FUZ
		$name = "COMIC FUZ"
	Case $EndMode = $EM_BOOKWALKER
		$name = "BookWalker"
	Case $EndMode = $EM_YJBLUE
		$name = "ヤンジャン(BLUE)"
		$note = "※ フルスクリーン状態から開始してください" & @CRLF
	EndSelect

	MsgBOX( 0, "PAUSE", $name & @CRLF & $note & @CRLF & _
		"使用可能なホットキー:" & @CRLF & _
		"  Alt+S : 開始／停止" & @CRLF & _
		"  Alt+W : 待機時間切替（通常／長め）" & @CRLF & _
		$extra )
EndFunc

; DAYS の表示モード名を返す。
Func Func_DaysModeName()
	If $DaysMode = 1 Then Return "定期購読モード"
	Return "通常モード"
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

   $DYJB_ENDCOLOR = call( "Func_GetParaValue", "capture.ini","DYJB_ENDCOLOR")
   $DYJB_ENDAREA_W = Number(call( "Func_GetParaValue", "capture.ini","DYJB_ENDAREA_W"))
   $DYJB_ENDAREA_H = Number(call( "Func_GetParaValue", "capture.ini","DYJB_ENDAREA_H"))
   $DYJB_FULLSCREEN[$XXX] = call( "Func_GetParaValue", "capture.ini","DYJB_FULLSCR_X")
   $DYJB_FULLSCREEN[$YYY] = call( "Func_GetParaValue", "capture.ini","DYJB_FULLSCR_Y")
   $D_YJB_BACKCOLOR = call( "Func_GetParaValue", "capture.ini","D_YJB_BACKCOLOR")

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

	$DBW_NEXT_POS[$XXX] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_POS_X")
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

; 指定位置の左右 2 点ずつがローディング色と一致するかを判定する。
; 広域判定中は画面全体に散らした 12 点がすべて一致したときだけローディングとみなす。
Func LoadingBackCheck( $color,$xx,$yy )
   if $WideCheck Then Return LoadingBackCheckWide($color)

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

; 横 4 点（15%, 30%, 70%, 85%）× 縦 3 点（25%, 50%, 75%）がすべてローディング色か判定する。
; 中央付近はローディングアイコンが出るため避けている。
Func LoadingBackCheckWide( $color )
   Local $xs[4] = [0.15, 0.30, 0.70, 0.85]
   Local $ys[3] = [0.25, 0.50, 0.75]
   Local $i, $j

   For $i = 0 To 3
	  For $j = 0 To 2
		 If $color <> PixelGetColor( Int($D_WIDTH*$xs[$i]), Int($D_HEIGHT*$ys[$j]) ) Then Return False
	  Next
   Next
   Return True
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
	  MsgBOX( 0, "Exit",  "最終ビルド日: " & Func_GetBuildDate() & @CRLF & "<Program End>" )
	  Exit
EndFunc

; 実行ファイル自身の更新日時をビルド日として返す（.au3 直接実行時はスクリプトの保存日時）。
Func Func_GetBuildDate()
	Local $t = FileGetTime(@ScriptFullPath, 0)
	If @error Then Return "不明"
	Return $t[0] & "-" & $t[1] & "-" & $t[2] & " " & $t[3] & ":" & $t[4]
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

; DAYS の表示形式を切り替える。DAYS モード以外では何もしない。
Func DaysMode_Change()
	If $EndMode <> $EM_DAYS Then Return

	if $DaysMode=0 Then
		$DaysMode=1
		MsgBOX( 0, "DAYSMODE", "定期購読モード" )
	Else
		$DaysMode=0
		MsgBOX( 0, "DAYSMODE", "通常モード" )
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
	Case $PageKind = 1 ; NOX（未使用）
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




; ebookjapan の次の巻へ進む。残り冊数が 0 になったら停止する。
Func Proc_ebookJapanNext()
	  local $CenterSum

	  $CenterSum = call( "KoteiSum")

	  $Ebook_CT = $Ebook_CT - 1
	  if (  0<$Ebook_CT ) Then
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

; ebookjapan の「次の巻」ボタンを色で探してクリックする（現在未使用）。
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

; ebookjapan モードで連続処理する冊数を 1 増やす。
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

; キャプチャキーを指定回数送信し、ページ描画の時間を確保する。
Func Proc_CaptureBurst($count, $delay)
	Local $index
	For $index = 1 To $count
		Send($D_CAPTURE_KEY)
		If $index < $count Then Sleep($delay)
	Next
EndFunc

; DAYS の最終ページ表示を色で検出し、検出時はキャプチャを追加で送る。
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
			Proc_CaptureBurst(3, 1000)
			return true
   else
			return false
   endif
endfunc

; ヤングマガジンWEB の最終ページ表示を色で検出し、検出時はキャプチャを追加で送る。
Func Proc_YMNext()
   if  (  $DYM_ENDCOLOR = PixelGetColor( $DYM_ENDPOS[$XXX], $DYM_ENDPOS[$YYY] )  And  ( 16777215 = PixelGetColor( $DYM_ENDPOS[$XXX], $DYM_ENDPOS[$YYY]  - 200 ) ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			Proc_CaptureBurst(3, 1000)
			return true
   else
			return false
   endif
endfunc

; FUZ の次話ボタンを色で検出し、検出時はキャプチャ後にクリックする。
Func Proc_FuzNext()
   if  ( $DFZ_COLOR = PixelGetColor( $DFZ_NEXT_X1, $DFZ_NEXT_Y ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			Proc_CaptureBurst(3, 1000)

			MouseClick( "left",$DFZ_NEXT_X1,$DFZ_NEXT_Y )
			sleep ( 3000 )
			MouseClick( "left",$DFZ_NEXT_X1,$DFZ_NEXT_Y )
			sleep ( 3000 )

			return true
   elseif  ( $DFZ_COLOR = PixelGetColor( $DFZ_NEXT_X2, $DFZ_NEXT_Y ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			Proc_CaptureBurst(3, 1000)

			MouseClick( "left",$DFZ_NEXT_X2,$DFZ_NEXT_Y )
			sleep ( 3000 )
			MouseClick( "left",$DFZ_NEXT_X2,$DFZ_NEXT_Y )
			sleep ( 3000 )

			return true
   else
			return false
   endif
endfunc

; ヤンジャン(BLUE) の終端処理。3 回連続タイムアウト時にメインループから呼ばれる。
; 画面全体から終端色（DYJB_ENDCOLOR）の DYJB_ENDAREA_W × DYJB_ENDAREA_H 以上のエリアを探し、
; 見つかれば次の話へ遷移して True、見つからなければ False を返す。
; キャプチャ 1 回 → エリア中心をダブルクリック → 「全画面」ボタン（DYJB_FULLSCR）をクリック → 9 秒待機。
; 待機後はメインループに戻り、キャプチャキー送信と {LEFT} の通常処理を続ける。
Func Proc_YJBlueNext()
   local $area
   local $hitX
   local $hitY

   ; カーソルが乗っていると色が変わるため、探す前に原点へ退避する
   MouseMove( 0, 0 )
   Sleep(500)

   $area = Func_FindColorArea( $DYJB_ENDCOLOR, $DYJB_ENDAREA_W, $DYJB_ENDAREA_H )
   if @error Then
			WriteDebugLog("YJBLUE 終端エリアなし -> 停止")
			return false
   endif
   $hitX = $area[0]
   $hitY = $area[1]

   ; ダブルクリック前に終端画面を 1 回キャプチャする
   SoundPlay(@WindowsDir & "\media\notify.wav",1)
   Send($D_CAPTURE_KEY)
   Sleep(1000)

   MouseClick( "left", $hitX, $hitY, 2 )
   ; カーソルが残ると検出位置の色が変わるため原点へ退避する
   MouseMove( 0, 0 )
   Sleep(3000)

   ; 「全画面」ボタンをクリック（判定位置とは無関係の座標）
   MouseClick( "left", $DYJB_FULLSCREEN[$XXX], $DYJB_FULLSCREEN[$YYY], 1 )
   Sleep(9000)

   WriteDebugLog("YJBLUE 終端検出 -> 検出座標: " & $hitX & "," & $hitY & " | 次の話へ移動")
   return true
endfunc

; 画面全体から、指定色だけで埋まった $w × $h 以上の矩形エリアを探す。
; 見つかればエリア中心の座標 [x, y] を返し、なければ @error = 1。
; PixelSearch で候補点（左上から走査して最初に見つかる点）を探し、そこを左上とする矩形を検証する。
Func Func_FindColorArea( $color, $w, $h )
   Local $maxX = $D_WIDTH - 1
   Local $maxY = $D_HEIGHT - $h
   Local $x = 0
   Local $y = 0
   Local $tries = 0
   Local $p

   While $tries < 300 And $y <= $maxY
	  ; 現在行の残り → 見つからなければ次の行以降を探す
	  $p = PixelSearch( $x, $y, $maxX, $y, $color )
	  If @error Then
		 If $y + 1 > $maxY Then ExitLoop
		 $p = PixelSearch( 0, $y + 1, $maxX, $maxY, $color )
		 If @error Then ExitLoop
	  EndIf
	  $tries += 1

	  If Func_IsColorRect( $color, $p[0], $p[1], $w, $h ) Then
		 Local $center[2] = [ $p[0] + Int($w / 2), $p[1] + Int($h / 2) ]
		 Return $center
	  EndIf

	  ; 次の候補はこの点の右から
	  $x = $p[0] + 1
	  $y = $p[1]
	  If $x > $maxX Then
		 $x = 0
		 $y += 1
	  EndIf
   WEnd
   Return SetError(1, 0, 0)
EndFunc

; ($x, $y) を左上とする $w × $h の矩形が指定色で埋まっているかを 4 ピクセル間隔で確認する。
Func Func_IsColorRect( $color, $x, $y, $w, $h )
   Local $i, $j
   If $x + $w > $D_WIDTH Or $y + $h > $D_HEIGHT Then Return False

   For $j = $y To $y + $h - 1 Step 4
	  For $i = $x To $x + $w - 1 Step 4
		 If PixelGetColor( $i, $j ) <> $color Then Return False
	  Next
	  If PixelGetColor( $x + $w - 1, $j ) <> $color Then Return False
   Next
   For $i = $x To $x + $w - 1 Step 4
	  If PixelGetColor( $i, $y + $h - 1 ) <> $color Then Return False
   Next
   Return True
EndFunc

; となりのヤングジャンプの次話へ進み、全画面表示に戻す。
Func Proc_TonaJumpNext()
   MouseClick( "left",$D_YJ_NEXT[$XXX],$D_YJ_NEXT[$YYY],1 )
   sleep(5000)

   MouseClick( "left",$D_YJ_FULLSCREEN[$XXX],$D_YJ_FULLSCREEN[$YYY],1 )
   sleep(2000)
endfunc

; BookWalker の次巻ボタンを色で探してクリックする。見つからなければ停止する。
Func Proc_BookwalkerNext()
	  local $result[2]
	  $result[0] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[0] , $DBW_NEXT_POS[$XXX],430,850 )
	  $result[1] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[1] , $DBW_NEXT_POS[$XXX],430,850 )
	   if  ((-1 <> $result[0] ) Or  (-1 <> $result[1] )) Then

             WriteDebugLog("BWボタン検知 -> X座標: " & $DBW_NEXT_POS[$XXX] & " | 検出Y1: " & $result[0] & " | 検出Y2: " & $result[1])

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



; 現在のモードに対応するローディング色だけを判定する。
; ローディング中なら延長秒数（20）、それ以外や対象外のモードでは 0 を返す。
Func Func_ModeLoading($xx, $yy)
	Select
	Case $EndMode = $EM_EBOOK
		Return EbookJapanLoading($xx, $yy)
	Case $EndMode = $EM_JUMP
		Return JumpPlusLoading($xx, $yy)
	Case $EndMode = $EM_TONARIYJ
		If ToYoungJumpLoading($xx, $yy) > 0 Then Return 20
		Return YoungJumpTeikiLoading($xx, $yy)
	Case $EndMode = $EM_BOOKWALKER
		Return BookWalkerLoading($xx, $yy)
	Case $EndMode = $EM_DAYS
		Return ComicDaysLoading($xx, $yy)
	Case $EndMode = $EM_YJBLUE
		Return YJBlueLoading($xx, $yy)
	EndSelect
	Return 0
EndFunc

; ローディング色の判定結果を共通形式で返す。
Func Func_IsLoadingColor($color, $xx, $yy)
	If LoadingBackCheck($color, $xx, $yy) Then Return 20
	Return 0
EndFunc

Func JumpPlusLoading($xx, $yy)
	Return Func_IsLoadingColor($D_JUMPPLUS_BACKCOLOR, $xx, $yy)
EndFunc

Func ToYoungJumpLoading($xx, $yy)
	Return Func_IsLoadingColor($D_YOUNGJUMP_BACKCOLOR, $xx, $yy)
EndFunc

Func YoungJumpTeikiLoading($xx, $yy)
	Return Func_IsLoadingColor($D_YOUNGJUMP_TEIKI_BACKCOLOR, $xx, $yy)
EndFunc

Func ComicDaysLoading($xx, $yy)
	Return Func_IsLoadingColor($D_CDAYS_BACKCOLOR, $xx, $yy)
EndFunc

Func YJBlueLoading($xx, $yy)
	Return Func_IsLoadingColor($D_YJB_BACKCOLOR, $xx, $yy)
EndFunc

; DAYS 定期購読モードで、終了判定位置の周辺が無彩色（グレー系）かを調べる。
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
	 If LoadingBackCheck($D_BW_BACKCOLOR[0], $xx, $yy) Or _
			LoadingBackCheck($D_BW_BACKCOLOR[1], $xx, $yy) Then Return 20
	 Return 0
EndFunc

Func EbookJapanLoading( $xx,$yy )
	 Return Func_IsLoadingColor($D_EB_BACKCOLOR, $xx, $yy)
EndFunc

; デバッグログにメッセージを追記する。
Func WriteDebugLog($Message)
	Local $fp = FileOpen(@ScriptDir & "\debug_log.txt", 1)
	If $fp = -1 Then Return False
	FileWriteLine($fp, @HOUR & ":" & @MIN & ":" & @SEC & " - " & $Message)
	FileClose($fp)
	Return True
EndFunc




