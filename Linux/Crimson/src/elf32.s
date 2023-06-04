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
;    mov ebx, 10020h
;    inc ecx
;    mov al, 5 ;e_shstrndx
    ; end of elf header

    ; open("/dev/fb0", O_RDRW);
;    int 80h ; eax <- fd

    ; make more space on the stack for display buffer (note : max size may be limited)
;    mov ebp, width * height * 4
;    sub esp, ebp
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

;	run:
		;push eax
;		shr ebx,1
;		shr edx,1
;		add edx,edi
;		sub edx,ebx
;		; x

;		add ebx,edx
;		mov ecx,edi
;		shl ecx,12
;		sub ebx,ecx
;
;		add dl,100
;
;		mov eax,ebx
;		mov esi,width
;		mul esi
;		add eax,ebx

;		;pop eax
;		mov word [eax + (width / 2 + height / 2 * width * 4)],0xffffffff
;	loop run
	;jp short loop
;incbin "payload.bin"

loop:

    ; ebx -> f
    ; ecx -> x
    ; edx -> y

    ; x = (x>>1) + f - (y >>= 1)
    sar ecx,1
    add ecx,ebx
    push edx ; bit better
    sar edx,1
    sub ecx,edx
    pop edx

    ; y = y + x - (f << 12);
    add edx,ecx
    push ebx
    sal ebx,10
    sub edx,ebx
    pop ebx

    ; (x>>23) + (y>>23) * WIDTH
    push edx
    sar edx,22
    imul edx,edx,width

    mov edi,ecx
    sar edi,22
    add edi,edx

    ; plot
	;mov esi,0x010101
	;and esi,ebx
	;sal esi,2
	;xor esi,esi
	;mov edx,ebx
	;sar edx,28
	;add esi,edx
    add dword [eax + (edi+ (width / 2 + height / 2 * width)) * 4],0x010101
    pop edx

    ; f += 100
    add ebx,100

jmp short loop

filesize equ $ - ehdr
