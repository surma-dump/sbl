all:
	nasm -f bin sbl.s
	dd if=./sbl of=./hdd conv=notrunc
run:
	qemu -hda ./hdd
