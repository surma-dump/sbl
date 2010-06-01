all:
	nasm -f bin sbl.s
	dd if=./sbl of=./hdd conv=notrunc
run:
	qemu -hda ./hdd -hdachs 100,2,10
gdb:
	gdb -x gdb-script
