; Auto BookMekuri & capture script
AutoItSetOption("MustDeclareVars", 1)

; 現状キャプチャ割当キー[9]


; ◆◆現行の各サイト対応状況
; Jump+ 単行本単巻（ストリーミング）　【汎用】で対応
; Junp+／ヤンジャン　【汎用】で対応。トリミング側を調整
; DAYS　【汎用】で対応。トリミング側を調整。背景色検知によるめくり遅れに対応
; Ebook 単巻（ストリーミング）　【汎用】で対応
; DMM 単巻（ストリーミング）　【汎用】で対応
;ゴラクエッグ　（ページクリック位置調整）
;Komiflo（ストリーミング）    毎ページ遷移後マウスアクション の組み合わせ。
; となりのYJ連続話対応

; ◆単行本連続実施
; Ebook 連続（ストリーミング）　専用を作成 　※全ての終端を検出していないので終了後自動で停止しない

; ◆書架連続実施
; Jump+ 雑誌本棚一括（ストリーミング）　本棚対応実装　各書籍初期表示ページを表紙に
; Jump+ 終端で次の号に移動できるようになったのでVer2として対応
; Ebook 本棚一括（アプリ）　専用で対応　各書籍ダウンロード済みで初期表示ページを表紙に

; ◆未確認・未対応
; Kindle PCアプリ　単巻（ダウンロード済み）対応★★　（汎用処理のまま対応できるか確認）
; Kindle PCアプリ　連続（ダウンロード済み）対応★★　（必要性薄い？）
; DMM PCアプリ　単巻（ダウンロード済み）対応　（ストリーミングでの動作をしているので対応しない）
; ebooks PCアプリ　キャプチャ不可。ブラウザで対応。
; 動作未確認サイト　の確認★★

; ◆現行ショートカットまとめ
;　「ESC」終了

; S:　Start/Stop Toggle
; E: モード変更(ページ遷移方法も同時に変更)　Normal(Ebooks/Jump+ 他)[Z]->Ebooks(連続)[Z]->ジャンプ(一括)[Z]->Ebooks(一括)[Z]->Komiflo[X]　

; ◆遷移方法のみ変更
; Q:左上クリック
; A:左クリック
; Z:左キー(default)　通常はこれでいける　
; X:左キー＋カーソル一定移動（ウィンドウ消し） Komiflo対策

; W: ページ送り待ち時間変更　7sec(default)/14sec

; 設定値保存ファイル　同フォルダの　"setting.ini"

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
; E to EndMode Change
HotKeySet("E", "EndMode_Change")

; Press 9 to capture
Const $D_CAPTURE_KEY =  "9"

; 配列定数(Conｓｔ)
Const $XXX  =  0
Const $YYY  =  1

Const $UUU  =  0
Const $DDD =  1
Const $LLL =  2
Const $RRR  =  3

;===============================

; ページめくりクリック位置（左上・左）
global $D_UL_CLICK[2]
global $D_L_CLICK[2]

; ページめくり遷移確認領域
global $D_CHECK_CENTER[2]
global $D_CHECK_HALF_SIZE

; ジャンププラスのLOADING背景グレー
global $D_JUMPPLUS_BACKCOLOR
global $D_CDAYS_BACKCOLOR

; 内部タイマー用変数（最大10）
global $Timer[10]

; control flg UpLeft:1 Left:2 KeyLeft:3 (default)  KeyLeft＆CuursorMove:4
global $PageKind = 3

; control flg Stop:0(default) running:1
global $startstop = 0

; control flg 0 (default):Stop 1: EbookSpecial 2: jump BookList 3 Ebooks BookList
global $EndMode = 0

; Wait Timer Counter
global $D_WAITTIMER_NORMAL
global $D_WAITTIMER_LONG
global $waittimer


; ジャンププラス設定
;=================================================
; 終了後にクリックして次の号を読む座標
global $D_JUMPPLUS_NEXT[2]

;=================================================
;EBOOK アプリ設定（横一列のみ）
global $DEB_SHELF[3] 	;　Y-開始-終了X位置
global $DEB_SHELF_NUM 	;　開始＾終了間冊数

;　終端後に本棚に戻るクリック位置
global $D_EBOOK_BS_CLOSE[2]

;　表示モードメニュークリック位置
global $D_EBOOK_BS_MODEMENU[2]

;　表示モード単ページクリック位置
global $D_EBOOK_BS_MODESINGLE[2]

;=================================================
;となりのヤングジャンプ
global $D_YJ_NEXT[2]
global $D_YJ_FULLSCREEN[2]

;=================================================
; 次番号保存変数　次に開く残冊数（左上が最終位置）　（現状ジャンププラス書架専用）
global $NEXTPOS

; 開始→終了書籍番号指定　左から何番目（次）から左から何番目（最終）まで　（現状eBookJapan書架専用）
global $STARTPOS
global $ENDPOS

;=================================================

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
   local $MoveCt
   local $bp[2]
   local $ebnext

   $befsum[0]  = 0
   $befsum[1]  = 1
   $befsum[2]  = 2

	; 変数初期化
	call ( "Proc_InitVar" )
	$waittimer =  $D_WAITTIMER_NORMAL
	$ebnext = $STARTPOS

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
				 ; キャプチャ前に中央から一旦マウスを動かす(komifloの表示消去対策)
				 mousemove ( 700 ,1260 )
				 mousemove ( 700 ,960 )
				 mousemove ( 700 ,1260 )
				 sleep ( 500 )
			endif

			; キャプチャキー押下
			Send ($D_CAPTURE_KEY)
			; ◆Aサム値設定（めくり前基準サム）
			$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
			sleep(300)						;　一応キャプチャソフトの保存動作待ち
			call( "Proc_Action"  )		;ページめくり
			call( "Proc_ResetTimer", 0  )	; タイムアウト用タイマーリセット

			; 頁めくりループ
			$LoopFlg = False
			while 1
				sleep(100)
				if $Asum <> call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ) then
					; Aサムと異なる＝動き始め　階層
					; ◆Bサム値初回設定（動き始めサム）
					$Bsum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
					$FSsum[0] = call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]+500 )
					$FSsum[1] = call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]-500 )
					$FSsum[2] = call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]+500 )
					$FSsum[3] = call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]-500 )
					$LoopCt=0
					$MoveCt=0
					while 1
						sleep(100)
						if  ( $Bsum <> call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY]  ) ) or _
						   ( $FSsum[0] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]+500 )   ) or _
						   ( $FSsum[1] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]-500 )   ) or _
						   ( $FSsum[2] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]+500 )   ) or _
						   ( $FSsum[3] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]-500 )   ) or _
						   ( True=call( "JumpPlusLoading", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ) ) or _
						   ( True=call( "ComicDaysLoading", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )  ) Then
							; 動きがあったもしくは、特定のグレー　　→　遷移未完了
							; ◆Bサム値最新設定（動き始めと異なる最新のサム）
							  $Bsum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
							  $FSsum[0] = call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]+500 )
							  $FSsum[1] = call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]-500 )
							  $FSsum[2] = call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]+500 )
							  $FSsum[3] = call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]-500 )
							$LoopCt=0
							$MoveCt=$MoveCt+1
							if ($MoveCt>100) Then
								; 10秒以上動き続けていたら　広告アニメ等を検出している可能性が高いのでループ脱出する。
								$LoopFLG = True
								exitloop
							endif
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
					; 脱出（ニ段）　一段から連続して脱出
					if $LoopFLG  then
						exitloop
					endif
				Else
					; まだ動き始めていない（動き出しを認識できない）
					; １0秒タイムアウトによる脱出
					if  (9 < call( "Func_GetTimer", 0 ) ) Then
						exitloop
					EndIf
				endif
			Wend

	;============================================
	;============================================
	;============================================
	;============================================
		; 自動停止判定
		if $startstop=1 then 	; 動作停止中は停止判定必要ない
			; 自動停止判定 a->b->c-.>d    a=c &  b=d
			if $Bsum = $befsum[1] and  $befsum[0] = $befsum[2]  Then
				; 終端検出初期化 バッファ毎に異なる仮データ入れておく
				$befsum[0]  = 9
				$befsum[1]  = 99
				$befsum[2]  = 999

				Select
	;============================================
					Case $EndMode = 1
	;============================================
				;EbookSpecial　Ebookの特集対応

				;　終了状態の中央部サム値保存
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

				; 次巻読み込み「次の巻」クリック
				MouseClick( "left",713,1457,1 )

				; 終了状態の画面から脱出を検出 '動きが止まっても5秒待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "EscapeEqualSec", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ,5)

				; 広告消しクリックと5sec待ち　（これはクリック後に通信環境による遅延はないので固定5secで良い）
				;MouseClick( "left",915,2394,1 )
				Sleep (5000)

				; ◆表紙状態：開始

   ;============================================
					Case $EndMode = 2
   ;============================================
					; Jump Shelf　
				; 次号クリック

				;　終了状態の中央部サム値保存
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

				; 次巻読み込み「次の巻」クリック
				MouseClick( "left",$D_JUMPPLUS_NEXT[$XXX],$D_JUMPPLUS_NEXT[$YYY],1 )

				; 終了状態の画面から脱出を検出 '動きが止まっても5秒待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "EscapeEqualSec", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ,5)

				; 次本ロード待ち( ジャンプの初期ロード待ちはアニメじゃなくプログレスバーであり、１秒程度は止まることもあるので組合わせて確認)
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
			   while 1
				  call( "EscapeEqualSec", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY],1 )
				  if  False =call( "JumpPlusLoading", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ) Then
					 exitloop
				  endif
			   wend
			   ; Load 完了後の下部メニュー消去待ち
			   ;（表紙画像出たあともプログレスバー出ている＋画面下インデックス消去を待つのでかなり余裕を見た待ち時間。）
			   sleep(15000 )

				; ◆表紙状態：開始

   ;============================================
				Case $EndMode = 3
   ;============================================
					; Ebook アプリ書棚一括(ストリーミングで無くダウンロード済みにしておく)

				; 「閉じる」前サム値取得
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				; 「閉じる」クリック
				MouseClick( "left",$D_EBOOK_BS_CLOSE[$XXX],$D_EBOOK_BS_CLOSE[$YYY],1 )
				; 本棚に戻る待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "EscapeEqualSec", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ,1)

				; 次本Open処理　（オープン位置確認ダイアログ出ずに即時表紙表示される前提）
				if ($ebnext > $endpos ) Then
				   MsgBOX( 0, "PAUSE", "Ebook Shelf End Detect" )
				   $startstop=0
			   else
				   $bp[0] = call("Func_GetEBShelfPos",$ebnext)
				   MouseClick( "left",$bp[0],$DEB_SHELF[1] ,2 )		; 次の本ダブルクリック
				   $ebnext = $ebnext +1
				endif
				; 次本Open待ち（DownLoadは発生しないのでイレギュラーな長時間待ちは発生しないはず）
				call( "EscapeEqualSec", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ,2)

				; 毎回リセットされるので単ページ表示モードへ切り替え
				MouseClick( "left",$D_EBOOK_BS_MODEMENU[$XXX],$D_EBOOK_BS_MODEMENU[$YYY],1 )
				sleep(200)
				MouseClick( "left",$D_EBOOK_BS_MODESINGLE[$XXX],$D_EBOOK_BS_MODESINGLE[$YYY],1 )
				sleep(200)

				; ◆表紙状態：開始

   ;============================================
				Case $EndMode = 6
   ;============================================
			   ;  となりのヤングジャンプ

			   ;  次の話クリック
				MouseClick( "left",$D_YJ_NEXT[$XXX],$D_YJ_NEXT[$YYY],1 )
				sleep(5000)

			   ;  リセットされるので全画面クリック
				MouseClick( "left",$D_YJ_FULLSCREEN[$XXX],$D_YJ_FULLSCREEN[$YYY],1 )
				sleep(2000)

				; ◆表紙状態：開始

   ;============================================
				case Else
   ;============================================
					; Default/ EndMode = 0(jump/ebooks) or 4(komiflo) or 5(goraku)
				MsgBOX( 0, "PAUSE", "Auto End Detect" )
				$startstop=0
				endselect
	;============================================
	;============================================
			endif
		endif
		;　バッファサム値位置シフト
		$befsum[2] = $befsum[1]
		$befsum[1] = $befsum[0]
		$befsum[0] = $Bsum
	Wend
endfunc


Func Proc_InitVar()
	;変数を ini ファイルから読み込む
	$NEXTPOS = call( "Func_GetParaValue", "setting.ini","D_NEXTPOS")

	$D_UL_CLICK[$XXX] = call( "Func_GetParaValue", "setting.ini","D_UL_CLICK_X")
	$D_UL_CLICK[$YYY]= call( "Func_GetParaValue", "setting.ini","D_UL_CLICK_Y")
	$D_L_CLICK[$XXX] = call( "Func_GetParaValue", "setting.ini","D_L_CLICK_X")
	$D_L_CLICK[$YYY] = call( "Func_GetParaValue", "setting.ini","D_L_CLICK_Y")

	$D_CHECK_CENTER[$XXX] = call( "Func_GetParaValue", "setting.ini","D_CHECK_CENTER_X")
	$D_CHECK_CENTER[$YYY] = call( "Func_GetParaValue", "setting.ini","D_CHECK_CENTER_Y")

	$D_CHECK_HALF_SIZE = call( "Func_GetParaValue", "setting.ini","D_CHECK_HALF_SIZE")

	$D_JUMPPLUS_BACKCOLOR = call( "Func_GetParaValue", "setting.ini","D_JUMPPLUS_BACKCOLOR")
	$D_CDAYS_BACKCOLOR = call( "Func_GetParaValue", "setting.ini","D_CDAYS_BACKCOLOR")

	$D_WAITTIMER_NORMAL = call( "Func_GetParaValue", "setting.ini","D_WAITTIMER_NORMAL")
	$D_WAITTIMER_LONG = call( "Func_GetParaValue", "setting.ini","D_WAITTIMER_LONG")

	$D_JUMPPLUS_NEXT[$XXX] = call( "Func_GetParaValue", "setting.ini","D_JUMPPLUS_NEXT_X")
	$D_JUMPPLUS_NEXT[$YYY] = call( "Func_GetParaValue", "setting.ini","D_JUMPPLUS_NEXT_Y")

	$DEB_SHELF[0] = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_Y")
	$DEB_SHELF[1] = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_S")
	$DEB_SHELF[2] = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_E")
	$DEB_SHELF_NUM = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_NUM")

	$D_EBOOK_BS_CLOSE[$XXX] = call( "Func_GetParaValue", "setting.ini","DEB_CLOSE_X")
	$D_EBOOK_BS_CLOSE[$YYY] = call( "Func_GetParaValue", "setting.ini","DEB_CLOSE_Y")
	$D_EBOOK_BS_MODEMENU[$XXX] = call( "Func_GetParaValue", "setting.ini","DEB_DMENU_X")
	$D_EBOOK_BS_MODEMENU[$YYY] = call( "Func_GetParaValue", "setting.ini","DEB_DMENU_Y")
	$D_EBOOK_BS_MODESINGLE[$XXX] = call( "Func_GetParaValue", "setting.ini","DEB_DSINGLE_X")
	$D_EBOOK_BS_MODESINGLE[$YYY] = call( "Func_GetParaValue", "setting.ini","DEB_DSINGLE_Y")


	$STARTPOS = call( "Func_GetParaValue", "setting.ini","D_STARTPOS")
	$ENDPOS = call( "Func_GetParaValue", "setting.ini","D_ENDPOS")

	$D_YJ_NEXT[$XXX] = call( "Func_GetParaValue", "setting.ini","DYJ_NEXT_X")
	$D_YJ_NEXT[$YYY] = call( "Func_GetParaValue", "setting.ini","DYJ_NEXT_Y")
	$D_YJ_FULLSCREEN[$XXX] = call( "Func_GetParaValue", "setting.ini","DYJ_FULLSCR_X")
	$D_YJ_FULLSCREEN[$YYY] = call( "Func_GetParaValue", "setting.ini","DYJ_FULLSCR_Y")
;	$AAA = call( "Func_GetParaValue", "setting.ini","AAA")
EndFunc

;　指定位置を中心としたエリアのサム値
Func AreaSum( $xx,$yy )
	return PixelChecksum( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE,$xx+$D_CHECK_HALF_SIZE ,$yy+$D_CHECK_HALF_SIZE)
EndFunc

; ジャンププラスのLoading中判定（背景色による） 左上＆右下の２点 And 判定　LOADING =True
Func JumpPlusLoading( $xx,$yy )
   if  ( ( $D_JUMPPLUS_BACKCOLOR = PixelGetColor ( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE ) ) and  _
   ($D_JUMPPLUS_BACKCOLOR = PixelGetColor ( $xx+$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE) ) ) Then
	  return True
   Else
	  return False
   endif
EndFunc

; コミックDAYSのLoading中判定（背景色による） 左上＆右下の２点 And 判定　LOADING =True
Func ComicDaysLoading( $xx,$yy )
   if  ( ( $D_CDAYS_BACKCOLOR = PixelGetColor ( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE ) ) and  _
   ($D_CDAYS_BACKCOLOR = PixelGetColor ( $xx+$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE) ) ) Then
	  return True
   Else
	  return False
   endif
EndFunc

;=====================================================
;　ページめくりアクション
Func Proc_Action()
	Select
	Case $PageKind = 1	; 左上クリック
		MouseClick( "left",$D_UL_CLICK[$XXX],$D_UL_CLICK[$YYY],1 )
	Case $PageKind = 2	; 左クリック
		MouseClick( "left",$D_L_CLICK[$XXX],$D_L_CLICK[$YYY],1 )
	Case else 	; 3/4 左キー
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

;  W to 待ち時間変更
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
; 終端検出時動作切り替え　0-5
Func EndMode_Change()
	$EndMode = $EndMode +1

	if 6<$EndMode Then
		$EndMode = 0
	EndIf

	Select
;============================================
	Case $EndMode = 1
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "Ebook の特集一括" )
;============================================
	Case $EndMode = 2
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "Jump 雑誌一括" )
;============================================
	Case $EndMode = 3
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "Ebook 雑誌一括" )
;============================================
	Case $EndMode = 4
		; 左キー　+ ページごとにカーソル操作
		$PageKind = 4
		MsgBOX( 0, "PAUSE", "KomiFlo　雑誌単位" )
;============================================
	Case $EndMode = 5
		; 左クリック　
		$PageKind = 2
		MsgBOX( 0, "PAUSE", "ゴラクエッグ(クリックめくり・位置特殊)" )
;============================================
	Case $EndMode = 6
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "となりのヤングジャンプ単話連続" )
;============================================
	case Else
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "汎用終了検出停止（Jump+/DAYS/Ebook/DMM）" )
	endselect
EndFunc

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

; Ebook 書棚用  N番目の１i次元本棚座標（左からNカウント）を返す　実際の書架並びは左（古）→右（最新）になので呼び出し方に注意　
Func Func_GetEBShelfPos(  $nn  )
	local $r ; 列
	local $ret
	local $omomi

	$r = Mod ($nn , $DEB_SHELF_NUM) -1  ; 列=列数の剰余 -1
	if $r<0 then $r=$r+$DEB_SHELF_NUM

	; 列　X 座標　
	$omomi = $r / ($DEB_SHELF_NUM-1)
	$ret  =   ($DEB_SHELF[2]*(1-$omomi) )+($DEB_SHELF[1]*($omomi) )

	return $ret
endfunc

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

