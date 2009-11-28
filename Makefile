all:
	nasm -f bin sbl.s
run:
	qemu -hda ./boot
