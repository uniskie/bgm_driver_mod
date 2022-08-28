; =============================================================================
;	BGM Driver ����T���v��
; -----------------------------------------------------------------------------
;	2020/07/15	t.hara
; =============================================================================

;================================
; [from BASIC] USR CALL hra BGM DRIVER
;================================
;ENTRY:
;		bgmdriver_initialize
;		bgmdriver_play					;[HL]...DATA
;		bgmdriver_stop
;		bgmdriver_check_playing			;Z ... STOP
;		bgmdriver_fadeout				;A ... SPEED
;		bgmdriver_play_sound_effect		;[HL] ... DATA
;		bgmdriver_mute_psg
;		bgmdriver_interrupt_handler		; CALL from H.TIMI

	include		"msx.asm"

	bsave_header	start_address, end_address, entry_point

	org			0xD000		;UA=&hD000
start_address::
		jp		bgm_init	;DEFUSR9=UA+&H00	U=USR9(1)'BGM�h���C�o�J�n
							;					U=USR9(0)'BGM�h���C�o�I��
		jp		bgm_play	;DEFUSR1=UA+&H03	U=USR1(&HC000)'&HC000�ɂ���BGM�f�[�^�����t�J�n
		jp		bgm_stop	;DEFUSR2=UA+&H06	U=USR2(0)'BGM���t�I��
		jp		bgm_se		;DEFUSR3=UA+&H09	U=USR3(&HC800)'&HC800�ɂ�����ʉ����Đ�
		jp		bgm_fadeout	;DEFUSR4=UA+&H0C	U=USR4(1)'�E�F�C�g1�t���[���Ńt�F�[�h�A�E�g
		jp		bgm_is_play	;DEFUSR5=UA+&H0F	U=USR5(0)'U��0�ȊO�Ȃ牉�t��

;================================
;  GET USR[INT]
;================================
; USE:	F,IX,HL
; RET:	HL=VAL
;		Z=OK/NZ=ERROR
getint:
		cp		2
		ret		nz

; --> �Ƿ �� ����� Ӽ��� ���ڽ ��ĸ
; LD HL,[0xF7F8]
; <--
; --> ø�� � �ض� : hl=[hl+2]
		push	hl
		pop		ix				;[IX+2] = INT VALUE
		ld		l,[ix+2]		;get value[low]
		ld		h,[ix+3]		;get value[high]
; <--
		ret

;================================
;--- INITIALIZE BGM DRIVER ---
;================================
; U=USR[1]  : INSTALL BGM DRIVER
; U=USR[OTHER] : UNINSTALL BGM DRIVER
bgm_init:
		call	getint
		ld		a,l
		cp		1
		jr		z,bgm_install
		jr		bgm_uninstall

entry_point::
bgm_install:
		call	bgmdriver_initialize

		ld		a,[htimi_bgm]
		or		a
		ret		nz

		di
		ld		hl,h_timi
		ld		de,htimi_bgm
		ld		bc,5
		ldir

		ld		hl,jp_bgm_htimi
		ld		de,h_timi
		ld		bc,3
		ldir
		ei
		ret

jp_bgm_htimi:
		jp		bgmdriver_interrupt_handler

bgm_uninstall:
		call	bgmdriver_stop
		call	bgmdriver_mute_psg

;		�����̃t�b�N�����ׂ�
		ld		hl,jp_bgm_htimi
		ld		de,h_timi
		ld		a,[de]
		inc		de
		cpi
		ret		nz
		ld		a,[de]
		inc		de
		cpi
		ret		nz
		ld		a,[de]
		inc		de
		cpi
		ret		nz
		
;		�ۑ������t�b�N������Ώ����߂�
		ld		a,[htimi_bgm]
		or		a
		jr		nz,bgm_uninstall_1
		
;		�ۑ������t�b�N���������ret������������
		ld		a,0xC9
		ld		[h_timi],a
		jr		bgm_uninstall_2

bgm_uninstall_1:
		di
		ld		hl,htimi_bgm
		ld		de,h_timi
		ld		bc,5
		ldir
bgm_uninstall_2:
		xor		a
		ld		[htimi_bgm],a
		ei
		ret

;		H.TIMI backup
htimi_bgm:
		db 0,0,0,0,0

;================================
;--- PLAY BGM ---
;================================
; A=USR[ADDRESS]
bgm_play:
		call	getint
		ret		nz
		jp		bgmdriver_play

;================================
;--- PLAY BGM ---
;================================
; A=USR()
bgm_stop:
		jp		bgmdriver_stop

;================================
;--- PLAY SOUND EFFECT ---
;================================
; A=USR[ADDRESS]
bgm_se:
		call	getint
		ret		nz
		jp		bgmdriver_play_sound_effect


;================================
;--- FADE OUT BGM ---
;================================
; A=USR[SPEED]
bgm_fadeout:
		call	getint
		ret		nz
		ld		a,l
		jp		bgmdriver_fadeout

;================================
;--- IS PLAYING? ---
;================================
; A=USR[0]
;	A>0 ... PLAYING
bgm_is_play:
		call	getint
		ret		nz

		push	ix	;[IX+2] = INT VALUE
		call	bgmdriver_check_playing
		ld		hl,0
		jr		nz,bgm_is_stop
		inc		hl
bgm_is_stop:
		ld		[ix+2],l
		ld		[ix+3],h
		ret

; =============================================================================
;	BGM driver
; =============================================================================
	include		"bgmdriver.asm"

end_address::
