; 3 layers
    bits 32
    org 0x00010000

ehdr:
    db 0x7f, "ELF"
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
	mov cl, 2
	mov al, 5 ;e_shstrndx
	; end of elf header

	; open("/dev/fb0", O_RDRW);
	int 80h ; eax <- fd

	push edx	         ;edx = 0
	push eax	         ;fd
	push byte 1	         ;MAP_SHARED
	mov al, 90
	push eax	         ;we need to set second bit for PROT_WRITE, 90 = 01011010 and setting PROT_WRITE automatically set PROT_READ
	push width*height*4  ;buffer size
	push edx	         ;NULL
	mov ebx, esp	     ;args pointer
	int 80h		         ;eax <- buffer pointer

main:
	; get set of params addr
	mov esi,params
	fetch:
		pop ebp ; x
		pop ebx ; y

		; push params, they will be shifted right by vpsravd
		push edx
		push edx
		push ebx
		push edx
		push ebx
		vmovdqu ymm0,[esp] ; load 32 bits values
		vpmovzxbd ymm1,[esi] ; convert params into 32 bits value
		vpsravd ymm0,ymm0,ymm1 ; shift right
		vmovdqu [esp],ymm0 ; store back result
		; compute x
		pop ecx
		sub ebp,ecx
		pop ecx
		add ebp,ecx
		; compute y
		pop ecx
		sub ebx,ecx
		push ebp
		pop edi
		mov cl,[esi+5]
		sar edi,cl
		add ebx,edi
		pop ecx
		and ecx,ebp
		add ebx,ecx
		; get index (f >> p)
		pop edi
		; save x,y
		push ebx
		push ebp

		; compute index
		; x
		mov ecx,[esi+6]
		sar ebp,cl
		add ebp,edi
		; y
		xchg cl,ch
		sar ebx,cl
		; direction (up or down)
		bt ecx,1 ; depend on data set order / params content
		jc short skip
		neg ebx
		skip:

		; compute index continuation
		imul ebx,width * 4
		lea ebp, [ebx+(ebp+(width / 2 + (height / 2) * width))*4]

		; check out of bounds
		cmp ebp, (width * height * 4) - 1
		jbe short draw
		continue:

		sub esp,5*4 ; point to next set (x,y) data part

		add esi,8
		;cmp esi,endParams ; full compat in doubt
		cmp byte [esi],0;al ; unsafe ? better may be 0 instead of al but +1 byte ; this also depend on data (there should be no params which start with 0 unless it is the first one)
		jnz short fetch

	; reset stack
	add esp,(5*4) * 3

	inc edx ; f += 1
	jmp short main

draw:
	; compute color
	mov ecx,edx
	push 1
	pop edi
	test cl,15
	jne d
		push 9 ; vary amount of red
		shr ecx,18
		pop edi
		sub edi, ecx
		jns d
		push 1
		pop edi
	d:
	sal edi, 16
	add edi, 258

	; saturate add
	movd xmm0,edi
	vpaddusb xmm0,xmm0,[eax+ebp]
	movd [eax+ebp],xmm0 ; plot
	jmp short continue

params:
	dd 0x0B0D0600 ; x / y shift params
	db 0x1f ; index (f >> n)
	db 0x06 ; y (x >> n) ; can be removed if don't mind same param for sets
	db 0x0B ; index (x >> n)
	db 0x08 ; index (y >> n)

	; water
	dd 0x0A0A0502
	db 0x0D
	db 0x06
	db 0x07
	db 0x0A

	; sky
	dd 0x04090502
	db 0x0F
	db 0x0C
	db 0x09
	db 0x0B
endParams:

filesize equ $ - ehdr
