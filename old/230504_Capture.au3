; Auto BookMekuri & capture script
AutoItSetOption("MustDeclareVars", 1)

#include <Misc.au3>
#include <MsgBoxConstants.au3>

#include <Color.au3>



;　履歴 YMD
; Ver2.00 19/08/20 横画面をデフォルトとする改修など
; Ver2.01 19/08/26 MagazineWalker で稀に発生するロード不良待ち追加
; Ver2.02 19/12/28 DAYSの終端仕様変更対応
; Ver2.03 20/02/06 ジャンプ＋連続時次本初期化対応
; Ver2.04 20/03/01 NOX+うぇぶり対応　ページめくり手法機能の削除
; Ver2.05 20/03/05 EBOOK 連続終端でのボタンを一定範囲検索するように回収　設定ファイル名称変更　setting.ini →capture.ini
; Ver2.06 20/03/16 DAYS 中断からの復帰機能
; Ver2.06 20/03/24 うぇぶりめくりをドラッグに対応
;  20/06/23 komiflo 終端２パターン対応
;  20/06/25 (バージョン廃止) ; 二重起動抑制 ; DAYS 終端再対応（拡大でマークが移動する事が判明した為
;  20/06/26 ; 定期ヤンジャンLoading背景色対応
;  20/07/05 ; BookWalker 連続対応()
;  20/07/17 ; komiflo 高速化 ; Bookwalker 誤認識あったのでモード分離 ;  CTRL+Z の中断終了追加
;  20/07/23 ; ebpook の連続購入カウンタ
;  20/07/25 ;  軽微な不具合
;  20/07/28 ;  軽微な不具合
;  20/08/10 ;  KOMIFLO LOADING待機
;  20/08/14 ;  軽微な不具合(komiflo終端)
;  20/11/13 ; Ebook 及び BookWalker 終端再調整
;  20/12/13 ; Komiflo 終端２パターン対応
;  21/01/13 ; Komiflo 終端仕様変更
;  21/05/08 ; ebooks 次巻開始仕様変更
;  21/09/23 ; NOX 削除　順番入れ替え　次巻処理中のカウンタ一時停止
;  21/09/28 ; Ebookだけ長く待つ＋ヤンマガweb連続対応(暫定)
;  21/10/29 ; 背景色白（ebook）の待ち時間延長
;  21/12/04 ; キー入力を止めないように修正（フック時に再スロー） ; 各種背景色時の待ち時間を全て延長＆背景色検出時にアラーム鳴らす
;  22/02/04 ; 白色背景時の検出条件のみ変更＆待ち時間を再度延長
;  22/03/22  DAYS のボタンを２色対応
;  22/03/24B BW のボタンを２色対応
;  22/03/24 LOADING判定の見直し
; 22/3/25 コード整理
; 22/3/25 DAYS独立
; 22/3/26 DAYS終端検出範囲最小化(速度対策)
; 22/3/26 Komiflo 区切り検出を複数箇所に（すり抜け確率を減らす）
; 22/3/30  汎用のタイムアウト直後で三秒待ち追加　暫定のヤンマガウェブ削除
; 22/9/12  ebook 背景判定処理漏れ修正
; 23/3/24  DAYS 色付き検出後待ち時間延長/ 全画面中断時リカバリ処理暫定削除 /  DAYSBW/COLOR分割
; 23/5/04  DAYS全画面中断処理復帰・DAYS中央・ヤンチャンウェブ中央
Const $LASTUPDATE  =  "230504"


; Jumpplus 処理削除

;============================================
; ■未実装仕様などメモ
; ★予定

; ★優先度低
;  ジャンププラスのヤンジャン連続
; SoundFile 定義
; 異なるディスプレイサイズに対応

;★不可能ぽい
; ヤンジャン定期購読連続実施対応

;============================================
; 取説的な仕様などメモ
;============================================
; ◆現行ショートカットまとめ
;　「ESC」終了

; S:　Start/Stop Toggle
; E: モード変更(ページ遷移方法も同時に変更)　
; W: ページ送り待ち時間変更　7sec(default)/14sec

; ■設定値保存ファイル　同フォルダの　"capture.ini"

; ■自動終端検出
;　条件 a->b->c->d で　a=c & b=d

;===================================================================================
; ◆◆現行の各サイト対応状況(全て横向きの見開きを前提に仕様を更新)
; ブラウザ・フル画面想定


;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;  定義

; ESC to Exit Program
HotKeySet("{ESC}", "Abort")
; S to Start/Stop (Counter Reset)
HotKeySet("s", "StartStop")
; E to EndMode Change
HotKeySet("e", "EndMode_Change")

; W to WaitTime Change
HotKeySet("w", "WaitTime_Change")

;+ to ebook Counter
HotKeySet("{+}", "ebook_ct_plus")

;===============================
;　定数　
;===============================

; 配列定数(Conｓｔ)
Const $XXX  =  0
Const $YYY  =  1

; ジャンプラ次本
Const $JP_NEXT_X  =  1275
Const $JP_NEXT_Y  =  680

Const $EM_HANYOU = 0
Const $EM_DAYSCL = 1
Const $EM_DAYSBW = 2
Const $EM_BOOKWALKER = 3
Const $EM_EBOOK = 4
Const $EM_JUMP = 5
Const $EM_KOMIFLO = 6
Const $EM_GORAKU = 7
Const $EM_TONARIYJ = 8
Const $EM_MAX = 8

;===============================
;　変数(capture.ini)
;===============================
; 画面サイズ
global $D_HEIGHT
global $D_WIDTH

; Press capture 時押下キー定義
global $D_CAPTURE_KEY

; ページめくりクリック位置（左）
global $D_L_CLICK[2]

; ページめくり遷移確認は中心基準で行う
global $D_CHECK_HALF_SIZE

;===============================
; LOADING 背景色
; ジャンププラスのLOADING背景色(グレー)
global $D_JUMPPLUS_BACKCOLOR

; （と）ヤンジャンLOADING背景色(グレー)
global $D_YOUNGJUMP_BACKCOLOR

; ヤンジャン定期購読LOADING背景色
global $D_YOUNGJUMP_TEIKI_BACKCOLOR

; コミックDAYSLOADING背景色(グレー)
global $D_CDAYS_BACKCOLOR

; ebookJapanのLOADING背景色(グレー)
global $D_EB_BACKCOLOR
; BookWalkerのLOADING背景色 2種(グレーと背景色)
global $D_BW_BACKCOLOR[2]
;===============================

; DAYSの終端検出色
global $DCD_ENDCOLOR[2]
; DAYSの終端検出X座標(2箇所)
global $DCD_ENDXPOS[2]
global $DCD_ENDYPOS

; DAYSのフルスクリーン復帰位置
global $DCD_FSCREEN[2]

; Komifloの区切り確認　X座標と色(横専用)
global $DKM_END_PIXEL_X
global $DKM_END_PIXEL_Y
global $DKM_END_COL[2]

;===============================
; bookwalker 次月ボタン　座標・色
global $DBW_NEXT_POS[2]
global $DBW_NEXT_COL[2]

; Wait Timer Counter
global $D_WAITTIMER_NORMAL
global $D_WAITTIMER_LONG
global $waittimer

; ジャンププラス設定
;=================================================
global $D_JP_INDEX[2]
global $D_JP_RESET[2]
global $D_JP_TOPINDEX[2]

;=================================================
;となりのヤングジャンプ
global $D_YJ_NEXT[2]
global $D_YJ_FULLSCREEN[2]

; EBOOK 特集　次巻クリック座標,(中心)ボタン色
global $DEB_NEXT[2]
global $DEB_COLOR

;=================================================
;サンデーうぇぶり
global $D_NOX_SW_PAGE[2]
global $D_NOX_SW_NEXT[2]

;===============================
;　変数(定義なし)
;===============================

; 内部タイマー用変数（最大10）
global $Timer[10]
; タイマー使用状態
; 0 ページ　
; 1　Mekuri内めくり終わらない
; 2　Mekuri内めくり終わり


global $PageKind = 3
; Click(NoX)+web_sunday:1
; UpLeft:1
; Left:2
; KeyLeft:3 (default)

global $startstop = 0
; Stop:0(default)
; Running:1

global $EndMode = 0

global $Ebook_CT = 1

; 待ち時間制御
global $NextPlus = False

;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;===========================================================
; main Function
;===========================================================

main()

;===========================================================

func main()
   local $befsum[3]
   local $ENDSum
   local $ebnext
   local $NextMachi
   local $NBF

;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;   初期化
   ; 二重起動の抑制
   If _Singleton("CapMac", 1) = 0 Then
	   MsgBox($MB_SYSTEMMODAL, "Warning", "多重起動はできません")
	   Exit
   EndIf

; 終端検出初期化
   $befsum[0]  = 0
   $befsum[1]  = 1
   $befsum[2]  = 2
   $NBF=false

	; 変数初期化
	call ( "Proc_InitVar" )
	$waittimer =  $D_WAITTIMER_NORMAL

;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
	; ページ単位ループ
   while 1
			; 動作待機中ミニループ
			; (動作してない時はこの中で待機)
			while 1
			   if $startstop=1 Then
				  ; 開始/再開
				   exitLoop
			   endif
			WEnd

		 ;============================================
		 ;============================================

		 ; 汎用前回タイムアウト後の待ち制御
		 if ( $NextPlus=True ) then
			$NBF=True
			$NextPlus = False
		 Endif

		 ; ★★★メインのキャプチャキー押下はコレ　★★★
		 Send ($D_CAPTURE_KEY)
		 ; ページめくり（めくり終わりまで抜けてこない）
		 $ENDsum = call ("Proc_Mekuri")

		 if ( $NBF=True ) then
			sleep(3000)
			$NBF=False
		 Endif

		 ;============================================
		 ;============================================
		   ; めくり後処理グループA（各誌で分岐）
			Select
			;============================================
			Case $EndMode = $EM_DAYSBW
			;============================================
				  ; DAYS前回タイムアウト後の待ち制御　重複？★整理できる
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				   ; daysの終端検出
				   $NextMachi = call ("Proc_DaysNext")
				   ;============================================
				  ; ページ中にカラー（広告？）があれば今ページと次ページの待ち時間延長5sec
				  if (  False = call("DaysBackColor")  ) Then
					 $NextMachi = True
					 sleep(5000)
				  endif
				  ;============================================
				  ; daysの全画面が中断された検出（横）
				  if  ( ( 3355443 = PixelGetColor ( 1400,1400 ) ) And _
					( 3355443 = PixelGetColor ( 1410,1400 ) )) Then
						   SoundPlay(@WindowsDir & "\media\tada.wav",1)
						   ; キャプチャ3回して
						   Send ($D_CAPTURE_KEY)
						   sleep ( 1000 )
						   Send ($D_CAPTURE_KEY)
						   sleep ( 1000 )
						   Send ($D_CAPTURE_KEY)
						   sleep ( 1000 )
						   ; フルスクリーンボタン押下して逃げる
						   MouseClick( "left",$DCD_FSCREEN[$XXX],$DCD_FSCREEN[$YYY],1 )
						   MouseMove( $DCD_FSCREEN[$XXX]-100,$DCD_FSCREEN[$YYY]-100 )
						   sleep ( 1000 )
						   ; １ページ戻る(継続)
						   Send ("{RIGHT}")
						   sleep ( 1000 )
				  endif
			;============================================
			Case $EndMode = $EM_DAYSCL
			;============================================
				  ; DAYS前回タイムアウト後の待ち制御　重複？★整理できる
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				   ; daysの終端検出
				   $NextMachi = call ("Proc_DaysNext")
				   ;============================================
			;============================================
			Case $EndMode = $EM_KOMIFLO
			;============================================
				  ; Komifloの区切り検出
				  if (( False = Call("Func_IsColorArea",$DKM_END_PIXEL_X,$DKM_END_PIXEL_Y,$DKM_END_COL[0]) ) And _
					 ( False = Call("Func_IsColorArea",$DKM_END_PIXEL_X,$DKM_END_PIXEL_Y,$DKM_END_COL[1]) )) then
						SoundPlay(@WindowsDir & "\media\notify.wav",1)
						; キャプチャキー押下
						Send ($D_CAPTURE_KEY)
						; ページめくり
						$ENDsum = call ("Proc_Mekuri")
						; キャプチャ前に中央から一旦マウスを動かす(komifloの表示消去対策)	中心からちょい上へ
						mousemove ( $D_WIDTH/2 ,($D_HEIGHT/2 )-300)
						mousemove ( $D_WIDTH/2 ,$D_HEIGHT/2  )
						mousemove ( $D_WIDTH/2 ,$D_HEIGHT/2  -150 )
						sleep ( 500 )
				  endif
			case Else
			endSelect

		 ;============================================
		 ;============================================
		   ; 停止処理・強制・自動検出
		   if $startstop=1 then 	; 動作停止中は停止判定必要ない
			   ; 自動停止判定 a->b->c-.>d    a=c &  b=d
			   if ($ENDsum = $befsum[1]) and  ($befsum[0] = $befsum[2])  Then
				   ; 終端検出変数の再初期化 （仮データ）
				   $befsum[0]  = 9
				   $befsum[1]  = 99
				   $befsum[2]  = 999

				  SoundPlay(@WindowsDir & "\media\tada.wav",1)
				   Select
   ;============================================
					Case $EndMode = $EM_HANYOU
	;============================================
							MsgBOX( 0, "PAUSE", "汎用 Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_KOMIFLO
	;============================================
							MsgBOX( 0, "PAUSE", "KOMIFLO Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_GORAKU
	;============================================
							MsgBOX( 0, "PAUSE", "GORAKU Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_DAYSCL
	;============================================
						  ; ■DAYS連続　
							MsgBOX( 0, "PAUSE", "DAYSCL Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_DAYSBW
	;============================================
						  ; ■DAYS連続　
							MsgBOX( 0, "PAUSE", "DAYSBW Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_EBOOK
						  ; ■ebookJapan連続　
						  call ("Proc_EbookJapanNext")
   ;============================================
					Case $EndMode = $EM_JUMP
						  ; ■ジャンプ(雑誌)連続　
						  call ("Proc_JumpPlusNext")
   ;============================================
					Case $EndMode = $EM_TONARIYJ
   ;============================================
					;  ■となりのヤングジャンプ連続
						  call ("Proc_TonaJumpNext")
   ;============================================
					Case $EndMode = $EM_BOOKWALKER
   ;============================================
					;  ■BookWalker定期購読連続
						  call ("Proc_BookwalkerNext")

   ;============================================
				case Else
				endselect
   ;============================================
	;============================================
			   endif	; 終端検出 IF END
		endif		; 終端検出動作中 IF END
		;　終端サム値シフト
		$befsum[2] = $befsum[1]
		$befsum[1] = $befsum[0]
		$befsum[0] = $ENDsum
	Wend
endfunc


;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
; メインの中身切り出しルーチン

; ページめくり（めくり終わりまでこのルーチン抜けない）
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


	; ◆初期値Aサム設定（めくり前基準サム）
	$Asum = call( "KoteiSum")
	sleep(300)						;　一応キャプチャソフトの保存動作待ち
	; ▲▽初期状態（状態A）▲▽
	call( "Proc_Action"  )		;ページめくり
    call( "Proc_ResetTimer", 2  )	; めくり完了タイムアウト用タイマーリセット

	$ExitFLG = False
	; 頁めくりループ
	while 1
		sleep(250)
		if $Asum <> call( "KoteiSum") then
			 ; ▲▽NOT初期状態（状態B）▲▽
			; Aサムと異なる＝動き始め　階層
			; ◆Bサム値初回設定（動き始めサム）
			$Bsum = call( "KoteiSum")
			call( "Proc_ResetTimer", 1  )	; めくり終わらないタイムアウト用タイマーリセット
			while 1
				sleep(300)
				; 固定背景色でのLOADINGチェック　★モードごとに最小限に切り分けるべき？
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
				   ;   Loading  中…　
				   ; ▲▽（背景色による状態B継続）もしくは（状態B’アニメーション）▲▽
					; ◆Bサム値　更新　動きを継続して確認
						$Bsum = $Csum
						$TO =0

						; LOADING検出時待ち延長）
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

						if ( $TO<>0 ) Then
						   $NextPlus = True
						Else
						   $NextPlus = False
						endif

						call( "Proc_ResetTimer", 2  )	; めくり完了タイムアウト用タイマー再リセット
						if ($TO < call( "Func_GetTimer", 1 )) Then
						   ; LOADING延長されていればループのまま
						   $ExitFLG = True
						   exitloop ;  →　ループ強制脱出終了（１）
					   endif
				Else
				   ; ▲▽（背景色は状態Bでない）かつ（状態BorB'のまま１秒動きがない）▲▽
					;　ページ遷移の正常完了とみなす。
					 if (1 < call( "Func_GetTimer", 2 )) Then
						;waittimer 分の待ち
						Sleep( $waittimer )

						$ExitFLG = True	; →　ループ脱出終了(2)
						exitloop
					 EndIf
				EndIf
			Wend

			if $ExitFLG  Then
				exitloop  ;  →ネストループ脱出終了（ALL）　(1)＆(2)
			EndIf
		Else
			; ASum（初期状態）からの動き出しを認識できない
			; タイムアウトによる脱出
			if  ($TO < call( "Func_GetTimer", 0 ) ) Then
				exitloop ;  →異常ループ脱出終了▼
			EndIf
		endif
	Wend

	call( "Proc_ResetTimer", 0  )	; ページタイムアウト用タイマーリセット
	return $Bsum
 EndFunc

 ;========================================================================
; 終端検出時動作切り替え
Func EndMode_Change()
HotKeySet("e")
Send("e")
HotKeySet("e", "EndMode_Change")
	$EndMode = $EndMode +1

	if $EM_MAX<$EndMode Then
		$EndMode = 0
	EndIf

	Select
;============================================
	Case $EndMode = $EM_HANYOU
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "【汎用】/DMM/他" )
;============================================
	Case $EndMode = $EM_DAYSCL
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "★コミックDAYS雑誌" )
	Case $EndMode = $EM_DAYSBW
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "★コミックDAYS単話" )
;============================================
	Case $EndMode = $EM_EBOOK
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "★Ebook連続（巻数+）" )
;============================================
	Case $EndMode = $EM_JUMP
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "ジャンプ本棚連続" )
;============================================
	Case $EndMode = $EM_KOMIFLO
		; 左キー　+ ページごとにカーソル操作
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "KomiFlo" )
;============================================
	Case $EndMode = $EM_GORAKU
		; 左クリック　
		$PageKind = 2
		MsgBOX( 0, "PAUSE", "ゴラクエッグ" )
;============================================
	Case $EndMode = $EM_TONARIYJ
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "(と)ヤンジャン連続" )
;============================================
	Case $EndMode = $EM_BOOKWALKER
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "★BookWalker定期購読" )
;============================================
	case Else
	endselect
EndFunc


 Func Proc_InitVar()
	;変数を ini ファイルから読み込む
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

	$DCD_ENDCOLOR[0] = call( "Func_GetParaValue", "capture.ini","DCD_ENDCOLOR1")
	$DCD_ENDCOLOR[1] = call( "Func_GetParaValue", "capture.ini","DCD_ENDCOLOR2")
	$DCD_ENDXPOS[0] = call( "Func_GetParaValue", "capture.ini","DCD_ENDXPOS1")
	$DCD_ENDXPOS[1] = call( "Func_GetParaValue", "capture.ini","DCD_ENDXPOS2")
	$DCD_ENDYPOS= call( "Func_GetParaValue", "capture.ini","DCD_ENDYPOS")

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

	$D_NOX_SW_PAGE[$XXX] = call( "Func_GetParaValue", "capture.ini","D_NOX_SW_PAGE_X")
	$D_NOX_SW_PAGE[$YYY] = call( "Func_GetParaValue", "capture.ini","D_NOX_SW_PAGE_Y")
	$D_NOX_SW_NEXT[$XXX] = call( "Func_GetParaValue", "capture.ini","D_NOX_SW_NEXT_X")
	$D_NOX_SW_NEXT[$YYY] = call( "Func_GetParaValue", "capture.ini","D_NOX_SW_NEXT_Y")

	$DCD_FSCREEN[$XXX] = call( "Func_GetParaValue", "capture.ini","DCD_FSCREEN_X")
	$DCD_FSCREEN[$YYY] = call( "Func_GetParaValue", "capture.ini","DCD_FSCREEN_Y")

	$DBW_NEXT_POS[$XXX] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_POS_X")
	$DBW_NEXT_POS[$YYY] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_POS_Y")
	$DBW_NEXT_COL[0] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_COL1")
	$DBW_NEXT_COL[1] = call( "Func_GetParaValue", "capture.ini","DBW_NEXT_COL2")
EndFunc

;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
; 共通ルーチン
; 小さい四角全てAndで判定
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

; 固定エリアのサム値
Func KoteiSum( )
   local $Asum
   local $Bsum

   Select
   case $EndMode = $EM_KOMIFLO
	  ; Komiflo 専用Loading Animation Area
	  $Asum =  PixelChecksum( 1150,600,1400,850)
	  $Bsum =  PixelChecksum( 650,600,900,850)
	  return $Asum + $Bsum
   case Else
	  return call( "AreaSum",  $D_WIDTH/2,$D_HEIGHT/2 )
   endselect
EndFunc

;　指定位置を中心としたエリアのサム値（HALF_SIZE定義を使用）
Func AreaSum( $xx,$yy )
	return PixelChecksum( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE,$xx+$D_CHECK_HALF_SIZE ,$yy+$D_CHECK_HALF_SIZE)
EndFunc

;  背景判定(横・見開き)
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

; 指定座標の縦列のどこか(or判定)に指定色があれば　縦座標 を戻す(どこにもみつからなければ-1)
Func Func_JudgeX_Color(  $color, $xpos ,$start,$end )
   local $ypos;

   ; start-end の間で４飛び ★重いので毎ページの中で使用しない
   For $ypos = $start To $end step 4
		 if ($color = PixelGetColor ( $xpos ,$ypos )) Then
			; 検出で中断
			return $ypos;
		 endif
   Next

   return -1
endfunc

; 2色Ver.（軽量化）　中心から　1,2,4,8 ・・・で雑に判定
Func Func_JudgeX2_Color(  $color1, $color2, $xpos ,$start,$end )
   local $ypos;
   local $nn;
   $ypos=($start+$end)/2
   $nn=1

   while( ($ypos+$nn)<$end )
		 if ( _
			($color1 = PixelGetColor ( $xpos , $ypos-$nn ) ) or _
			($color2 = PixelGetColor ( $xpos ,$ypos-$nn ) ) or _
			($color1 = PixelGetColor ( $xpos ,$ypos+$nn ) ) or _
			($color2 = PixelGetColor ( $xpos ,$ypos+$nn ) )  _
			) Then
			; 検出で中断
			return $ypos;
		 endif
		 $nn=$nn*2
   Wend

   return -1
endfunc

;　終了
Func Abort()
HotKeySet("{ESC}")
Send("{ESC}")
HotKeySet("{ESC}", "Abort")
	  ; End of Program
	  MsgBOX( 0, "Exit",  $LASTUPDATE & "<Program End>" )
	  Exit
EndFunc

; S to Start/Pause
Func StartStop()
HotKeySet("s" )
Send("s")
HotKeySet("s", "StartStop")
	if $startstop=1 Then
		$startstop=0 ; STOP
		MsgBOX( 0, "STOP", "STOP(MANUAL)" )
	Else
		$startstop=1	; START
   EndIf
EndFunc

;  W to 待ち時間変更
Func WaitTime_Change()
HotKeySet("w" )
Send("w")
HotKeySet("w", "WaitTime_Change")
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

;=====================================================
;　ページめくりアクション
Func Proc_Action()
	Select
	Case $PageKind = 1	; NOX+サンデーうぇぶりクリック　
		MouseClick( "left",$D_NOX_SW_PAGE[$XXX],$D_NOX_SW_PAGE[$YYY],1 )
	Case $PageKind = 2	; 左クリック
		MouseClick( "left",$D_L_CLICK[$XXX],$D_L_CLICK[$YYY],1 )
	Case else 	; 3 左キー
		Send ("{LEFT}")
	EndSelect
EndFunc


;========================================================================
;　 指定ファイル形式（下記）から指定ワードで定義されているものを取得する
; ファイル形式（テキスト）
;  ;1文字目セミコロン読み捨て
; 　空白使用しない　
;　KEYWORD=VAL 形式
;　重複等未チェック
Func Func_GetParaValue(  $filename ,$para  )
	local $fp
	local $line
	local $ret

	$fp = FileOpen($filename, 0)

	; ファイルが読み込みモードで開かれたかどうかチェック
	If $fp = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
		Exit
	EndIf

	$ret = "" ; 初期値

	;EOFに達するまで1文字づつ読み込む。
	While 1
		$line = FileReadLine($fp)
		If @error = -1 Then ExitLoop
		if 0=StringLen( $line ) Then
			; 文字なし　処理なし
		elseif ";"=Stringleft( $line,1 ) Then
			; 1文字目セミコロン読み捨て
			; 処理なし
		elseif ($para & "=") = StringLeft($Line ,  StringLen($para) +1 ) Then
			; $para と同文字数+"=" との比較で一致するか比較
			; 一致時は　=　の次の文字以降を返り値に (中身の型は不問)
			$ret = StringMid( $Line,StringLen($para) +2)
			Exitloop
		endif
	Wend

	FileClose($fp)

	return  $ret
endfunc

; 終了状態の画面から脱出を検出 ' 値が変わるまで脱出しない
Func EscapeNotEqual(  $Asum ,  $Xpos, $YPos  )
	local $NewSum

	while 1
		$NewSum = call( "AreaSum", $Xpos,$YPos )
		if $Asum <> $NewSum Then
			exitloop
		endif
	wend
EndFunc

;　指定エリアの描画(サム値)が1秒変化なくなるまで待ち
Func EscapeEqualSec(   $Xpos, $YPos , $SecTimer  )
	local $TimerCt
	local $Timermax
	local $Asum

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
				; 異なったらリセット
				$TimerCt = 0
				$Asum = call( "AreaSum", $Xpos,$YPos )
		EndIf
	wend
EndFunc


;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
; 各誌用ルーチン

 ;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
; 次号遷移

; 　■ebookJapan次号遷移
Func Proc_ebookJapanNext()
	  ;EbookSpecial　Ebookの特集対応
	  local $CenterSum

	  ;　現在（終端）の中央部サム値保存
	  $CenterSum = call( "KoteiSum")

	  ; 指定巻数だけ実行
	  $Ebook_CT = $Ebook_CT - 1
	  if (  0<$Ebook_CT ) Then
			; 次巻クリック
			call( "Proc_ebookNextBook" )
			; 次巻Load待ち '
			call( "EscapeNotEqual", $CenterSum ,  $D_WIDTH/2 ,$D_HEIGHT/2  )
			call( "EscapeEqualSec", $D_WIDTH/2 ,$D_HEIGHT/2  ,5)

			; 動きが止まって待ち
			Sleep (4000)
			; 表紙状態：開始
			MouseClick("Left")	 ; クリックでバーが出る
			Sleep (1000)
			MouseClick("Left") ; クリックでバーを消す
			Sleep (5000)
	  Else
		 ; 指定巻数終了
		  MsgBOX( 0, "PAUSE", "EB Auto End Detect" )
		  $startstop=0
	  endif
endfunc

; ebookJapan次巻の遷移（ボタン位置が微妙に固定されないので色で周囲を探す）
Func Proc_ebookNextBook()
	local $distance =0;

	while 1
	  ;　下
	   MouseMove($DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]+$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]+$distance,$DEB_COLOR) Then
				; 次巻読み込み「次の巻」クリック　
				MouseClick( "left",$DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]+$distance,1 )
				exitloop
	 endif
	   MouseMove($DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]+$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]+10, $DEB_NEXT[$YYY]+$distance,$DEB_COLOR) Then
				; 次巻読み込み「次の巻」クリック　
				MouseClick( "left",$DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]+$distance,1 )
				exitloop
	 endif

	  ; 上
	   MouseMove($DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]-$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]-$distance,$DEB_COLOR) Then
				; 次巻読み込み「次の巻」クリック　
				MouseClick( "left",$DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]-$distance,1 )
				exitloop
	 endif
	   MouseMove($DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]-$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]+10, $DEB_NEXT[$YYY]-$distance,$DEB_COLOR) Then
				; 次巻読み込み「次の巻」クリック　
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

; + t o EBOOK 処理巻数
Func ebook_ct_plus()
HotKeySet("{+}")
Send("{+}")
HotKeySet("{+}", "ebook_ct_plus")
	if $EndMode=$EM_EBOOK Then
	  $Ebook_CT = $Ebook_CT + 1
	  MsgBOX( 0, "BOOKS", $Ebook_CT )
	EndIf
 EndFunc


; 　■ジャンププラス次号遷移
Func Proc_JumpPlusNext()
	   local $ASum

		;　終了状態の中央部サム値保存
		$Asum = call( "KoteiSum")

		; 次号　（クリック）
		MouseClick( "left",$JP_NEXT_X,$JP_NEXT_Y,1 )

		; 終了状態の画面から脱出を検出 '動きが止まっても5秒待ち
		call( "EscapeNotEqual", $Asum ,  $D_WIDTH /2, $D_HEIGHT/2  )
		call( "EscapeEqualSec", $D_WIDTH /2, $D_HEIGHT/2  ,5)

		; 次本ロード待ち( ジャンプの初期ロード待ちはアニメじゃなくプログレスバーであり、１秒程度は止まることもあるので組合わせて確認)
		call( "EscapeNotEqual", $Asum ,  $D_WIDTH /2, $D_HEIGHT/2 )
		while 1
			call( "EscapeEqualSec", $D_WIDTH /2, $D_HEIGHT/2,1 )
			if  False =call( "JumpPlusLoading", $D_WIDTH /2, $D_HEIGHT/2 ) Then
				exitloop
			endif
		wend
		; Load 完了

		;インデックス表示クリック（中央下）
		MouseClick( "left",$D_JP_INDEX[$XXX],$D_JP_INDEX[$YYY],1 )
		;待ち(5sec)
		sleep(5000 )
		;インデックス先頭戻りクリック（下A）
		MouseClick( "left",$D_JP_RESET[$XXX],$D_JP_RESET[$YYY],1 )
		;待ち(2sec)
		sleep(2000 )
		;インデックス先頭表示クリック（右下B)
		MouseClick( "left",$D_JP_TOPINDEX[$XXX],$D_JP_TOPINDEX[$YYY],1 )
		;待ち(5sec)
		sleep(5000 )
		;表紙に戻る（右？）キー　×(5) ？
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")

		;終了(本ルートへ戻り)
		;（表紙画像出たあともプログレスバー出ている＋画面下インデックス消去を待つのでかなり余裕を見た待ち時間。）
		sleep(15000 )

		; ◆表紙状態：開始
endfunc

; 　■コミックDAYS次号遷移
; 終端を検出すればtrue ）
Func Proc_DaysNext()
   if  ( _
		 (-1 <> call( "Func_JudgeX2_Color", $DCD_ENDCOLOR[0], $DCD_ENDCOLOR[1], $DCD_ENDXPOS[0],$DCD_ENDYPOS-20 ,$DCD_ENDYPOS+20 ))  Or _
		 (-1 <> call( "Func_JudgeX2_Color", $DCD_ENDCOLOR[0], $DCD_ENDCOLOR[1], $DCD_ENDXPOS[1] ,$DCD_ENDYPOS-20 ,$DCD_ENDYPOS+20 ))  _
		 ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			; 追加キャプチャ
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

;   ■となりのヤングジャンプ次話遷移
Func Proc_TonaJumpNext()
   ;  次の話クリック
   MouseClick( "left",$D_YJ_NEXT[$XXX],$D_YJ_NEXT[$YYY],1 )
   sleep(5000)

   ;  リセットされるので全画面クリック
   MouseClick( "left",$D_YJ_FULLSCREEN[$XXX],$D_YJ_FULLSCREEN[$YYY],1 )
   sleep(2000)
endfunc

;   ■Bookwalker次話遷移
Func Proc_BookwalkerNext()
	  local $result[2]
	  ;  bookwalke のNEXTボタン検索
	  $result[0] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[0] , $DBW_NEXT_POS[$XXX],100,1300 )
	  $result[1] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[1] , $DBW_NEXT_POS[$XXX],100,1300 )
	   if  ((-1 <> $result[0] ) Or  (-1 <> $result[1] )) Then
			 if  (-1 <> $result[0])  Then
			  MouseClick( "left",$DBW_NEXT_POS[$XXX],$result[0]+5,1 )
			  else
			  MouseClick( "left",$DBW_NEXT_POS[$XXX],$result[1]+5,1 )
			  endif
			  ; Load待ち＋消える待ち
			  sleep(13000)
	  Else
			 MsgBOX( 0, "PAUSE", "BW Auto End Detect" )
			 $startstop=0
	  endif
endfunc


 ;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
; LOADING判定

; ジャンププラスのLoading中判定（背景色による） 左＆右の２点の Or 判定（どちかが残れば）　LOADING =True
; 一度
Func JumpPlusLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_JUMPPLUS_BACKCOLOR,$xx,$yy ) ) Then
;SoundPlay(@ScriptDir  & "\bird.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; となりのヤングジャンプのLoading中判定（背景色による） 左＆右の２点の Or 判定（どちかが残れば）　LOADING =True
Func ToYoungJumpLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_YOUNGJUMP_BACKCOLOR,$xx,$yy ) ) Then
;SoundPlay(@ScriptDir  & "\carpass.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; ヤングジャンプ定期のLoading中判定（背景色による） 左＆右の２点の Or 判定（どちかが残れば）　LOADING =True
Func YoungJumpTeikiLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_YOUNGJUMP_TEIKI_BACKCOLOR,$xx,$yy ) ) Then
;SoundPlay(@ScriptDir  & "\dog2.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; コミックDAYSのLoading中判定（背景色による） 左＆右の２点 Or 判定（どちかが残れば）　LOADING =True
Func ComicDaysLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_CDAYS_BACKCOLOR,$xx,$yy ) ) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

; コミックDAYSのページ内容が白黒(True)でない（False）
; 判定エリア＝左右　対角線
Func   DaysBackColor( )
   local $xx , $yy
   local $startX
   local $startY , $endY
   local $color

   $startX = $DCD_ENDXPOS[0] - 200
   $startY = $DCD_ENDYPOS - 200
   $endY = $DCD_ENDYPOS + 200

   $xx = $startX
   For $yy = $startY To $endY step 10
		 $color = _ColorGetRGB(PixelGetColor ( $xx ,$yy ))
		 if ( $color[0]<>$color[1] ) or ($color[0]<>$color[2]) Then
			return False
		 endif
		 $xx = $xx + 10
   Next

   $startX = $DCD_ENDXPOS[1] - 200
   $startY = $DCD_ENDYPOS - 200
   $endY = $DCD_ENDYPOS + 200

   $xx = $startX
   For $yy = $startY To $endY step 10
		 $color = _ColorGetRGB(PixelGetColor ( $xx ,$yy ))
		 if ( $color[0]<>$color[1] ) or ($color[0]<>$color[2]) Then
			return False
		 endif
		 $xx = $xx + 10
   Next

   return True
EndFunc

; BookWalkerのLoading中判定（背景色による） 左＆右の２点 Or 判定（どちかが残れば）　LOADING >0
Func BookWalkerLoading( $xx,$yy )
   if  (( True = call( "LoadingBackCheck",$D_BW_BACKCOLOR[0],$xx,$yy ))  Or _
	  ( True = call( "LoadingBackCheck",$D_BW_BACKCOLOR[1],$xx,$yy )) ) Then
;SoundPlay(@ScriptDir  & "\cat2.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; ebookのLoading中判定（背景色による） 左＆右の２点 Or 判定（どちかが残れば）　LOADING >0
; 中心点
Func EbookJapanLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_EB_BACKCOLOR, $xx,$yy )) Then
;SoundPlay(@ScriptDir  & "\cat1.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc


 ;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲
;▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲



