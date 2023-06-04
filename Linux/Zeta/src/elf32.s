    bits 32
    org 0x00010000

ehdr:
    db 0x7f, "ELF"  ; magic
    dd 1
    dd 0
    dd $$
    dw 2
    dw 3
    dd entry
    dd entry
    dd 4
    db "/dev/fb0",0

	; based on 'lintro' 128 bytes intro by frag/fsqrt: https://www.pouet.net/prod.php?which=58560
	mov ebx, 10020h
	mov cl, 2 ;e_shnum ;O_RDWR
	mov al, 5 ;e_shstrndx
	; end of elf header

	; open("/dev/fb0", O_RDRW);
	int 80h ; eax <- fd

	;mmap(NULL, buflen, PROT_WRITE, MAP_SHARED, fd, 0);
	push edx ; edx = 0
	push eax ; fd
	push byte 1 ; MAP_SHARED
	mov al, 90
	push eax ; buffer size
	push width*height*4 ; buffer size
	push edx ; NULL
	mov ebx, esp ; args pointer
	int 80h ; eax <- buffer pointer

loop:

    ; ebx -> f
    ; ecx -> x
    ; edx -> y

    mov ecx,ebx
    xor ecx,edx

    mov edx,ebx
    sal edx,10

    sar ecx,20
    xor edx,ecx

    ; (x >> 23) + (y >> 23) * WIDTH
    push edx
    sar edx,22
    imul edx,edx,width

    ;mov edi,ecx
    sar ecx,2
    add ecx,edx

    ; plot
    rol edx,23
    add [eax + (ecx+ (width / 2 + height / 2 * width)) * 4],edx
    pop edx

    ; f += 100
    add ebx,93
jmp short loop

filesize equ $ - ehdr
