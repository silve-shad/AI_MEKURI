; Auto Mekuri & capture script
AutoItSetOption("MustDeclareVars", 1)

; 現状キャプチャ割当キー[9]

; 現行の各サイト対応状況
; Jump+ 単巻（ストリーミング）　汎用で対応
; Ebook 単巻（ストリーミング）　汎用で対応
; DMM 単巻（ストリーミング）　汎用で対応

; Jump+ 本棚一括（ストリーミング）　本棚対応実装　各書籍表紙に戻しておく
; Ebook 連続（ストリーミング）　専用で対応
;Komiflo（ストリーミング） 汎用＋毎ページ遷移後マウスアクションを組み合わせ。
; Ebook 本棚一括（アプリ）　　専用で対応★★（予定）　各書籍ダウンロード済みで表紙に戻しておく

; Kindle PCアプリ　対応未定★★（連続しなければ現行の処理で対応できる可能性）
;ゴラクエッグ　（汎用＋ページクリック位置調整）でモード作成　★
;ジャンププラス／ヤンジャン　汎用で対応。トリミングを調整　★

; 現行ショートカットまとめ
;　「ESC」終了

; S:　Start/Stop Toggle

; E: モード変更(ページ遷移方法も同時に変更)　Normal(Ebooks/Jump+ 他)[Z]->Ebooks(連続)[Z]->ジャンプ(一括)[Z]->Ebooks(一括)[Z]->Komiflo[X]　

; 遷移方法のみ変更
; Q:左上クリック
; A:左クリック
; Z:左キー(default)　通常はこれでいける　
; X:左キー＋カーソル一定移動（ウィンドウ消し） Komiflo対策

; W: ページ送り待ち時間変更　7sec(default)/14sec

; 初期値保存ファイル　"setting.ini"

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

; 配列定数
Const $XXX  =  0
Const $YYY  =  1

Const $UUU  =  0
Const $DDD =  1
Const $LLL =  2
Const $RRR  =  3

;===============================

; クリック位置（左上・左）
global $D_UL_CLICK[2]
global $D_L_CLICK[2]

; ページめくり遷移確認領域
global $D_CHECK_CENTER[2]

global $D_CHECK_HALF_SIZE

; ジャンププラスのLOADING背景グレー
global $D_JUMPPLUS_BACKCOLOR

; 内部タイマー用変数（最大10）
global $Timer[10]

; control flg UpLeft:1 Left:2 KeyLeft:3 (default)  KeyLeft;Move:4
global $PageKind = 3

; control flg Stop:0(default) running:1
global $startstop = 0

; control flg 0 (default):Stop 1: EbookSpecial 2: jump BookList 3 Ebooks BookList
global $EndMode = 0

; Wait Timer Counter
global $D_WAITTIMER_NORMAL
global $D_WAITTIMER_LONG
global $waittimer


; 本棚の上下左右座標と該当する行数、列数 (書店毎に設定が必要)
;=================================================
; ジャンププラス設定　 1 to 63
global $D_SHELF[4]
global $D_COL_SHELF_NUM
global $D_ROW_SHELF_NUM

;　終端検出後にクリックしなければいけない座標A
global $D_CANSEL[2]

;　終端検出後にクリックしなければいけない座標B
global $D_MODOL[2]

;=================================================
;EBOOK アプリ設定（横一列のみ）
global $DEB_SHELF[3] 	;　Y-開始-終了X位置
global $DEB_SHELF_NUM 	;　開始＾終了間冊数

;　★★　終端後に本棚に戻るクリック位置
global $DEB_RET[2]

;=================================================
; 次番号保存変数　次に開く残冊数
global $NEXTPOS
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
   local $bp[2]

   $befsum[0]  = 0
   $befsum[1]  = 1
   $befsum[2]  = 2

	; 変数を ini ファイルから読み込む
	$NEXTPOS = call( "Func_GetParaValue", "setting.ini","D_NEXTPOS") 

	$D_UL_CLICK[$XXX] = call( "Func_GetParaValue", "setting.ini","D_UL_CLICK_X") 
	$D_UL_CLICK[$YYY]= call( "Func_GetParaValue", "setting.ini","D_UL_CLICK_Y") 
	$D_L_CLICK[$XXX] = call( "Func_GetParaValue", "setting.ini","D_L_CLICK_X") 
	$D_L_CLICK[$YYY] = call( "Func_GetParaValue", "setting.ini","D_L_CLICK_Y") 

	$D_CHECK_CENTER[$XXX] = call( "Func_GetParaValue", "setting.ini","D_CHECK_CENTER_X") 
	$D_CHECK_CENTER[$YYY] = call( "Func_GetParaValue", "setting.ini","D_CHECK_CENTER_Y") 

	$D_CHECK_HALF_SIZE = call( "Func_GetParaValue", "setting.ini","D_CHECK_HALF_SIZE") 

	$D_JUMPPLUS_BACKCOLOR = call( "Func_GetParaValue", "setting.ini","D_JUMPPLUS_BACKCOLOR") 

	$D_WAITTIMER_NORMAL = call( "Func_GetParaValue", "setting.ini","D_WAITTIMER_NORMAL") 
	$D_WAITTIMER_LONG = call( "Func_GetParaValue", "setting.ini","D_WAITTIMER_LONG") 
	$waittimer =  $D_WAITTIMER_NORMAL

	$D_SHELF[$UUU] = call( "Func_GetParaValue", "setting.ini","D_SHELF_U") 
	$D_SHELF[$DDD] = call( "Func_GetParaValue", "setting.ini","D_SHELF_D") 
	$D_SHELF[$LLL] = call( "Func_GetParaValue", "setting.ini","D_SHELF_L") 
	$D_SHELF[$RRR] = call( "Func_GetParaValue", "setting.ini","D_SHELF_R") 
	$D_COL_SHELF_NUM = call( "Func_GetParaValue", "setting.ini","D_COL_SHELF_NUM") 
	$D_ROW_SHELF_NUM = call( "Func_GetParaValue", "setting.ini","D_ROW_SHELF_NUM") 

	$D_CANSEL[$XXX] = call( "Func_GetParaValue", "setting.ini","D_CANSEL_X") 
	$D_CANSEL[$YYY] = call( "Func_GetParaValue", "setting.ini","D_CANSEL_Y") 

	$D_MODOL[$XXX] = call( "Func_GetParaValue", "setting.ini","D_MODOL_X") 
	$D_MODOL[$YYY] = call( "Func_GetParaValue", "setting.ini","D_MODOL_Y") 

	$DEB_SHELF[0] = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_Y") 
	$DEB_SHELF[1] = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_S") 
	$DEB_SHELF[2] = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_E") 
	$DEB_SHELF_NUM = call( "Func_GetParaValue", "setting.ini","DEB_SHELF_NUM") 

	$DEB_RET[$XXX] = call( "Func_GetParaValue", "setting.ini","DEB_RET_X") 
	$DEB_RET[$YYY] = call( "Func_GetParaValue", "setting.ini","DEB_RET_Y") 

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
					while 1
						sleep(100)
						if  ( $Bsum <> call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY]  ) ) or _
						   ( $FSsum[0] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]+500 )   ) or _
						   ( $FSsum[1] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]-500 )   ) or _
						   ( $FSsum[2] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]+500 )   ) or _
						   ( $FSsum[3] <> call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]-500 )   ) or _
						   ( True=call( "JumpPlusLoading", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] ) ) Then
							; 動きがあったもしくは、特定のグレー　　→　遷移未完了
							; ◆Bサム値最新設定（動き始めと異なる最新のサム）
							  $Bsum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
							  $FSsum[0] = call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]+500 )
							  $FSsum[1] = call( "AreaSum", $D_CHECK_CENTER[$XXX]+400,$D_CHECK_CENTER[$YYY]-500 )
							  $FSsum[2] = call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]+500 )
							  $FSsum[3] = call( "AreaSum", $D_CHECK_CENTER[$XXX]-400,$D_CHECK_CENTER[$YYY]-500 )
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
		if $startstop=1 then 	; 動作停止中は自動停止しない
			; 自動停止判定 a->b->c-.>d    a=c &  b=d
			if $Bsum = $befsum[1] and  $befsum[0] = $befsum[2]  Then
				; 終端検出初期化 異なるデータならなんでも
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
				MouseClick( "left",937,1403,1 )

				; 終了状態の画面から脱出を検出 ' 
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "Escape1secEqual", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

				; 表紙キャプチャキー押下
				Send ($D_CAPTURE_KEY)

				; 表紙のサム値保存
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

				call( "Proc_Action"  )		;2ページ目へ遷移

				; 表紙から脱出を検出
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "Escape1secEqual", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

				; 広告消しクリックと5sec待ち　（これはクリック後に通信環境による遅延はないので固定5secで良い）
				MouseClick( "left",915,2394,1 )
				Sleep (5000)
				;　これで終了。２ページ目へのキャプチャキーは全体内の処理としておこなわれる

	;============================================
					Case $EndMode = 2
	;============================================
					; Jump Shelf　
				; キャンセル押下
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				MouseClick( "left",$D_CANSEL[$XXX],$D_CANSEL[$YYY],1 )
				; キャンセル待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "Escape1secEqual", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				; 戻る押下
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				MouseClick( "left",$D_MODOL[$XXX],$D_MODOL[$YYY],1 )
				; 戻る待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "Escape1secEqual", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				; 次本押下
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				if ($NEXTPOS<1) Then
				   MsgBOX( 0, "PAUSE", "Auto End Detect" )
				   $startstop=0
			   else
				   $bp = call("Func_GetXYShelfPos",$NEXTPOS)
				   MouseClick( "left",$bp[0],$bp[1],1 )
				   $NEXTPOS = $NEXTPOS -1
				endif

				; 次本ロード待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "Escape1secEqual", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

	;============================================
				Case $EndMode = 3
	;============================================
					; Ebook 書棚一括 

				; キャンセル前サム値取得
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				; キャンセル処理　★★位置不明
	;			MouseClick( "left",$D_CANSEL_X,$D_CANSEL_Y,1 )
				; 本棚に戻る待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "Escape1secEqual", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

				;  本棚サム値取得
				$Asum = call( "AreaSum", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				; 次本Open処理　（表紙・確認ダイアログ出ない前提）
				if ($NEXTPOS<1) Then
				   MsgBOX( 0, "PAUSE", "Auto End Detect" )
				   $startstop=0
			   else
				   $bp[0] = call("Func_GetEBShelfPos",$NEXTPOS)
				   $bp[1] = $DEB_SHELF[1]
				   MouseClick( "left",$bp[0],$bp[1],1 )
				   $NEXTPOS = $NEXTPOS -1
				endif
				; 次本Open待ち
				call( "EscapeNotEqual", $Asum ,  $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )
				call( "Escape1secEqual", $D_CHECK_CENTER[$XXX],$D_CHECK_CENTER[$YYY] )

				; 表紙の何らか余計な表示あれば消す処理が必要　★★
				

	;============================================
				case Else
	;============================================
					; Default/ (jump/ebooks/komiflo)　EndMode = 0 or 4 
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

;　指定位置を中心としたエリアのサム値
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
;　ページめくりアクション
Func Proc_Action()
	Select
	Case $PageKind = 1
		MouseClick( "left",$D_UL_CLICK[$XXX],$D_UL_CLICK[$YYY],1 )
	Case $PageKind = 2
		MouseClick( "left",$D_L_CLICK[$XXX],$D_L_CLICK[$YYY],1 )
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
; 終端検出時動作切り替え　0-3
Func EndMode_Change()
	$EndMode = $EndMode +1

	if 4<$EndMode Then
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
	case Else
		; 左キー
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "通常一冊単位（jump/Ebbok/DMM）" )
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

;========================================================================
;　 N番目の2次元本棚座標（左上からカウント）を返す　N（MAX）=　列数*行数　になる。
Func Func_GetXYShelfPos(  $nn  )
	local $c ; 行
	local $r ; 列
	local $ret[2]
	local $omomi

	$c = Int( ($nn-1) / $D_ROW_SHELF_NUM)  ; 行=列数の商
	$r = Mod ($nn , $D_ROW_SHELF_NUM) -1  ; 列=列数の剰余 -1
	if $r<0 then $r=$r+$D_ROW_SHELF_NUM

	; 列　X 座標　LR
	$omomi = $r / ($D_ROW_SHELF_NUM-1)
	$ret [0] =   ($D_SHELF[$LLL]*(1-$omomi) )+($D_SHELF[$RRR]*($omomi) )

	; 行　Y 座標　UD
	$omomi = $c / ($D_COL_SHELF_NUM-1)
	$ret [1] =   ($D_SHELF[$UUU]*(1-$omomi) )+($D_SHELF[$DDD]*($omomi) )

	return $ret
endfunc

; Ebook 書棚用
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
Func Escape1secEqual(   $Xpos, $YPos  )
	local $TimerCt
	local $Asum

	$TimerCt = 0
	$Asum = call( "AreaSum", $Xpos,$YPos )

	while 1
		sleep(100)
		if (  $Asum=call( "AreaSum", $Xpos,$YPos )  ) Then
				$TimerCt = $TimerCt  +1
				if ( $TimerCt >9 ) Then
					exitloop
				endif
		Else
				; 異なったらリセット
				$TimerCt = 0
				$Asum = call( "AreaSum", $Xpos,$YPos )
		EndIf
	wend
EndFunc

