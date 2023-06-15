PASSWORD_BYTES_SIZE:		equ 16
PASSWORD_CHARACTERS_SIZE:	equ 25
PASSWORD_CHARACTERS_ROWS:	equ 5
PASSWORD_CHARACTERS_COLUMNS:	equ 5

password_buffer: equ buffer     ; size PASSWORD_BYTES_SIZE
; byte 0: credits
; byte 1-2: rand seed
; bytes 3,4,5,6,7,8,9: map status (last bit is visited status of last planet before triton)
; bytes 10,11,12,13,14: upgrade status
; byte 15: checksum
password_text_buffer: equ password_buffer+PASSWORD_BYTES_SIZE      	; size PASSWORD_CHARACTERS_SIZE
password_draw_ptr: equ password_text_buffer+PASSWORD_CHARACTERS_SIZE    	; size 2
password_current_byte:	equ password_draw_ptr+2		; size 1
password_write_bit_counter:	equ password_current_byte+1		; size 1