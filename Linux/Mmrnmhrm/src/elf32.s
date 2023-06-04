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
	inc ecx
	mov al, 5 ;e_shstrndx
	; end of elf header

	; open("/dev/fb0", O_RDRW);
	int 80h ; eax <- fd

    mov ebp, width * height * 4
    sub esp, ebp

    sar ebx,7
    add al,245
    ;sal eax,6 ; x = 160
    ; edx = y
    iter:
        mov edi,edx
        sar edi,7
        add eax,edi ; x += (y >> 7)
        mov ecx,eax
        sar ecx,4
        mov edi,ecx
        sar edi,2
        sub edx,edi

        ;lea edi,[edx + height / 2]
        ;mov edi,edx
        imul edi,edx,-width
        lea edi,[eax + edi + width / 2 + height / 2 * width]
        mov byte [esp+edi*4],cl
        mov byte [esp+edi*4+width*4*128+width/3*4],bl
    dec ebx
    jns short iter

    ;mov byte [esp+(width / 12 + height / 2 * width) * 4],cl

    loop:
        sal ebx,13; <- due to state of ebx note: must change this for different width
        ;mov ebx,width*2*4 ; skip two first lines due to pixels lookup
        display_loop:
            ; get pixel
            mov byte al,[esp+ebx+4]
            ; if (p > 1 && p < 12)
            dec eax
            dec eax
            cmp al,9
            ja short display_loop_end
        
            ; (f >> 3) + 12
            mov ecx,[esp]; esi
            mov eax,ecx ; for f >> 1 below
            sar ecx,3
            add ecx,12
            ; f >> 1
            sar eax,1
            cdq

            ; ecx : (f >> 1) % (12 + (f >> 3))
            idiv ecx

            ; brightness >> 1
            sar edx,1
            ; set xmm1 as a greyscale value (_mm_set_epi8 line)
            vmovd xmm1,edx
            vpbroadcastb xmm1,xmm1

            ; pack RGB color and set xmm0 (_mm_set_epi32 line)
            mov eax,edx
            sar eax,2 ; >> 3 (but edx was >> 1 before)
            mov ecx,eax
            sar ecx,1 ; >> 4 (but edx was >> 1 before)
            shl eax,8 ; can be replaced by: or dh,al (3 bytes)
            shl edx,16
            or edx,eax
            or edx,ecx
            vmovd xmm3,edx
            vpshufd xmm0,xmm3,0

            ; draw loop 
            push 3
            pop edx
            draw_loop:
                mov ecx,edx
                mov eax,edx
                shr ecx,1
                and al,1
                dec ecx
                lea eax,[eax*4+ebx]
                ;shl eax,2
                ;add eax,ebx

                imul ecx,ecx,width*4
                add eax,ecx ; eax -> WIDTH * (y - 1) + x - 1;
                mov ecx,ebp
                vpaddusb xmm2,xmm0,[esp+eax]
                sub ecx,eax
                vmovd [esp+eax],xmm2
                vpaddusb xmm2,xmm1,[esp+ecx]
                vmovd [esp+ecx],xmm2

                dec edx
                ;cmp edx,4
                jns short draw_loop

          display_loop_end:
            ; display loop index check
            ;inc ebx
            add ebx,4
            cmp ebx,ebp; (width * height)
            jne short display_loop

        ; frame counter
        inc long [esp]
            ; pwrite64
            mov ecx,esp  ; buffer ptr
            mov edx,ebp  ; screen size
            ;xor esi,esi  ; seek to beginning of screen
            ;inc esi
            xor edi,edi
            push 3
            pop ebx
            ;mov ebx,3    ; fd of framebuffer
            ;mov eax,0xb5 ; pwrite64
            xor eax,eax
            mov al,0xb5
            int 0x80     ; pwrite64 to framebuffer
    jmp loop

filesize equ $ - ehdr
