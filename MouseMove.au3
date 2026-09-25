; 処理の補足説明
AutoItSetOption("MustDeclareVars", 1)
#include <Misc.au3>

; 処理の補足説明
; 更新履歴: 00 20/08/19

; 処理の補足説明
; 処理の補足説明
; 処理の補足説明
; 処理の補足説明
; 処理の補足説明

; 処理の補足説明
; 処理の補足説明
HotKeySet("{F12}", "Abort")

; 処理の補足説明
; 処理の補足説明
; 処理の補足説明

main()

; 処理の補足説明

func main()

   ; 処理の補足説明
   If _Singleton("MMV", 1) = 0 Then
	   Exit
   EndIf

   ; 処理の補足説明
   while 1
	  MouseMove( 100, 100 )
	  Sleep(60000)
	  MouseMove( 200, 100 )
	  Sleep(60000)
   WEnd
EndFunc


; 処理の補足説明
Func Abort()
	  ; 処理の補足説明
	  Exit
EndFunc

