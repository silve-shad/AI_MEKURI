; 60 秒ごとにマウスを動かし、スリープやスクリーンセーバーを防ぐ補助ツール。
AutoItSetOption("MustDeclareVars", 1)
#include <Misc.au3>

; 更新履歴: 00 20/08/19

; F12: 終了
HotKeySet("{F12}", "Abort")

main()

func main()

   ; 二重起動を防ぐ
   If _Singleton("MMV", 1) = 0 Then
	   Exit
   EndIf

   while 1
	  MouseMove( 100, 100 )
	  Sleep(60000)
	  MouseMove( 200, 100 )
	  Sleep(60000)
   WEnd
EndFunc


Func Abort()
	  Exit
EndFunc
