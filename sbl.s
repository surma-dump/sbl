	cli			; Disable interrupts

	mov	ax,0x7c0	; We are at 0000:07c0
	mov	ds,ax		; turn that into
	mov	es,ax		; 07c0:0000
	

	mov	ax,0x9000	; Setup Stack
	mov	ss,ax	
	mov	sp,0
	sti			; Enable interrupts

	mov	si, wel		; Print welcome
	call	print_string

	mov	al,0xFE
	call	print_hex

	jmp	$




;;;;;;;;;;
; Prints characters until 0-byte
; CS:SI = start of string
;;;;;;;;;;

print_string:
	mov	ah,0x0e		; TTY 
.loop:
	lodsb			; Load next char (CS:SI) and increment SI
	or	al, al		; Like compare to zero, just smaller
	jz	.end
	int	0x10
	jmp 	.loop
.end:
	ret


;;;;;;;;;;
; Prints a byte in hexadecimal
; al = byte
;;;;;;;;;;

print_hex:
	mov	ah, 0x0e	; TTY
	mov	cx, 2		; nybbles left to print
	push	ax		; Save al for processing lower nybble later
	shr	al,4		; Shift upper nybble down
.loop:
	and	al,0b1111	; Mask lower nybble
	cmp	al,10		; A-F or 0-9?
	jl	.digit
	add	al,'A'-10	; Generate ASCII for A-F
	jmp	.print
.digit:
	add	al,'0'		; Generate ASCII for 0-9
.print:
	int	0x10
	dec	cx
	jz	.end
	pop	ax
	jmp	.loop
.end:
	ret

wel:	db	"=== Suckless Bootloader ===",0xA,0xD,0

times 510-($-$$) db 0		; MBR Signature
dw 0xAA55
