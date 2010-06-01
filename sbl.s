[ORG 0x7c00]
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

read_disk:
	mov	ah,0x02		; Read disk
	mov	al,1		; read n Sectors
	mov	ch,0		; Track 
	mov	cl,2		; Sector 
	mov	dh,0		; Head 
	mov	bx,512		; Write to ES:BX
	int	0x13

	jb	.error		; CF=1 if error occured
	mov	si,disk_read_success
	call	print_string
	jmp	debug
.error:
	mov	si,disk_read_fail
	call	print_string
	jmp	hang

debug:
	mov	si, 512 
.loop:
	lodsb
	call	print_hex
	mov	cx, si
	cmp	cx, 512+512
	je	.end
	jmp	.loop
.end:
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
disk_read_success:	db "[*] Disk read successfull",0xA,0xD,0
disk_read_fail:		db "[!] Disk read failed!",0xA,0xD,0

times 510-($-$$) db 0		; MBR Signature
dw 0xAA55
