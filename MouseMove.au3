; Mouse Move App
AutoItSetOption("MustDeclareVars", 1)
#include <Misc.au3>

;　履歴 YMD
; Ver1.00 20/08/19

;============================================
; 取説的な仕様などメモ
;============================================
; ◆現行ショートカットまとめ
;　「F12」終了

; S:　S
; F12 to Exit Program
HotKeySet("{F12}", "Abort")

;===========================================================
; main Function
;===========================================================

main()

;===========================================================

func main()

   ; 二重起動の抑制
   If _Singleton("MMV", 1) = 0 Then
	   Exit
   EndIf

   ; 大ループ（永遠）
   while 1
	  MouseMove( 100, 100 )
	  Sleep(60000)
	  MouseMove( 200, 100 )
	  Sleep(60000)
   WEnd
EndFunc


;　終了
Func Abort()
	  ; End of Program
	  Exit
EndFunc

