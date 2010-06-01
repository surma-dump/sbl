[ORG 0x7c00]
%define MBR_ADDR 0x4000
init:
	cli			; Disable interrupts

	mov	ax,0x9000	; Setup Stack
	mov	ss,ax	
	mov	sp,0
	sti			; Enable interrupts

	mov	si, welcome_msg	; Print welcome
	call	print_string

	mov	ah,0x00		; Reset Disks
	int	0x13

read_mbr:
	mov	ah,0x02		; Read disk
	mov	al,1		; read n Sectors
	mov	ch,0		; Track 
	mov	cl,1		; Sector 
	mov	dh,0		; Head 
	mov	bx,MBR_ADDR	; Write to ES:BX
	int	0x13

dump_partitions:
	mov	si, MBR_ADDR;+446
.loop:	lodsb
	;cmp	si, MBR_ADDR+446+16*4
	call	print_hex
	cmp	si, MBR_ADDR+512
	je	hang
	jmp	.loop

hang:
	cli
	hlt


;;;;;;;;;;
; Prints characters until 0-byte
; ES:SI = start of string
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

welcome_msg:		db "=== Suckless Bootloader ===",0xA,0xD,0

times 446-($-$$) db 0		; MBR Signature
