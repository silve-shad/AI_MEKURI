; Auto BookMekuri & capture script
; Auto BookMekuri & capture script
AutoItSetOption("MustDeclareVars", 1)

#include <Misc.au3>
#include <MsgBoxConstants.au3>

#include <Color.au3>



;�@���� YMD
; Ver2.00 19/08/20 ����ʂ��f�t�H���g�Ƃ�����C�Ȃ�
; Ver2.01 19/08/26 MagazineWalker �ŋH�ɔ������郍�[�h�s�Ǒ҂��ǉ�
; Ver2.02 19/12/28 DAYS�̏I�[�d�l�ύX�Ή�
; Ver2.03 20/02/06 �W�����v�{�A�������{�������Ή�
; Ver2.04 20/03/01 NOX+�����Ԃ�Ή��@�y�[�W�߂����@�@�\�̍폜
; Ver2.05 20/03/05 EBOOK �A���I�[�ł̃{�^�������͈͌�������悤�ɉ���@�ݒ�t�@�C�����̕ύX�@setting.ini ��capture.ini
; Ver2.06 20/03/16 DAYS ���f����̕��A�@�\
; Ver2.06 20/03/24 �����Ԃ�߂�����h���b�O�ɑΉ�
;  20/06/23 komiflo �I�[�Q�p�^�[���Ή�
;  20/06/25 (�o�[�W�����p�~) ; ��d�N���}�� ; DAYS �I�[�đΉ��i�g��Ń}�[�N���ړ����鎖������������
;  20/06/26 ; ��������W����Loading�w�i�F�Ή�
;  20/07/05 ; BookWalker �A���Ή�()
;  20/07/17 ; komiflo ������ ; Bookwalker ��F���������̂Ń��[�h���� ;  CTRL+Z �̒��f�I���ǉ�
;  20/07/23 ; ebpook �̘A���w���J�E���^
;  20/07/25 ;  �y���ȕs�
;  20/07/28 ;  �y���ȕs�
;  20/08/10 ;  KOMIFLO LOADING�ҋ@
;  20/08/14 ;  �y���ȕs�(komiflo�I�[)
;  20/11/13 ; Ebook �y�� BookWalker �I�[�Ē���
;  20/12/13 ; Komiflo �I�[�Q�p�^�[���Ή�
;  21/01/13 ; Komiflo �I�[�d�l�ύX
;  21/05/08 ; ebooks �����J�n�d�l�ύX
;  21/09/23 ; NOX �폜�@���ԓ���ւ��@�����������̃J�E���^�ꎞ��~
;  21/09/28 ; Ebook���������҂{�����}�Kweb�A���Ή�(�b��)
;  21/10/29 ; �w�i�F���iebook�j�̑҂����ԉ���
;  21/12/04 ; �L�[���͂��~�߂Ȃ��悤�ɏC���i�t�b�N���ɍăX���[�j ; �e��w�i�F���̑҂����Ԃ�S�ĉ������w�i�F���o���ɃA���[���炷
;  22/02/04 ; ���F�w�i���̌��o�����̂ݕύX���҂����Ԃ��ēx����
;  22/03/22  DAYS �̃{�^�����Q�F�Ή�
;  22/03/24B BW �̃{�^�����Q�F�Ή�
;  22/03/24 LOADING����̌�����
; 22/3/25 �R�[�h����
; 22/3/25 DAYS�Ɨ�
; 22/3/26 DAYS�I�[���o�͈͍ŏ���(���x�΍�)
; 22/3/26 Komiflo ��؂茟�o�𕡐��ӏ��Ɂi���蔲���m�������炷�j
; 22/3/30  �ėp�̃^�C���A�E�g����ŎO�b�҂��ǉ��@�b��̃����}�K�E�F�u�폜
; 22/9/12  ebook �w�i���菈���R��C��
; 23/3/24  DAYS �F�t�����o��҂����ԉ���/ �S��ʒ��f�����J�o�������b��폜 /  DAYSBW/COLOR����
; 23/5/10  DAYS�S��ʒ��f�������A�EDAYS�����E�����`�����E�F�u����
; 23/06/06  DAYS�̎G���ƒP�b�𓝍��E�����}�KWEB��ǉ�
; 23/11/23  ebook �̘A�������ύX
; 24/02/10  FUZ�Ή�
; 26/06/10  BookWalker�I�[�Ή�
; 26/06/14  HotKey���Ή��iALT�t���ցj/�S���N�A�`�����s�I���폜�@BookWalker�I�[�đΉ�
; 26/06/18  AI debug

Const $LASTUPDATE  =  "260618"

;============================================
; ���������d�l�Ȃǃ���
; ���\��

; ���D��x��
;  �W�����v�v���X�̃����W�����A��
; SoundFile ��`
; �قȂ�f�B�X�v���C�T�C�Y�ɑΉ�

;���s�\�ۂ�
; �����W��������w�ǘA�����{�Ή�

;============================================
; ����I�Ȏd�l�Ȃǃ���
;============================================
; �����s�V���[�g�J�b�g�܂Ƃ�
;�@�uESC�v�I��

; ALT+S:�@Start/Stop Toggle
; ALT+E: ���[�h�ύX(�y�[�W�J�ڕ��@�������ɕύX)�@
; ALT+W: �y�[�W����҂����ԕύX�@7sec(default)/14sec

; ���ݒ�l�ۑ��t�@�C���@���t�H���_�́@"capture.ini"

; �������I�[���o
;�@���� a->b->c->d �Ł@a=c & b=d

;===================================================================================
; �������s�̊e�T�C�g�Ή���(�S�ĉ������̌��J����O��Ɏd�l���X�V)
; �u���E�U�E�t����ʑz��


;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
;  ��`

; ESC to Exit Program
HotKeySet("{ESC}", "Abort")
; S to Start/Stop (Counter Reset)
HotKeySet("!s", "StartStop")

; E to EndMode Change
HotKeySet("!e", "EndMode_Change")

; W to WaitTime Change
HotKeySet("!w", "WaitTime_Change")

; D to Days Mode Change
HotKeySet("!d", "DaysMode_Change")

;+ to ebook Counter
HotKeySet("{+}", "ebook_ct_plus")

;===============================
;�@�萔�@
;===============================

; �z��萔(Con����)
Const $XXX  =  0
Const $YYY  =  1

; �W�����v�����{
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

;===============================
;�@�ϐ�(capture.ini)
;===============================
; ��ʃT�C�Y
global $D_HEIGHT
global $D_WIDTH

; Press capture �������L�[��`
global $D_CAPTURE_KEY

; �y�[�W�߂���N���b�N�ʒu�i���j
global $D_L_CLICK[2]

; �y�[�W�߂���J�ڊm�F�͒��S��ōs��
global $D_CHECK_HALF_SIZE

;===============================
; LOADING �w�i�F
; �W�����v�v���X��LOADING�w�i�F(�O���[)
global $D_JUMPPLUS_BACKCOLOR

; �i�Ɓj�����W����LOADING�w�i�F(�O���[)
global $D_YOUNGJUMP_BACKCOLOR

; �����W��������w��LOADING�w�i�F
global $D_YOUNGJUMP_TEIKI_BACKCOLOR

; �R�~�b�NDAYSLOADING�w�i�F(�O���[)
global $D_CDAYS_BACKCOLOR

; ebookJapan��LOADING�w�i�F(�O���[)
global $D_EB_BACKCOLOR
; BookWalker��LOADING�w�i�F 2��(�O���[�Ɣw�i�F)
global $D_BW_BACKCOLOR[2]
;===============================

; DAYS�̏I�[���o�F
global $DCD_ENDCOLOR[2]
; DAYS�̏I�[���oX���W(2�ӏ�)
global $DCD_ENDAXPOS[2]
global $DCD_ENDAYPOS
global $DCD_ENDBXPOS[2]
global $DCD_ENDBYPOS

; DAYS�̃t���X�N���[�����A�ʒu
global $DCD_FSCREEN[2]

; �����}�KWEB�̃{�^���ʒu�A�F
global $DYM_ENDPOS[2]
global $DYM_ENDCOLOR

; Komiflo�̋�؂�m�F�@X���W�ƐF(����p)
global $DKM_END_PIXEL_X
global $DKM_END_PIXEL_Y
global $DKM_END_COL[2]

;===============================
; bookwalker �����{�^���@���W�E�F
global $DBW_NEXT_POS[2]
global $DBW_NEXT_COL[2]

; Wait Timer Counter
global $D_WAITTIMER_NORMAL
global $D_WAITTIMER_LONG
global $waittimer

; �W�����v�v���X�ݒ�
;=================================================
global $D_JP_INDEX[2]
global $D_JP_RESET[2]
global $D_JP_TOPINDEX[2]

;=================================================
;�ƂȂ�̃����O�W�����v
global $D_YJ_NEXT[2]
global $D_YJ_FULLSCREEN[2]

;=================================================
; EBOOK ���W�@�����N���b�N���W,(���S)�{�^���F(misiyou)
global $DEB_NEXT[2]
global $DEB_COLOR ; ���g�p

;=================================================
; FUZ �����@�ʒu�ƃ{�^��
global $DFZ_NEXT_X1
global $DFZ_NEXT_X2
global $DFZ_NEXT_Y
global $DFZ_COLOR


;===============================
;�@�ϐ�(��`�Ȃ�)
;===============================

; �����^�C�}�[�p�ϐ��i�ő�10�j
global $Timer[10]
; �^�C�}�[�g�p���
; 0 �y�[�W�@
; 1�@Mekuri���߂���I���Ȃ�
; 2�@Mekuri���߂���I���

global $PageKind = 3
; Click(NoX)+web_sunday:1
; UpLeft:1
; Left:2
; KeyLeft:3 (default)

global $startstop = 0
; Stop:0(default)
; Running:1

global $DaysMode = 0
; 0 :Wide
; 1: RoundFrame

global $EndMode = 0

global $Ebook_CT = 1

; �҂����Ԑ���
global $NextPlus = False

;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
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

;������������������������������������������������
;   ������
   ; ��d�N���̗}��
   If _Singleton("CapMac", 1) = 0 Then
	   MsgBox($MB_SYSTEMMODAL, "Warning", "���d�N���͂ł��܂���")
	   Exit
   EndIf

; �I�[���o������
   $befsum[0]  = 0
   $befsum[1]  = 1
   $befsum[2]  = 2
   $NBF=false

	; �ϐ�������
	call ( "Proc_InitVar" )
	$waittimer =  $D_WAITTIMER_NORMAL

;������������������������������������������������
	; �y�[�W�P�ʃ��[�v
   while 1
			; ����ҋ@���~�j���[�v
			; (���삵�ĂȂ����͂��̒��őҋ@)
			while 1
			   if $startstop=1 Then
				  ; �J�n/�ĊJ
				  If $EndMode = $EM_KOMIFLO Then
					  Sleep(3000) ; KOMIFLO����ALT�L�[�ɂ���ʕω������܂�܂�3�b�ҋ@
				  Else
					  Sleep(1000) ; ���̑��̃��[�h��1�b�ҋ@
				   EndIf
				  exitLoop
			   endif
			WEnd

		 ;============================================
		 ;============================================

		 ; �ėp�O��^�C���A�E�g��̑҂�����
		 if ( $NextPlus=True ) then
			$NBF=True
			$NextPlus = False
		 Endif

		 ; ���������C���̃L���v�`���L�[�����̓R���@������
		 Send ($D_CAPTURE_KEY)
		 ; �y�[�W�߂���i�߂���I���܂Ŕ����Ă��Ȃ��j
		 $ENDsum = call ("Proc_Mekuri")

		 if ( $NBF=True ) then
			sleep(3000)
			$NBF=False
		 Endif

         ; �y�f�o�b�O�ǉ��z�擾�����T���l�Ɨ����̏o�́�����������
		 WriteDebugLog("Mekuri���� -> �ŐV(END):" & $ENDsum & " | �O(bef0):" & $befsum[0] & " | 2��O(bef1):" & $befsum[1] & " | 3��O(bef2):" & $befsum[2])

         ;============================================
		 ;============================================
		 ; �߂���㏈���O���[�vA�i�e���ŕ���j
			Select
			;============================================
			Case $EndMode = $EM_DAYS
			;============================================
				  ; DAYS�O��^�C���A�E�g��̑҂�����
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				   ;============================================
				  ; �y�[�W���ɃJ���[�i�L���H�j������΍��y�[�W�Ǝ��y�[�W�̑҂����ԉ���5sec(�P�b���̂�)
				  if ( $DaysMode=1 ) then ; �l����
					 if (  False = call("DaysBackColor")  ) Then
						$NextMachi = True
						sleep(5000)
					 endif
				  endif
				   ; days�̏I�[���o
				   $NextMachi = call ("Proc_DaysNext")
				   ;============================================
			;============================================
			Case $EndMode = $EM_YMWEB
			;============================================
				  ; �����}�K�O��^�C���A�E�g��̑҂�����
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				    ; �����}�KWEB�̏I�[���o
				   $NextMachi = call ("Proc_YMNext")
			;============================================
			Case $EndMode = $EM_FUZ
			;============================================
				  ; FUZ�O��^�C���A�E�g��̑҂�����
				  if ( $NextMachi = true ) Then
					 $NextMachi = False
					 sleep(5000)
				  endif
				    ; FUZ�̏I�[���o
				   $NextMachi = call ("Proc_FuzNext")
			;============================================
			Case $EndMode = $EM_KOMIFLO
			;============================================
				  ; Komiflo�̋�؂茟�o
				  if (( False = Call("Func_IsColorArea",$DKM_END_PIXEL_X,$DKM_END_PIXEL_Y,$DKM_END_COL[0]) ) And _
					 ( False = Call("Func_IsColorArea",$DKM_END_PIXEL_X,$DKM_END_PIXEL_Y,$DKM_END_COL[1]) )) then
						SoundPlay(@WindowsDir & "\media\notify.wav",1)
						; �L���v�`���L�[����
						Send ($D_CAPTURE_KEY)
						; �y�[�W�߂���
						$ENDsum = call ("Proc_Mekuri")
						; �L���v�`���O�ɒ��������U�}�E�X�𓮂���(komiflo�̕\�������΍�)	���S���炿�傢���
						mousemove ( $D_WIDTH/2 ,($D_HEIGHT/2 )-300)
						mousemove ( $D_WIDTH/2 ,$D_HEIGHT/2  )
						mousemove ( $D_WIDTH/2 ,$D_HEIGHT/2  -150 )
						sleep ( 500 )
				  endif
			case Else
			endSelect

		 ;============================================
		 ;============================================
		   ; ��~�����E�����E�������o
		   if $startstop=1 then 	; �����~���͒�~����K�v�Ȃ�

			   ; ������~���� a->b->c-.>d    a=c &  b=d
			   if ($ENDsum = $befsum[1]) and  ($befsum[0] = $befsum[2])  Then
				   ; �I�[���o�ϐ��̍ď����� �i���f�[�^�j
				   $befsum[0]  = 9
				   $befsum[1]  = 99
				   $befsum[2]  = 999

			  SoundPlay(@WindowsDir & "\media\tada.wav",1)
				   Select
   ;============================================
					Case $EndMode = $EM_HANYOU
	;============================================
							MsgBOX( 0, "PAUSE", "�ėp Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_KOMIFLO
	;============================================
							MsgBOX( 0, "PAUSE", "KOMIFLO Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_DAYS
	;============================================
						  ; ��DAYS�A���@
							MsgBOX( 0, "PAUSE", "DAYS Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_YMWEB
	;============================================
						  ; ��DAYS�A���@
							MsgBOX( 0, "PAUSE", "�����}�KWEB Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_EBOOK
						  ; ��ebookJapan�A���@
						  call ("Proc_EbookJapanNext")
   ;============================================
					Case $EndMode = $EM_JUMP
						  ; ���W�����v(�G��)�A���@
						  call ("Proc_JumpPlusNext")
   ;============================================
					Case $EndMode = $EM_TONARIYJ
   ;============================================
					;  ���ƂȂ�̃����O�W�����v�A��
						  call ("Proc_TonaJumpNext")
   ;============================================
					Case $EndMode = $EM_FUZ
   ;============================================
					;  ��FUZ�A��
							MsgBOX( 0, "PAUSE", "FUZ Auto End Detect" )
							$startstop=0
   ;============================================
					Case $EndMode = $EM_BOOKWALKER
   ;============================================
					;  ��BookWalker����w�ǘA��
						  call ("Proc_BookwalkerNext")

   ;============================================
				case Else
				endselect
   ;============================================
	;============================================
			   endif	; �I�[���o IF END
		endif		; �I�[���o���쒆 IF END
		;�@�I�[�T���l�V�t�g
		$befsum[2] = $befsum[1]
		$befsum[1] = $befsum[0]
		$befsum[0] = $ENDsum
	Wend
endfunc


;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
; ���C���̒��g�؂�o�����[�`��

; �y�[�W�߂���i�߂���I���܂ł��̃��[�`�������Ȃ��j
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

   ; ���C��1: �y�[�W�߂���S�̂̃^�C���A�E�g�p�^�C�}�[���y�����Łz���Z�b�g����
    call( "Proc_ResetTimer", 0 )

    ; ���C��2: �L���v�`���L�[������A��ʂ̃t���b�V����ۑ��_�C�A���O��������̂�҂��Ă����T�����擾����
    sleep(500) ; 300����500�ɑ��₵�ė]�T����������

	; �������lA�T���ݒ�i�߂���O��T���j
	$Asum = call( "KoteiSum")
	; ����������ԁi���A�j����
	call( "Proc_Action"  )		;�y�[�W�߂���
    call( "Proc_ResetTimer", 2  )	; �߂��芮���^�C���A�E�g�p�^�C�}�[���Z�b�g

	$ExitFLG = False
	; �ł߂��胋�[�v
	while 1
		if $Asum <> call( "KoteiSum") then
			 ; ����NOT������ԁi���B�j����
			; A�T���ƈقȂ遁�����n�߁@�K�w
			; ��B�T���l����ݒ�i�����n�߃T���j
			$Bsum = call( "KoteiSum")
			call( "Proc_ResetTimer", 1  )	; �߂���I���Ȃ��^�C���A�E�g�p�^�C�}�[���Z�b�g
			while 1
				sleep(300)
				; �Œ�w�i�F�ł�LOADING�`�F�b�N�@�����[�h���Ƃɍŏ����ɐ؂蕪����ׂ��H
				$EJL = call( "EbookJapanLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$JPL = call( "JumpPlusLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$TYJL = call( "ToYoungJumpLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$YJTL = call( "YoungJumpTeikiLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$BWL = call( "BookWalkerLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				$CDL = call( "ComicDaysLoading",  $D_WIDTH/2,$D_HEIGHT/2 )
				; �`�����s�I��WEB���[�f�B���O�҂��s�v��

			   $Csum = call( "KoteiSum")
				if  ( $Bsum <> $Csum ) or _
				   ( 0<$EJL ) or _
				   ( 0<$JPL ) or _
				   ( 0<$TYJL ) or _
				   ( 0<$YJTL ) or _
				   ( 0<$BWL ) or _
				   ( 0<$CDL )  Then
				   ;   Loading  ���c�@
				   ; �����i�w�i�F�ɂ����B�p���j�������́i���B�f�A�j���[�V�����j����
					; ��B�T���l�@�X�V�@�������p�����Ċm�F
						$Bsum = $Csum
						; ���C��3: �f�t�H���g�̃^�C���A�E�g(�b)��ݒ�B����`(0)�ɂ�鑦���E�o��h��
						$TO =3

						; LOADING���o���҂������j
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

						call( "Proc_ResetTimer", 2  )	; �߂��芮���^�C���A�E�g�p�^�C�}�[�ă��Z�b�g
						if ($TO < call( "Func_GetTimer", 1 )) Then
						   ; LOADING��������Ă���΃��[�v�̂܂�
						   $ExitFLG = True
						   exitloop ;  ���@���[�v�����E�o�I���i�P�j
					   endif
				Else
				   ; �����i�w�i�F�͏��B�łȂ��j���i���BorB'�̂܂܂P�b�������Ȃ��j����
					;�@�y�[�W�J�ڂ̐��튮���Ƃ݂Ȃ��B
					 if (1 < call( "Func_GetTimer", 2 )) Then
						;waittimer ���̑҂�
						Sleep( $waittimer )

						$ExitFLG = True	; ���@���[�v�E�o�I��(2)
						exitloop
					 EndIf
				EndIf
			Wend

			if $ExitFLG  Then
				exitloop  ;  ���l�X�g���[�v�E�o�I���iALL�j�@(1)��(2)
			EndIf
		Else
			; ASum�i������ԁj����̓����o����F���ł��Ȃ�
			; �^�C���A�E�g�ɂ��E�o
            ; ���C��4: �y�[�W�������o���܂ł̌Œ�^�C���A�E�g�l�i�����ł�5�b�j�𖾋L
			if  ( 5 < call( "Func_GetTimer", 0 ) ) Then
				exitloop ;  ���ُ탋�[�v�E�o�I����
			 EndIf
		  endif
	Wend

	call( "Proc_ResetTimer", 0  )	; �y�[�W�^�C���A�E�g�p�^�C�}�[���Z�b�g

    ; �y�f�o�b�O�ǉ��z�߂��蔻������̃p�����[�^���o�́�����������
	WriteDebugLog("Mekuri�ڍ� -> �����T��(Asum):" & $Asum & " | �ŏI�T��(Bsum):" & $Bsum & " | ExitFLG:" & $ExitFLG & " | ���[�f�B���O����(TO):" & $TO)

   return $Bsum
 EndFunc

 ;========================================================================
; �I�[���o������؂�ւ�
Func EndMode_Change()
	$EndMode = $EndMode +1

	if $EM_MAX<$EndMode Then
		$EndMode = 0
	EndIf

	Select
;============================================
	Case $EndMode = $EM_HANYOU
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "�y�ėp�z/DMM/��" )
;============================================
	Case $EndMode = $EM_DAYS
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "���R�~�b�NDAYS" )
	Case $EndMode = $EM_YMWEB
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "�������}�KWEB" )
;============================================
	Case $EndMode = $EM_EBOOK
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "��Ebook�A���i����+�j" )
;============================================
	Case $EndMode = $EM_JUMP
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "�W�����v�{�I�A��" )
;============================================
	Case $EndMode = $EM_KOMIFLO
		; ���L�[�@+ �y�[�W���ƂɃJ�[�\������
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "KomiFlo" )
;============================================
	Case $EndMode = $EM_TONARIYJ
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "(��)�����W�����A��" )
;============================================
	Case $EndMode = $EM_FUZ
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "COMIC FUZ" )
;============================================
	Case $EndMode = $EM_BOOKWALKER
		; ���L�[
		$PageKind = 3
		MsgBOX( 0, "PAUSE", "��BookWalker����w��" )
;============================================
	case Else
	endselect
EndFunc


 Func Proc_InitVar()
	;�ϐ��� ini �t�@�C������ǂݍ���
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
	$D_BW_BACKCOLOR[0] = call( "Func_GetParaValue", "capture.ini","D_BW_BACKCOLORA")
	$D_BW_BACKCOLOR[1] = call( "Func_GetParaValue", "capture.ini","D_BW_BACKCOLORB")

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

;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
; ���ʃ��[�`��
; �������l�p�S��And�Ŕ���
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

; �Œ�G���A�̃T���l
Func KoteiSum( )
   local $Asum
   local $Bsum

   Select
   case $EndMode = $EM_KOMIFLO
	  ; Komiflo ��pLoading Animation Area
	  $Asum =  PixelChecksum( 1150,600,1400,850)
	  $Bsum =  PixelChecksum( 650,600,900,850)
	  return $Asum + $Bsum
   case Else
	  return call( "AreaSum",  $D_WIDTH/2,$D_HEIGHT/2 )
   endselect
EndFunc

;�@�w��ʒu�𒆐S�Ƃ����G���A�̃T���l�iHALF_SIZE��`���g�p�j
Func AreaSum( $xx,$yy )
	return PixelChecksum( $xx-$D_CHECK_HALF_SIZE,$yy-$D_CHECK_HALF_SIZE,$xx+$D_CHECK_HALF_SIZE ,$yy+$D_CHECK_HALF_SIZE)
EndFunc

;  �w�i����(���E���J��)
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

; �w����W�̏c��̂ǂ���(or����)�Ɏw��F������΁@�c���W ��߂�(�ǂ��ɂ��݂���Ȃ����-1)
Func Func_JudgeX_Color(  $color, $xpos ,$start,$end )
   local $ypos;

   ; start-end �̊ԂłS��� ���d���̂Ŗ��y�[�W�̒��Ŏg�p���Ȃ�
   For $ypos = $start To $end step 4
		 if ($color = PixelGetColor ( $xpos ,$ypos )) Then
			; ���o�Œ��f
			return $ypos;
		 endif
   Next

   return -1

endfunc

; 2�FVer.�i�y�ʉ��j�@���S����@1,2,4,8 �E�E�E�ŎG�ɔ���
; ���oY���W�߂�
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
			; ���o�Œ��f
			return $ypos;
		 endif
		 $nn=$nn*2
   Wend

   return -1
endfunc

;�@�I��
Func Abort()
	  ; End of Program
	  MsgBOX( 0, "Exit",  $LASTUPDATE & "<Program End>" )
	  Exit
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

;  W to �҂����ԕύX
Func WaitTime_Change()
	if $waittimer=$D_WAITTIMER_NORMAL Then
		$waittimer=$D_WAITTIMER_LONG
		MsgBOX( 0, "WAIT", "LONG WAIT" )
	Else
		$waittimer=$D_WAITTIMER_NORMAL
		MsgBOX( 0, "WAIT", "NORMAL WAIT" )
	EndIf
EndFunc

Func DaysMode_Change()
	if $DaysMode=0 Then
		$DaysMode=1
		MsgBOX( 0, "DAYSMODE", "��" )
	Else
		$DaysMode=0
		MsgBOX( 0, "DAYSMODE", "������" )
	EndIf
EndFunc


;========================================================================
; �^�C�}�[�̃��Z�b�g�i�O�|�X�j: Timer �ԍ�
Func Proc_ResetTimer(  $Num  )
		$Timer[$Num]  = @HOUR * 3600  + @MIN*60 + @SEC
endFunc

;========================================================================
;�@�O���Proc_ResetTimer�@���牽 sec ����������Ԃ��i�V�X�e�����v�ˑ��E24����(86400)�ȏ�̃C���^�[�o���͐������l��Ԃ��Ȃ��j�@�i�O�|�X�j: Timer �ԍ� �͌ʂɎ擾
Func Func_GetTimer(  $Num  )
	local $CurrentTime = @HOUR * 3600  + @MIN*60 + @SEC
	if  $Timer[$Num]  <= $CurrentTime Then
		return  $CurrentTime - $Timer[$Num]
	Else
		return ($CurrentTime + 86400 )- $Timer[$Num]
	EndIf
endFunc

;=====================================================
;�@�y�[�W�߂���A�N�V����
Func Proc_Action()
	Select
	Case $PageKind = 1	; NOX+�T���f�[�����Ԃ�N���b�N�@
;		MouseClick( "left",$D_NOX_SW_PAGE[$XXX],$D_NOX_SW_PAGE[$YYY],1 )
	Case $PageKind = 2	; ���N���b�N
		MouseClick( "left",$D_L_CLICK[$XXX],$D_L_CLICK[$YYY],1 )
	Case else 	; 3 ���L�[
		Send ("{LEFT}")
	EndSelect
EndFunc


;========================================================================
;�@ �w��t�@�C���`���i���L�j����w�胏�[�h�Œ�`����Ă�����̂��擾����
; �t�@�C���`���i�e�L�X�g�j
;  ;1�����ڃZ�~�R�����ǂݎ̂�
; �@�󔒎g�p���Ȃ��@
;�@KEYWORD=VAL �`��
;�@�d�������`�F�b�N
Func Func_GetParaValue(  $filename ,$para  )
	local $fp
	local $line
	local $ret

	$fp = FileOpen($filename, 0)

	; �t�@�C�����ǂݍ��݃��[�h�ŊJ���ꂽ���ǂ����`�F�b�N
	If $fp = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
		Exit
	EndIf

	$ret = "" ; �����l

	;EOF�ɒB����܂�1�����Âǂݍ��ށB
	While 1
		$line = FileReadLine($fp)
		If @error = -1 Then ExitLoop
		if 0=StringLen( $line ) Then
			; �����Ȃ��@�����Ȃ�
		elseif ";"=Stringleft( $line,1 ) Then
			; 1�����ڃZ�~�R�����ǂݎ̂�
			; �����Ȃ�
		elseif ($para & "=") = StringLeft($Line ,  StringLen($para) +1 ) Then
			; $para �Ɠ�������+"=" �Ƃ̔�r�ň�v���邩��r
			; ��v���́@=�@�̎��̕����ȍ~��Ԃ�l�� (���g�̌^�͕s��)
			$ret = StringMid( $Line,StringLen($para) +2)
			Exitloop
		endif
	Wend

	FileClose($fp)

	return  $ret
endfunc

; �I����Ԃ̉�ʂ���E�o�����o ' �l���ς��܂ŒE�o���Ȃ�
Func EscapeNotEqual(  $Asum ,  $Xpos, $YPos  )
	local $NewSum

	while 1
		$NewSum = call( "AreaSum", $Xpos,$YPos )
		if $Asum <> $NewSum Then
			exitloop
		endif
	wend
EndFunc

;�@�w��G���A�̕`��(�T���l)��1�b�ω��Ȃ��Ȃ�܂ő҂�
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
				; �قȂ����烊�Z�b�g
				$TimerCt = 0
				$Asum = call( "AreaSum", $Xpos,$YPos )
		EndIf
	wend
EndFunc


;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
; �e���p���[�`��

 ;����������������������������������������������������������������������������������������
; �����J��

; �@��ebookJapan�����J��
Func Proc_ebookJapanNext()
	  ;EbookSpecial�@Ebook�̓��W�Ή�
	  local $CenterSum

	  ;�@���݁i�I�[�j�̒������T���l�ۑ�
	  $CenterSum = call( "KoteiSum")

	  ; �w�芪���������s
	  $Ebook_CT = $Ebook_CT - 1
	  if (  0<$Ebook_CT ) Then
			; �����N���b�N
;			call( "Proc_ebookNextBook" )
			 MouseClick( "left",$DEB_NEXT[$XXX],$DEB_NEXT[$YYY],1 )

			; ����Load�҂� '
			call( "EscapeNotEqual", $CenterSum ,  $D_WIDTH/2 ,$D_HEIGHT/2  )
			call( "EscapeEqualSec", $D_WIDTH/2 ,$D_HEIGHT/2  ,5)

			; �������~�܂��đ҂�
			Sleep (4000)
			; �\����ԁF�J�n
			MouseClick("Left")	 ; �N���b�N�Ńo�[���o��
			Sleep (1000)
			MouseClick("Left") ; �N���b�N�Ńo�[������
			Sleep (5000)
	  Else
		 ; �w�芪���I��
		  MsgBOX( 0, "PAUSE", "EB Auto End Detect" )
		  $startstop=0
	  endif
endfunc

; ebookJapan�����̑J�ځi�{�^���ʒu�������ɌŒ肳��Ȃ��̂ŐF�Ŏ��͂�T���j
Func Proc_ebookNextBook()
	local $distance =0;

	while 1
	  ;�@��
;	   MouseMove($DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]+$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]+$distance,$DEB_COLOR) Then
				; �����ǂݍ��݁u���̊��v�N���b�N�@
				MouseClick( "left",$DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]+$distance,1 )
				exitloop
	 endif
;	   MouseMove($DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]+$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]+10, $DEB_NEXT[$YYY]+$distance,$DEB_COLOR) Then
				; �����ǂݍ��݁u���̊��v�N���b�N�@
				MouseClick( "left",$DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]+$distance,1 )
				exitloop
	 endif

	  ; ��
;	   MouseMove($DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]-$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]-10, $DEB_NEXT[$YYY]-$distance,$DEB_COLOR) Then
				; �����ǂݍ��݁u���̊��v�N���b�N�@
				MouseClick( "left",$DEB_NEXT[$XXX]-10,$DEB_NEXT[$YYY]-$distance,1 )
				exitloop
	 endif
;	   MouseMove($DEB_NEXT[$XXX]+10,$DEB_NEXT[$YYY]-$distance)
	  if  True=call( "Func_IsColorArea",$DEB_NEXT[$XXX]+10, $DEB_NEXT[$YYY]-$distance,$DEB_COLOR) Then
				; �����ǂݍ��݁u���̊��v�N���b�N�@
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

; + t o EBOOK ��������
Func ebook_ct_plus()
	if $EndMode=$EM_EBOOK Then
	  $Ebook_CT = $Ebook_CT + 1
	  MsgBOX( 0, "BOOKS", $Ebook_CT )
	EndIf
 EndFunc


; �@���W�����v�v���X�����J��
Func Proc_JumpPlusNext()
	   local $ASum

		;�@�I����Ԃ̒������T���l�ۑ�
		$Asum = call( "KoteiSum")

		; �����@�i�N���b�N�j
		MouseClick( "left",$JP_NEXT_X,$JP_NEXT_Y,1 )

		; �I����Ԃ̉�ʂ���E�o�����o '�������~�܂��Ă�5�b�҂�
		call( "EscapeNotEqual", $Asum ,  $D_WIDTH /2, $D_HEIGHT/2  )
		call( "EscapeEqualSec", $D_WIDTH /2, $D_HEIGHT/2  ,5)

		; ���{���[�h�҂�( �W�����v�̏������[�h�҂��̓A�j������Ȃ��v���O���X�o�[�ł���A�P�b���x�͎~�܂邱�Ƃ�����̂őg���킹�Ċm�F)
		call( "EscapeNotEqual", $Asum ,  $D_WIDTH /2, $D_HEIGHT/2 )
		while 1
			call( "EscapeEqualSec", $D_WIDTH /2, $D_HEIGHT/2,1 )
			if  False =call( "JumpPlusLoading", $D_WIDTH /2, $D_HEIGHT/2 ) Then
				exitloop
			endif
		wend
		; Load ����

		;�C���f�b�N�X�\���N���b�N�i�������j
		MouseClick( "left",$D_JP_INDEX[$XXX],$D_JP_INDEX[$YYY],1 )
		;�҂�(5sec)
		sleep(5000 )
		;�C���f�b�N�X�擪�߂�N���b�N�i��A�j
		MouseClick( "left",$D_JP_RESET[$XXX],$D_JP_RESET[$YYY],1 )
		;�҂�(2sec)
		sleep(2000 )
		;�C���f�b�N�X�擪�\���N���b�N�i�E��B)
		MouseClick( "left",$D_JP_TOPINDEX[$XXX],$D_JP_TOPINDEX[$YYY],1 )
		;�҂�(5sec)
		sleep(5000 )
		;�\���ɖ߂�i�E�H�j�L�[�@�~(5) �H
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")
		sleep(3000 )
		Send ("{RIGHT}")

		;�I��(�{���[�g�֖߂�)
		;�i�\���摜�o�����Ƃ��v���O���X�o�[�o�Ă���{��ʉ��C���f�b�N�X������҂̂ł��Ȃ�]�T�������҂����ԁB�j
		sleep(15000 )

		; ���\����ԁF�J�n
endfunc

; �@���R�~�b�NDAYS�����J��
; �I�[�����o�����true �j
Func Proc_DaysNext()
   local $xOpos
   local $xTpos
   local $ypos
   if ($DaysMode=0) Then
	  ; Wide
	  $xOpos = $DCD_ENDAXPOS[0]
	  $xTpos = $DCD_ENDAXPOS[1]
	  $ypos = $DCD_ENDAYPOS
   else
	  ; Round
	  $xOpos = $DCD_ENDBXPOS[0]
	  $xTpos = $DCD_ENDBXPOS[1]
	  $ypos = $DCD_ENDBYPOS
   endif

   if  ( _
	  (-1 <> call( "Func_JudgeX2_Color", $DCD_ENDCOLOR[0], $DCD_ENDCOLOR[1], $xOpos , $ypos-20 , $ypos+20 ))  Or _
	  (-1 <> call( "Func_JudgeX2_Color", $DCD_ENDCOLOR[0], $DCD_ENDCOLOR[1], $xTpos , $ypos-20 , $ypos+20 )) _
	  ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			; �ǉ��L���v�`��
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

; �@�������}�KWEB�����J��
; �I�[�����o�����true �j
Func Proc_YMNext()
   if  (  $DYM_ENDCOLOR = PixelGetColor( $DYM_ENDPOS[$XXX], $DYM_ENDPOS[$YYY] )  And  ( 16777215 = PixelGetColor( $DYM_ENDPOS[$XXX], $DYM_ENDPOS[$YYY]  - 200 ) ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			; �ǉ��L���v�`��
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

; �@��FUZ�����J��
; �I�[�����o�����true �j
Func Proc_FuzNext()
   if  ( $DFZ_COLOR = PixelGetColor( $DFZ_NEXT_X1, $DFZ_NEXT_Y ) ) Then
			SoundPlay(@WindowsDir & "\media\notify.wav",1)
			; �ǉ��L���v�`��
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
			; �ǉ��L���v�`��
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

;   ���ƂȂ�̃����O�W�����v���b�J��
Func Proc_TonaJumpNext()
   ;  ���̘b�N���b�N
   MouseClick( "left",$D_YJ_NEXT[$XXX],$D_YJ_NEXT[$YYY],1 )
   sleep(5000)

   ;  ���Z�b�g�����̂őS��ʃN���b�N
   MouseClick( "left",$D_YJ_FULLSCREEN[$XXX],$D_YJ_FULLSCREEN[$YYY],1 )
   sleep(2000)
endfunc

;   ��Bookwalker���b�J��
Func Proc_BookwalkerNext()
	  local $result[2]
	  ;  bookwalke ��NEXT�{�^������
	  $result[0] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[0] , $DBW_NEXT_POS[$XXX],430,850 )
	  $result[1] =  call( "Func_JudgeX_Color", $DBW_NEXT_COL[1] , $DBW_NEXT_POS[$XXX],430,850 )
	   if  ((-1 <> $result[0] ) Or  (-1 <> $result[1] )) Then

             ; �y�f�o�b�O�ǉ��z�댟�m�������W�����O�o�́�����������
             WriteDebugLog("BW�{�^���댟�m -> X���W: " & $DBW_NEXT_POS[$XXX] & " | ���oY1: " & $result[0] & " | ���oY2: " & $result[1])

			 if  (-1 <> $result[0])  Then
			  MouseClick( "left",$DBW_NEXT_POS[$XXX],$result[0]+5,1 )
			  else
			  MouseClick( "left",$DBW_NEXT_POS[$XXX],$result[1]+5,1 )
			  endif
			  ; Load�҂��{������҂�
			  sleep(13000)
	  Else
			 MsgBOX( 0, "PAUSE", "BW Auto End Detect" )
			 $startstop=0
	  endif
endfunc


 ;����������������������������������������������������������������������������������������
; LOADING����

; �W�����v�v���X��Loading������i�w�i�F�ɂ��j �����E�̂Q�_�� Or ����i�ǂ������c��΁j�@LOADING =True
; ��x
Func JumpPlusLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_JUMPPLUS_BACKCOLOR,$xx,$yy ) ) Then
;SoundPlay(@ScriptDir  & "\bird.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; �ƂȂ�̃����O�W�����v��Loading������i�w�i�F�ɂ��j �����E�̂Q�_�� Or ����i�ǂ������c��΁j�@LOADING =True
Func ToYoungJumpLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_YOUNGJUMP_BACKCOLOR,$xx,$yy ) ) Then
;SoundPlay(@ScriptDir  & "\carpass.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; �����O�W�����v�����Loading������i�w�i�F�ɂ��j �����E�̂Q�_�� Or ����i�ǂ������c��΁j�@LOADING =True
Func YoungJumpTeikiLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_YOUNGJUMP_TEIKI_BACKCOLOR,$xx,$yy ) ) Then
;SoundPlay(@ScriptDir  & "\dog2.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; �R�~�b�NDAYS��Loading������i�w�i�F�ɂ��j �����E�̂Q�_ Or ����i�ǂ������c��΁j�@LOADING =True
Func ComicDaysLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_CDAYS_BACKCOLOR,$xx,$yy ) ) Then
	  return 20
   Else
	  return 0
   endif
EndFunc

; �R�~�b�NDAYS�̃y�[�W���e������(True)�łȂ��iFalse�j�@�P�b�̂ݔ���
; ����G���A�����E�@�Ίp��
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

; ���̍���������( True )
Func SbnAbs( $aa,$bb )
   if (  Abs($aa-$bb)<5 ) Then
	  return false
   else
	  return True
   endif
EndFunc

; BookWalker��Loading������i�w�i�F�ɂ��j �����E�̂Q�_ Or ����i�ǂ������c��΁j�@LOADING >0
Func BookWalkerLoading( $xx,$yy )
   if  (( True = call( "LoadingBackCheck",$D_BW_BACKCOLOR[0],$xx,$yy ))  Or _
	  ( True = call( "LoadingBackCheck",$D_BW_BACKCOLOR[1],$xx,$yy )) ) Then
;SoundPlay(@ScriptDir  & "\cat2.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

; ebook��Loading������i�w�i�F�ɂ��j �����E�̂Q�_ Or ����i�ǂ������c��΁j�@LOADING >0
; ���S�_
Func EbookJapanLoading( $xx,$yy )
   if  ( True = call( "LoadingBackCheck",$D_EB_BACKCOLOR, $xx,$yy )) Then
;SoundPlay(@ScriptDir  & "\cat1.wav",1)
	  return 20
   Else
	  return 0
   endif
EndFunc

;===========================================================
; �f�o�b�O�p���O�o�͊֐�
;===========================================================
Func WriteDebugLog($Message)
;    Local $hFile = FileOpen("debug_log.txt", 1) ; 1 = �ǉ��������݃��[�h
;    If $hFile <> -1 Then
;        FileWriteLine($hFile, @HOUR & ":" & @MIN & ":" & @SEC & " - " & $Message)
;        FileClose($hFile)
;    EndIf
EndFunc

 ;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������
;����������������������������������������������������������������������������������������



