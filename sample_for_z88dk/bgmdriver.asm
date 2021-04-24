; -----------------------------------------------------------------------------
;	PSG BGM DRIVER
; -----------------------------------------------------------------------------
;	Copyright (c) 2020 Takayuki Hara
;	http://hraroom.s602.xrea.com/msx/software/index.html
;	
;	Permission is hereby granted, free of charge, to any person obtaining a 
;	copy of this software and associated documentation files (the 
;	"Software"), to deal in the Software without restriction, including 
;	without limitation the rights to use, copy, modify, merge, publish, 
;	distribute, sublicense, and/or sell copies of the Software, and to 
;	permit persons to whom the Software is furnished to do so, subject to 
;	the following conditions:
;	
;	The above copyright notice and this permission notice shall be 
;	included in all copies or substantial portions of the Software.
;	
;	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
;	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
;	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
;	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
;	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
;	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
;	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; =============================================================================
;	2009/09/30	t.hara
;	2019/07/15	t.hara	Modified for ZMA
; -----------------------------------------------------------------------------

include "bgmdriver_d.asm"

; -----------------------------------------------------------------------------
;	AY-3-8910 [PSG] ���W�X�^��`
; -----------------------------------------------------------------------------
PSG_REG_ADR			= 0xA0		; �A�h���X���b�`
PSG_REG_WRT			= 0xA1		; �f�[�^���C�g

; -----------------------------------------------------------------------------
;	BIOS�֘A
; -----------------------------------------------------------------------------
BASE_SLOT			= 0xA8		; ��{�X���b�g�w��|�[�g
EXT_SLOT			= 0xFFFF	; �g���X���b�g�w��|�[�g

; -----------------------------------------------------------------------------
;	���t�^�X�N���\���̃I�t�Z�b�g��`
;	INFO_*
; -----------------------------------------------------------------------------
INFO_PLAY_ADR_L		= 0			; ���t���A�h���X [0�Ȃ��~��]
INFO_PLAY_ADR_H		= 1			; �V
INFO_WAIT_COUNT_L	= 2			; �ҋ@����
INFO_WAIT_COUNT_H	= 3			; �V
INFO_EFF_FREQ_L		= 4			; �������g��
INFO_EFF_FREQ_H		= 5			; �V
INFO_TONE_FREQ_L	= 6			; �ݒ���g��
INFO_TONE_FREQ_H	= 7			; �V
INFO_EFF_VOL		= 8			; ��������
INFO_TONE_VOL		= 9			; �ݒ艹��
INFO_VIB_WAIT		= 10		; �r�u���[�g�x������
INFO_ENV_STATE		= 11		; �G���x���[�v�X�e�[�g
INFO_ENV_VOL		= 12		; �G���x���[�v����
INFO_VIB_INDEX		= 13		; �r�u���[�g�C���f�b�N�X
INFO_SOUND_FONT_L	= 14		; �Đ����̉��F�f�[�^�̃A�h���X
INFO_SOUND_FONT_H	= 15		; �V
INFO_NOISE_FREQ		= 16		; �m�C�Y���g��
INFO_SEL_SFONT_L	= 17		; ���F�f�[�^�̃A�h���X
INFO_SEL_SFONT_H	= 18		; ���F�f�[�^�̃A�h���X
INFO_SIZE			= 19		; INFO�\���̂̃T�C�Y

; -----------------------------------------------------------------------------
;	���F�f�[�^�\���̃I�t�Z�b�g��`
;	SFONT_*
; -----------------------------------------------------------------------------
SFONT_VIB_WAVE		= 0			; �r�u���[�g�g�`
SFONT_AR			= 32		; �G���x���[�v�� AR
SFONT_DR			= 33		; �G���x���[�v�� DR
SFONT_SL			= 34		; �G���x���[�v�� SL
SFONT_SR			= 35		; �G���x���[�v�� SR
SFONT_RR			= 36		; �G���x���[�v�� RR
SFONT_VIB_WAIT		= 37		; �r�u���[�g�x������
SFONT_NOISE			= 38		; �m�C�Y���g�� [SFONT_VIB_WAIT + 1 �ł��邱�Ƃ��O��]
SFONT_FREQ_L		= 39		; �h�����p����g��[L]
SFONT_FREQ_H		= 40		; �h�����p����g��[H]

; -----------------------------------------------------------------------------
;	����������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_initialize::
		ld		hl, play_info_ch0
		ld		de, play_info_ch0 + 1
		ld		bc, INFO_SIZE * 3 - 1
		xor		a, a
		ld		[hl], a
		ldir
		ret

; -----------------------------------------------------------------------------
;	���t�J�n����
;	input:
;		hl	...	BGM�f�[�^�̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l, ix
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_play::
		; �܂�����̉��t���~����
		push	hl
		call	bgmdriver_stop
		; ���t�J�n�̂��߂̏��������������{����
		pop		hl
		di
		; BGM�f�[�^�̃A�h���X��ۑ�
		ld		[play_bgm_data_adr], hl
		ld		ix, [play_bgm_data_adr]
		; ch0 �̉��t�f�[�^�A�h���X���擾
		ld		e, [ix + 0]
		ld		d, [ix + 1]
		add		hl, de
		ld		[play_info_ch0 + INFO_PLAY_ADR_L], hl
		; ch1 �̉��t�f�[�^�A�h���X���擾
		ld		hl, [play_bgm_data_adr]
		ld		e, [ix + 2]
		ld		d, [ix + 3]
		add		hl, de
		ld		[play_info_ch1 + INFO_PLAY_ADR_L], hl
		; ch2 �̉��t�f�[�^�A�h���X���擾
		ld		hl, [play_bgm_data_adr]
		ld		e, [ix + 4]
		ld		d, [ix + 5]
		add		hl, de
		ld		[play_info_ch2 + INFO_PLAY_ADR_L], hl
		; �t�F�[�h�A�E�g���Ȃ�t�F�[�h�A�E�g���~����
		xor		a, a
		ld		[play_master_volume_speed], a
		ld		[play_master_volume_wait], a
		ld		[play_master_volume], a
		ei
		ret

; -----------------------------------------------------------------------------
;	���t��~����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_stop::
		; ��~�����̓r���Ŋ��荞�܂�ċ����s�R�ɂȂ�Ȃ��悤�Ɋ���
		di
		; ��~����
		ld		hl, play_info_ch0
		call	bgmdriver_init_play_info
		ld		hl, play_info_ch1
		call	bgmdriver_init_play_info
		ld		hl, play_info_ch2
		call	bgmdriver_init_play_info
		; ���։���
		ei
		ret

; -----------------------------------------------------------------------------
;	���t���`�F�b�N
;	input:
;		�Ȃ�
;	output
;		Z�t���O ... 1 �Ȃ��~��, 0 �Ȃ牉�t��
;	break
;		a, f, ix
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_check_playing::
		di
		ld		ix, play_info_ch0
		ld		a, [ix + INFO_PLAY_ADR_L]
		or		a, [ix + INFO_PLAY_ADR_H]
		ld		ix, play_info_ch1
		or		a, [ix + INFO_PLAY_ADR_L]
		or		a, [ix + INFO_PLAY_ADR_H]
		ld		ix, play_info_ch2
		or		a, [ix + INFO_PLAY_ADR_L]
		or		a, [ix + INFO_PLAY_ADR_H]
		ei
		ret

; -----------------------------------------------------------------------------
;	�t�F�[�h�A�E�g����
;	input:
;		a	...	�t�F�[�h�A�E�g���x[1�`255]
;	output
;		�Ȃ�
;	break
;		a
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_fadeout::
		; ��~�����̓r���Ŋ��荞�܂�ċ����s�R�ɂȂ�Ȃ��悤�Ɋ���
		di
		ld		[play_master_volume_speed], a
		xor		a, a
		ld		[play_master_volume_wait], a
		ld		[play_master_volume], a
		ei
		ret

; -----------------------------------------------------------------------------
;	����~����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_mute_psg::
		di
		xor		a, a
		ld		d, a
		ld		c, PSG_REG_ADR
		ld		b, 16

bgmdriver_mute_psg_loop:
		out		[c], d					; FOR b=0 TO 15:SOUND b, 0:NEXT
		inc		d
		out		[PSG_REG_WRT], a
		djnz	bgmdriver_mute_psg_loop

		ld		d, 7					; SOUND 7, &H80 + &H3F
		out		[c], d
		ld		a, 0x80 + 0x3F
		out		[PSG_REG_WRT], a
		ei

		ret

; -----------------------------------------------------------------------------
;	���ʉ��J�n����
;	input:
;		hl	...	���ʉ��f�[�^�̃A�h���X
;	output
;		�Ȃ�
;	break
;		a
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_play_sound_effect::
		; ���ʉ��J�n�̂��߂̏��������������{����
		push	hl
		di
		ld		a, [play_sound_effect_priority]			; �Đ����̌��ʉ����v���C�I���e�B���������H
		cp		a, [hl]
		jp		c, bgmdriver_play_sound_effect_skip		; �Ⴏ��΍Đ����Ȃ�
		ld		a, [hl]
		ld		[play_sound_effect_priority], a			; �v���C�I���e�B���X�V
		inc		hl
		ld		[play_sound_effect_adr], hl				; ���ʉ��f�[�^�̃A�h���X
		xor		a, a
		ld		[play_sound_effect_wait_count], a		; �ҋ@���� 0
		ld		[play_sound_effect_freq+0], a			; �Đ����g�� 0
		ld		[play_sound_effect_freq+1], a
		ld		[play_sound_effect_noise_freq], a		; �m�C�Y���g�� 0
		ld		[play_sound_effect_volume], a			; ���� 0
		inc		a
		ld		[play_sound_effect_active], a			; ���ʉ��Đ��J�n
bgmdriver_play_sound_effect_skip:
		pop		hl
		ei
		ret

; -----------------------------------------------------------------------------
;	���t�^�X�N��������������[����]
;	input:
;		hl	...	���������鉉�t�^�X�N���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_init_play_info:
		ld		e, l
		ld		d, h
		inc		de
		ld		bc, INFO_SIZE - 1
		xor		a, a
		ld		[hl], a
		ldir
		ret

; -----------------------------------------------------------------------------
;	���t�������[�`��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�Ȃ�
;	comment
;		1/60�b�Ԋu�� call ����邱�Ƃ����҂��Ă��郋�[�`���ł���A�ʏ��
;		H_TIMI ���t�b�N�������[�`������Ăяo���B
;		���荞�ݏ�����z�肵�Ă��邽�߁A���W�X�^�͔j�󂵂Ȃ��B
; -----------------------------------------------------------------------------
bgmdriver_interrupt_handler::
		; ���t���[�`���Ăяo��
		ld		ix, play_info_ch0
		call	bgmdriver_play_ch
		ld		ix, play_info_ch1
		call	bgmdriver_play_ch
		ld		ix, play_info_ch2
		call	bgmdriver_play_ch
		; ���ʉ��������[�`���Ăяo��
		call	bgmdriver_sound_effect
		; �t�F�[�h�A�E�g����
		call	bgmdriver_fadeout_proc
		; �~�L�T�[���[�`���Ăяo��
		call	bgmdriver_mixer
		ret

; -----------------------------------------------------------------------------
;	���t�������[�`��[1ch��] [����]
;	input:
;		ix	...	���t���������{���鉉�t�^�X�N���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_play_ch:
		; ���t���ł��邩���ׂ�
		ld		a, [ix + INFO_PLAY_ADR_L]
		or		a, [ix + INFO_PLAY_ADR_H]
		ret		z									; ���t���łȂ���Ή��������ɒE����
		; �ҋ@���Ԃł��邩���ׂ�
		ld		l, [ix + INFO_WAIT_COUNT_L]
		ld		h, [ix + INFO_WAIT_COUNT_H]
		ld		a, l
		or		a, h
		jr		z, bgmdriver_check_next_data
		; �ҋ@���Ԃ��X�V
		dec		hl
		ld		[ix + INFO_WAIT_COUNT_L], l
		ld		[ix + INFO_WAIT_COUNT_H], h
		jp		bgmdriver_update_vibrato
		; ���̉��t�f�[�^��ǂݎ��
bgmdriver_check_next_data:
		ld		l, [ix + INFO_PLAY_ADR_L]
		ld		h, [ix + INFO_PLAY_ADR_H]
		ld		a, [hl]
		inc		hl
		; ���t�f�[�^���f�R�[�h
		cp		a, 96
		jp		c, bgmdriver_keyon					; 0�`95 �� KeyOn ���b�Z�[�W
		cp		a, 101
		jp		c, bgmdriver_drum_keyon				; 96�`100 �� KeyOn ���b�Z�[�W
		jp		z, bgmdriver_keyoff					; 101 �� KeyOff ���b�Z�[�W
		cp		a, 103
		jp		c, bgmdriver_rest					; 102 �� �x�����b�Z�[�W
		jp		z, bgmdriver_volume					; 103 �� ���ʐݒ胁�b�Z�[�W
		cp		a, 105
		jp		c, bgmdriver_sound_font				; 104 �� ���F�ݒ胁�b�Z�[�W
		jp		z, bgmdriver_jump					; 105 �� �A�h���X�W�����v���b�Z�[�W
		cp		a, 107
		jp		c, bgmdriver_play_end				; 106 �� ���t��~���b�Z�[�W
		jp		z, bgmdriver_drum1_font				; 107 �� �h�����P���F�ݒ胁�b�Z�[�W
		cp		a, 109
		jp		c, bgmdriver_drum2_font				; 108 �� �h�����Q���F�ݒ胁�b�Z�[�W
		jp		z, bgmdriver_drum3_font				; 109 �� �h�����R���F�ݒ胁�b�Z�[�W
		cp		a, 111
		jp		c, bgmdriver_drum4_font				; 110 �� �h�����S���F�ݒ胁�b�Z�[�W
		jp		z, bgmdriver_drum5_font				; 111 �� �h�����T���F�ݒ胁�b�Z�[�W
		ret

		; KeyOn���� -----------------------------------------------------------
bgmdriver_keyon:
		ld		c, a								; �j�󂳂�Ȃ����W�X�^�Ƀo�b�N�A�b�v
		call	bgmdriver_get_wait_time
		ld		[ix + INFO_WAIT_COUNT_L], e			; �҂����ԍX�V
		ld		[ix + INFO_WAIT_COUNT_H], d
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		a, c								; ����
		; ���K�����g���ɕϊ�����
		rlca
		ld		l, a
		ld		h, 0
		ld		de, freq_data
		add		hl, de								; hl �� freq_data + a * 2
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; ���F�f�[�^���擾����
		ld		l, [ix + INFO_SEL_SFONT_L]
		ld		h, [ix + INFO_SEL_SFONT_H]
		; �ݒ���g�����X�V����
bgmdriver_set_freq:
		ld		[ix + INFO_TONE_FREQ_L], e
		ld		[ix + INFO_TONE_FREQ_H], d
		; �e�평��������
		xor		a, a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		; �r�u���[�g������������
		ld		[ix + INFO_VIB_INDEX], a
		ld		[ix + INFO_SOUND_FONT_L], l
		ld		[ix + INFO_SOUND_FONT_H], h
		ld		de, SFONT_VIB_WAIT
		add		hl, de
		ld		a, [hl]
		ld		[ix + INFO_VIB_WAIT], a
		; �m�C�Y���g��������������
		inc		hl
		ld		a, [hl]
		ld		[ix + INFO_NOISE_FREQ], a
		jp		bgmdriver_update_vibrato

		; DRUM KeyOn���� -------------------------------------------------------
bgmdriver_drum_keyon:
		ld		c, a								; �j�󂳂�Ȃ����W�X�^�Ƀo�b�N�A�b�v
		call	bgmdriver_get_wait_time
		ld		[ix + INFO_WAIT_COUNT_L], e			; �҂����ԍX�V
		ld		[ix + INFO_WAIT_COUNT_H], d
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		a, c								; ����
		; ���F�����擾����
		sub		a, 96								; hl �� [a - 96] * 2 + play_drum_font1
		rlca
		ld		hl, play_drum_font1
		add		a, l
		ld		l, a								; ���t���O�s��
		ld		a, 0								; ���t���O�s��
		adc		a, h
		ld		h, a								; hl �Ƀh�������F�̃A�h���X�̓����Ă���A�h���X
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl								; hl �Ƀh�������F�̃A�h���X
		push	hl
		ld		de, SFONT_FREQ_L
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]								; de �Ƀh�����p�Đ����g��
		pop		hl									; hl �Ƀh�������F�̃A�h���X
		jp		bgmdriver_set_freq

		; KeyOff���� -----------------------------------------------------------
bgmdriver_keyoff:
		call	bgmdriver_get_wait_time
		ld		[ix + INFO_WAIT_COUNT_L], e			; �҂����ԍX�V
		ld		[ix + INFO_WAIT_COUNT_H], d
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		; �G���x���[�v�������[�X��ԂɕύX����
		ld		a, [ix + INFO_ENV_STATE]
		cp		a, 3
		jp		nc, bgmdriver_update_vibrato
		ld		[ix + INFO_ENV_STATE], 3
		jp		bgmdriver_update_vibrato

		; �x���̏��� ----------------------------------------------------------
bgmdriver_rest:
		call	bgmdriver_get_wait_time
		ld		[ix + INFO_WAIT_COUNT_L], e			; �҂����ԍX�V
		ld		[ix + INFO_WAIT_COUNT_H], d
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		[ix + INFO_ENV_STATE], 4
		ld		[ix + INFO_ENV_VOL], 0
		jp		bgmdriver_update_vibrato

		; ���ʐݒ� ------------------------------------------------------------
bgmdriver_volume:
		ld		a, [hl]								; ���ʎ擾
		inc		hl
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		[ix + INFO_TONE_VOL], a				; �ݒ艹�ʍX�V
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; ���F�ݒ� ------------------------------------------------------------
bgmdriver_sound_font:
		ld		e, [hl]								; ���F�f�[�^�̃A�h���X���擾
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		hl, [play_bgm_data_adr]				; ���t�f�[�^�̐擪�A�h���X
		add		hl, de
		ld		[ix + INFO_SEL_SFONT_L], l				; ���F�f�[�^�A�h���X���X�V
		ld		[ix + INFO_SEL_SFONT_H], h
		xor		a, a									; �e�평����
		ld		[ix + INFO_VIB_WAIT], a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		ld		[ix + INFO_VIB_INDEX], a
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; �h�����P���F�ݒ�ݒ� ------------------------------------------------
bgmdriver_drum1_font:
		ld		e, [hl]								; ���F�f�[�^�̃A�h���X���擾
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		hl, [play_bgm_data_adr]				; ���t�f�[�^�̐擪�A�h���X
		add		hl, de
		ld		[play_drum_font1], hl				; ���F�f�[�^�A�h���X���X�V
		xor		a, a									; �e�평����
		ld		[ix + INFO_VIB_WAIT], a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		ld		[ix + INFO_VIB_INDEX], a
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; �h�����Q���F�ݒ�ݒ� ------------------------------------------------
bgmdriver_drum2_font:
		ld		e, [hl]								; ���F�f�[�^�̃A�h���X���擾
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		hl, [play_bgm_data_adr]				; ���t�f�[�^�̐擪�A�h���X
		add		hl, de
		ld		[play_drum_font2], hl				; ���F�f�[�^�A�h���X���X�V
		xor		a, a									; �e�평����
		ld		[ix + INFO_VIB_WAIT], a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		ld		[ix + INFO_VIB_INDEX], a
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; �h�����R���F�ݒ�ݒ� ------------------------------------------------
bgmdriver_drum3_font:
		ld		e, [hl]								; ���F�f�[�^�̃A�h���X���擾
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		hl, [play_bgm_data_adr]				; ���t�f�[�^�̐擪�A�h���X
		add		hl, de
		ld		[play_drum_font3], hl				; ���F�f�[�^�A�h���X���X�V
		xor		a, a									; �e�평����
		ld		[ix + INFO_VIB_WAIT], a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		ld		[ix + INFO_VIB_INDEX], a
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; �h�����S���F�ݒ�ݒ� ------------------------------------------------
bgmdriver_drum4_font:
		ld		e, [hl]								; ���F�f�[�^�̃A�h���X���擾
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		hl, [play_bgm_data_adr]				; ���t�f�[�^�̐擪�A�h���X
		add		hl, de
		ld		[play_drum_font4], hl				; ���F�f�[�^�A�h���X���X�V
		xor		a, a									; �e�평����
		ld		[ix + INFO_VIB_WAIT], a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		ld		[ix + INFO_VIB_INDEX], a
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; �h�����T���F�ݒ�ݒ� ------------------------------------------------
bgmdriver_drum5_font:
		ld		e, [hl]								; ���F�f�[�^�̃A�h���X���擾
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		ld		hl, [play_bgm_data_adr]				; ���t�f�[�^�̐擪�A�h���X
		add		hl, de
		ld		[play_drum_font5], hl				; ���F�f�[�^�A�h���X���X�V
		xor		a, a									; �e�평����
		ld		[ix + INFO_VIB_WAIT], a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		ld		[ix + INFO_VIB_INDEX], a
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; �A�h���X�W�����v ----------------------------------------------------
bgmdriver_jump:
		ld		e, [hl]								; ��ѐ�A�h���X�擾
		inc		hl
		ld		d, [hl]
		ld		hl, [play_bgm_data_adr]				; ���t�f�[�^�̐擪�A�h���X
		add		hl, de
		ld		[ix + INFO_PLAY_ADR_L], l				; ���t�f�[�^������
		ld		[ix + INFO_PLAY_ADR_H], h
		jp		bgmdriver_check_next_data			; �����Ď��̃f�[�^����������

		; ���t��~ ------------------------------------------------------------
bgmdriver_play_end:
		xor		a, a
		ld		[ix + INFO_PLAY_ADR_L], a				; ���t��~
		ld		[ix + INFO_PLAY_ADR_H], a
		ld		[ix + INFO_TONE_VOL], a
		ld		[ix + INFO_ENV_STATE], a
		ld		[ix + INFO_ENV_VOL], a
		jp		bgmdriver_envelope_end				; ��~�����̂Ńr�u���[�g��G���x���[�v�����̓X�L�b�v

		; �r�u���[�g�̏��� ----------------------------------------------------
bgmdriver_update_vibrato:
		; �r�u���[�g�x�����Ԃ̍Œ��ł��邩���ׂ�
		ld		a, [ix + INFO_VIB_WAIT]
		or		a, a
		jr		z, bgmdriver_vibrato_active
		; �r�u���[�g�x�����Ԃ̍Œ��̏ꍇ
		dec		a
		ld		[ix + INFO_VIB_WAIT], a				; �x������1�J�E���g�o��
		; �ݒ���g�����擾
		ld		l, [ix + INFO_TONE_FREQ_L]
		ld		h, [ix + INFO_TONE_FREQ_H]
		jp		bgmdriver_update_freq
		; �r�u���[�g�x�����Ԃ�E���Ă���ꍇ
bgmdriver_vibrato_active:
		; �r�u���[�g�ʑ��ʒu���擾
		ld		a, [ix + INFO_VIB_INDEX]
		ld		e, a
		inc		a
		and		a, 31
		ld		[ix + INFO_VIB_INDEX], a				; ���̈ʑ��֐i�߂Ă���
		; �ʑ��ʒu�ɑΉ�����r�u���[�g�g�`���擾
		ld		d, 0
		ld		l, [ix + INFO_SOUND_FONT_L]
		ld		h, [ix + INFO_SOUND_FONT_H]
		add		hl, de
		ld		a, [hl]								; a �� INFO_SOUND_FONT->SFONT_VIB_WAVE[ INFO_VIB_INDEX ]
		; �ݒ���g�����擾
		ld		l, [ix + INFO_TONE_FREQ_L]
		ld		h, [ix + INFO_TONE_FREQ_H]
		; �r�u���[�g�g�`�����Z
		or		a, a
		jp		p, bgmdriver_vibrato_active_skip
		ld		d, 255
bgmdriver_vibrato_active_skip:
		ld		e, a
		add		hl, de
		; PSG�ɐݒ肳�����g�������X�V
bgmdriver_update_freq:
		ld		[ix + INFO_EFF_FREQ_L], l
		ld		[ix + INFO_EFF_FREQ_H], h

		; �G���x���[�v�̏��� --------------------------------------------------
		ld		l, [ix + INFO_SOUND_FONT_L]
		ld		h, [ix + INFO_SOUND_FONT_H]
		ld		d, 0
		ld		a, [ix + INFO_ENV_STATE]				; 0: AR, 1: DR, 2: SR, 3: RR, 4: ��~��
		sub		a, 1
		jr		c, bgmdriver_envelope_ar
		jr		z, bgmdriver_envelope_dr
		sub		a, 2
		jr		c, bgmdriver_envelope_sr
		jr		z, bgmdriver_envelope_rr
		jp		bgmdriver_envelope_end
		; �����[�X���C�g�̏���
bgmdriver_envelope_rr:
		ld		a, [ix + INFO_ENV_VOL]
		ld		e, SFONT_RR
		add		hl, de
		ld		b, [hl]
		sub		a, b
		ld		[ix + INFO_ENV_VOL], a					; ���t���O�s��
		jr		nc, bgmdriver_envelope_end
		ld		[ix + INFO_ENV_VOL], 0
		ld		[ix + INFO_ENV_STATE], 4				; ��~���Ɉڍs
		jp		bgmdriver_envelope_end
		; �T�X�e�B�����C�g�̏���
bgmdriver_envelope_sr:
		ld		a, [ix + INFO_ENV_VOL]
		ld		e, SFONT_SR
		add		hl, de
		ld		b, [hl]
		sub		a, b
		ld		[ix + INFO_ENV_VOL], a					; ���t���O�s��
		jr		nc, bgmdriver_envelope_end
		ld		[ix + INFO_ENV_VOL], 0
		ld		[ix + INFO_ENV_STATE], 4				; ��~���Ɉڍs
		jp		bgmdriver_envelope_end
		; �f�B�P�C���C�g�̏���
bgmdriver_envelope_dr:
		ld		a, [ix + INFO_ENV_VOL]
		ld		e, SFONT_DR
		add		hl, de
		ld		b, [hl]								; SFONT_DR
		inc		hl
		ld		c, [hl]								; SFONT_SL
		sub		a, b
		ld		[ix + INFO_ENV_VOL], a					; ���t���O�s��
		cp		a, c
		jr		nc, bgmdriver_envelope_end
		ld		[ix + INFO_ENV_VOL], c
		ld		[ix + INFO_ENV_STATE], 2				; SR �Ɉڍs
		jp		bgmdriver_envelope_end
		; �A�^�b�N���C�g�̏���
bgmdriver_envelope_ar:
		ld		a, [ix + INFO_ENV_VOL]
		ld		e, SFONT_AR
		add		hl, de
		ld		b, [hl]
		add		a, b
		ld		[ix + INFO_ENV_VOL], a					; ���t���O�s��
		jr		nc, bgmdriver_envelope_end
		ld		[ix + INFO_ENV_VOL], 255
		ld		[ix + INFO_ENV_STATE], 1				; DR �Ɉڍs
		jp		bgmdriver_envelope_end
bgmdriver_envelope_end:

		; �������ʂ��v�Z ------------------------------------------------------
		ld		a, [ix + INFO_TONE_VOL]
		xor		a, 15
		ld		b, a
		ld		a, [ix + INFO_ENV_VOL]
		srl		a
		srl		a
		srl		a
		srl		a
		sub		a, b
		jr		nc, bgmdriver_calc_eff_vol
		xor		a, a
bgmdriver_calc_eff_vol:
		ld		[ix + INFO_EFF_VOL], a
		ret

; -----------------------------------------------------------------------------
;	�҂����ԓǂݎ�菈�� [����]
;	input:
;		hl	...	�҂����Ԃ��L�^����Ă��郁�����̃A�h���X
;	output
;		hl	...	�҂����Ԃ̎��̃A�h���X
;		de	...	�ǂݎ�����҂�����
;	break
;		a, f, d, e, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_get_wait_time:
		ld		de, 0
bgmdriver_get_wait_time_loop:
		ld		a, [hl]
		inc		hl
		inc		a
		jr		nz, bgmdriver_get_wait_time_exit
		dec		a
		add		a, e
		jr		nc, bgmdriver_get_wait_time_loop
		inc		d
		jr		bgmdriver_get_wait_time_loop
bgmdriver_get_wait_time_exit:
		dec		a
		add		a, e
		ld		e, a
		jr		nc, bgmdriver_get_wait_time_skip
		inc		d
bgmdriver_get_wait_time_skip:
		ret

; -----------------------------------------------------------------------------
;	�t�F�[�h�A�E�g���� [����]
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_fadeout_proc:
		; �t�F�[�h�A�E�g�������쒆�����f
		ld		a, [play_master_volume_speed]
		or		a, a
		ret		z

		; �ҋ@�������f
		ld		a, [play_master_volume_wait]
		or		a, a
		jr		z, bgmdriver_fadeout_skip1
		; �ҋ@���Ȃ�҂����Ԍ�
		dec		a
		ld		[play_master_volume_wait], a
		ret
		; �ҋ@���łȂ�
bgmdriver_fadeout_skip1:
		; ���̑҂����Ԃ�ݒ�
		ld		a, [play_master_volume_speed]
		ld		[play_master_volume_wait], a
		; ���ʌ�
		ld		a, [play_master_volume]
		inc		a								; 0���ő剹��, 15�������Ȃ̂ŁAinc a �ŉ��ʌ�
		ld		[play_master_volume], a
		cp		a, 15
		ret		nz
		; �����ɂȂ�����t�F�[�h�A�E�g���~����
		xor		a, a
		ld		[play_master_volume_speed], a
		; �}�X�^�[���ʂ��ő�ɖ߂�
		ld		[play_master_volume], a
		; ���t����~����
		ld		hl, play_info_ch0
		call	bgmdriver_init_play_info
		ld		hl, play_info_ch1
		call	bgmdriver_init_play_info
		ld		hl, play_info_ch2
		call	bgmdriver_init_play_info
		ret

; -----------------------------------------------------------------------------
;	���ʉ����� [����]
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_sound_effect:
		; ���ʉ��Đ��������f
		ld		a, [play_sound_effect_active]
		or		a, a
		ret		z

		; �ҋ@���Ԓ������f
		ld		a, [play_sound_effect_wait_count]
		or		a, a
		jr		z, bgmdriver_sound_effect_proc
		; �ҋ@���Ԍo��
		dec		a
		ld		[play_sound_effect_wait_count], a
		ret

		; ���ʉ�����
bgmdriver_sound_effect_proc:
		ld		hl, [play_sound_effect_adr]
bgmdriver_sound_effect_loop:
		ld		a, [hl]
		inc		hl
		ld		[play_sound_effect_adr], hl				; ���̃A�h���X

		; �����R�[�h�̉��
		cp		a, BGM_SE_VOL
		jp		c, bgmdriver_sound_effect_freq_proc
		jp		z, bgmdriver_sound_effect_volume_proc
		cp		a, BGM_SE_WAIT
		jp		c, bgmdriver_sound_effect_noise_freq_proc
		jp		z, bgmdriver_sound_effect_wait_proc
		jp		bgmdriver_sound_effect_end_proc

		; ���ʉ��̎��g���ݒ�
bgmdriver_sound_effect_freq_proc:
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		[play_sound_effect_adr], hl				; ���̃A�h���X
		ld		[play_sound_effect_freq], de			; ���g�����X�V
		jp		bgmdriver_sound_effect_loop

		; ���ʉ��̉��ʐݒ�
bgmdriver_sound_effect_volume_proc:
		ld		a, [hl]									; ���ʂ��擾����
		inc		hl
		ld		[play_sound_effect_volume], a			; ���ʂ��X�V
		jp		bgmdriver_sound_effect_loop

		; ���ʉ��̃m�C�Y���g���ݒ�
bgmdriver_sound_effect_noise_freq_proc:
		ld		a, [hl]									; �m�C�Y���g�����擾����
		inc		hl
		ld		[play_sound_effect_noise_freq], a		; �m�C�Y���g�����X�V
		jp		bgmdriver_sound_effect_loop

		; �P���ҋ@
bgmdriver_sound_effect_wait_proc:
		ld		a, [hl]									; �ҋ@���Ԃ��擾����
		inc		hl
		ld		[play_sound_effect_adr], hl				; ���̃A�h���X
		ld		[play_sound_effect_wait_count], a		; �ҋ@���Ԃ��X�V
		ret

		; ���ʉ���~
bgmdriver_sound_effect_end_proc:
		xor		a, a
		ld		[play_sound_effect_active], a
		dec		a
		ld		[play_sound_effect_priority], a			; �Œ�v���C�I���e�B�ɍX�V
		ret

; -----------------------------------------------------------------------------
;	�~�L�T�[���� [����]
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l, ix
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
bgmdriver_mixer:
		ld		b, 0							; tone �� on/off �t���O [1 �� on]
		ld		e, 0							; noise �� on/off �t���O [1 �� on]
		ld		c, PSG_REG_ADR

		; ch0 ���g���ݒ�
		ld		d, 0
		ld		ix, play_info_ch0
		ld		a, [ix + INFO_EFF_FREQ_L]			; SOUND 0, [ix + INFO_EFF_FREQ_L]
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		ld		a, [ix + INFO_EFF_FREQ_H]			; SOUND 1, [ix + INFO_EFF_FREQ_H]
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		; ch0 �̎�ޔ���
		and		a, 0x80
		jr		nz, bgmdriver_mixer_skip1_ch0	; �g�[��off �Ȃ�X�L�b�v
		inc		b								; ch0 �̃g�[��on ��ێ�
bgmdriver_mixer_skip1_ch0:
		ld		a, [ix + INFO_NOISE_FREQ]
		bit		7, a
		jr		z, bgmdriver_mixer_skip2_ch0	; �m�C�Yoff �Ȃ�X�L�b�v
		and		a, 31
		ld		[play_noise_freq], a			; �m�C�Y���g�����o���Ă���
		ld		e, 8							; ch0 �̃m�C�Yon ��ێ�
bgmdriver_mixer_skip2_ch0:

		; ch1 ���g���ݒ�
		ld		ix, play_info_ch1
		ld		a, [ix + INFO_EFF_FREQ_L]			; SOUND 2, [ix + INFO_EFF_FREQ_L]
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		ld		a, [ix + INFO_EFF_FREQ_H]			; SOUND 3, [ix + INFO_EFF_FREQ_H]
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		; ch1 �̎�ޔ���
		and		a, 0x80
		jr		nz, bgmdriver_mixer_skip1_ch1	; �g�[��off �Ȃ�X�L�b�v
		inc		b								; ch0 �̃g�[��on ��ێ�
		inc		b
bgmdriver_mixer_skip1_ch1:
		ld		a, [ix + INFO_NOISE_FREQ]
		bit		7, a
		jr		z, bgmdriver_mixer_skip2_ch1	; �m�C�Yoff �Ȃ�X�L�b�v
		and		a, 31
		ld		[play_noise_freq], a			; �m�C�Y���g�����o���Ă���
		ld		a, 16							; ch1 �̃m�C�Yon ��ێ�
		add		a, e
		ld		e, a
bgmdriver_mixer_skip2_ch1:

		; ch2 �� BGM�� ���ʉ���
		ld		a, [play_sound_effect_active]
		or		a, a
		jr		z, bgmdriver_mixer_tone_ch2

		; ch2 ���ʉ��̎��g���ݒ�
		ld		hl, [play_sound_effect_freq]
		ld		a, l							; SOUND 4, l
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		ld		a, h							; SOUND 5, h
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		; ch2 ���ʉ��̃g�[����������
		and		a, 0x80
		jr		nz, bgmdriver_mixer_skip0_ch2	; �g�[��off �Ȃ�X�L�b�v
		inc		b
		inc		b
		inc		b
		inc		b

bgmdriver_mixer_skip0_ch2:
		; ch2 ���ʉ��̃m�C�Y���g���ݒ�
		ld		a, [play_sound_effect_noise_freq]
		bit		7, a
		jp		z, bgmdriver_mixer_noise_freq
		and		a, 0x3F
		out		[c], d							; SOUND 6, play_sound_effect_noise_freq
		inc		d
		out		[PSG_REG_WRT], a
		ld		a, 32							; ch1 �̃m�C�Yon ��ێ�
		add		a, e
		ld		e, a
		jp		bgmdriver_mixer_mix

bgmdriver_mixer_tone_ch2:
		; ch2 ���g���ݒ�
		ld		ix, play_info_ch2
		ld		a, [ix + INFO_EFF_FREQ_L]		; SOUND 4, [ix + INFO_EFF_FREQ_L]
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		ld		a, [ix + INFO_EFF_FREQ_H]		; SOUND 5, [ix + INFO_EFF_FREQ_H]
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a
		; ch2 �̎�ޔ���
		and		a, 0x80
		jr		nz, bgmdriver_mixer_skip1_ch2	; �g�[��off �Ȃ�X�L�b�v
		inc		b
		inc		b
		inc		b
		inc		b
bgmdriver_mixer_skip1_ch2:
		ld		a, [ix + INFO_NOISE_FREQ]
		bit		7, a
		jr		z, bgmdriver_mixer_skip2_ch2	; �m�C�Yoff �Ȃ�X�L�b�v
		and		a, 31
		ld		[play_noise_freq], a			; �m�C�Y���g�����o���Ă���
		ld		a, 32							; ch1 �̃m�C�Yon ��ێ�
		add		a, e
		ld		e, a
bgmdriver_mixer_skip2_ch2:

bgmdriver_mixer_noise_freq:
		; �m�C�Y���g��
		out		[c], d							; SOUND 6, play_noise_freq
		inc		d
		ld		a, [play_noise_freq]
		out		[PSG_REG_WRT], a

bgmdriver_mixer_mix:
		; �~�L�T�[
		ld		hl, play_master_volume
		out		[c], d							; SOUND 7, [b | e | 0x80] ^ 0x3F
		inc		d
		ld		a, e
		or		a, b
		or		a, 0x80
		xor		a, 0x3F
		out		[PSG_REG_WRT], a

		; ch0 ���ʐݒ�
		ld		ix, play_info_ch0				; SOUND 8, [ix + INFO_EFF_VOL]
		ld		a, [ix + INFO_EFF_VOL]
		sub		a, [hl]
		jp		nc, bgmdriver_mixer_mix_skip1
		xor		a, a
bgmdriver_mixer_mix_skip1:
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a

		; ch1 ���ʐݒ�
		ld		ix, play_info_ch1				; SOUND 9, [ix + INFO_EFF_VOL]
		ld		a, [ix + INFO_EFF_VOL]
		sub		a, [hl]
		jp		nc, bgmdriver_mixer_mix_skip2
		xor		a, a
bgmdriver_mixer_mix_skip2:
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a

		; ch2 �� BGM�� ���ʉ���
		ld		a, [play_sound_effect_active]
		or		a, a
		jr		z, bgmdriver_mixer_volume_ch2
		ld		a, [play_sound_effect_volume]
		jp		bgmdriver_mixer_volume_ch2_skip1
bgmdriver_mixer_volume_ch2:
		; ch2 ���ʐݒ�
		ld		ix, play_info_ch2				; SOUND 10, [ix + INFO_EFF_VOL]
		ld		a, [ix + INFO_EFF_VOL]
		sub		a, [hl]
		jp		nc, bgmdriver_mixer_mix_skip3
		xor		a, a
bgmdriver_mixer_mix_skip3:

bgmdriver_mixer_volume_ch2_skip1:
		out		[c], d
		inc		d
		out		[PSG_REG_WRT], a

		ret

; -----------------------------------------------------------------------------
;	�f�[�^�G���A
; -----------------------------------------------------------------------------
freq_data:
		dw		3420, 3228, 3047, 2876, 2714, 2562, 2418, 2282, 2154, 2033, 1919, 1811
		dw		1710, 1614, 1523, 1438, 1357, 1281, 1209, 1141, 1077, 1016,  959,  905
		dw		 855,  807,  761,  719,  678,  640,  604,  570,  538,  508,  479,  452
		dw		 427,  403,  380,  359,  339,  320,  302,  285,  269,  254,  239,  226
		dw		 213,  201,  190,  179,  169,  160,  151,  142,  134,  127,  119,  113
		dw		 106,  100,   95,   89,   84,   80,   75,   71,   67,   63,   59,   56
		dw		  53,   50,   47,   44,   42,   40,   37,   35,   33,   31,   29,   28
		dw		  26,   25,   23,   22,   21,   20,   18,   17,   16,   15,   14,   14

; -----------------------------------------------------------------------------
;	���[�N�G���A
; -----------------------------------------------------------------------------
play_sound_effect_active:
		db		0				; ���ʉ��Đ����� 1
play_sound_effect_wait_count:
		db		0				; ���ʉ��̑ҋ@����
play_sound_effect_freq:
		dw		0				; ���ʉ��̍Đ����g��
play_sound_effect_noise_freq:
		db		0				; ���ʉ��̃m�C�Y���g��
play_sound_effect_volume:
		db		0				; ���ʉ��̉���
play_sound_effect_adr:
		dw		0				; �Đ����̌��ʉ��f�[�^�̃A�h���X
play_sound_effect_priority:
		db		255				; �Đ����̌��ʉ��̃v���C�I���e�B [0���ō�]

play_noise_freq:
		db		0				; ���ۂɍĐ�����m�C�Y���g������p��ƕϐ�

play_bgm_data_adr:
		dw		0				; �Đ����� BGM�f�[�^�擪�A�h���X

play_master_volume_wait:
		db		0				; �t�F�[�h�A�E�g�p�ҋ@����
play_master_volume_speed:
		db		0				; �t�F�[�h�A�E�g�p�ҋ@���ԏ����l[0�̓t�F�[�h�A�E�g��~��]
play_master_volume:
		db		0				; �}�X�^�[����[0���ő剹��, 15������]

play_drum_font1:
		dw		0				; �h�������P�̉��F�f�[�^�A�h���X
play_drum_font2:
		dw		0				; �h�������Q�̉��F�f�[�^�A�h���X
play_drum_font3:
		dw		0				; �h�������R�̉��F�f�[�^�A�h���X
play_drum_font4:
		dw		0				; �h�������S�̉��F�f�[�^�A�h���X
play_drum_font5:
		dw		0				; �h�������T�̉��F�f�[�^�A�h���X

play_info_ch0:
		repeat i, INFO_SIZE
			db		0			; ch0 �̉��t�f�[�^���
		endr
play_info_ch1:
		repeat i, INFO_SIZE
			db		0			; ch1 �̉��t�f�[�^���
		endr
play_info_ch2:
		repeat i, INFO_SIZE
			db		0			; ch2 �̉��t�f�[�^���
		endr