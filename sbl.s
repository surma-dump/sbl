	cli			; Disable interrupts

	mov	ax,0x7c0	; We are at 0000:07c0
	mov	ds,ax		; turn that into
	mov	es,ax		; 07c0:0000
	

	mov	ax,0x9000	; Setup Stack
	mov	ss,ax	
	mov	sp,0
	sti			; Enable interrupts

	mov	bx, wel		; Print welcome
	call	print_string

	jmp	$





print_string:
	push	bx
	mov	ah,0x0e
.loop:
	mov	al,[bx]
	cmp	al, 0
	je	.end
	int	0x10
	inc	bx
	jmp 	.loop
.end:
	pop	bx
	ret

wel:	db	"Suckless Bootloader",0xA,0xD,0

times 510-($-$$) db 0		; MBR Signature
dw 0xAA55
