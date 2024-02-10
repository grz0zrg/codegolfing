; Halite 256b by The Orz / grz for Lovebyte 2024
; works on dosbox and freedos / bochs
bits 16

org 100h

;les bp,[bx] ; -2b on dosbox but shifted draw address on freedos
push word 0a000h
pop es

; palette
mov al,13h
p:
    int 10h
    imul dx,bx,7fh
    imul cx,bx,58h
    quit:
    imul ax,bx,40h
    mov cl,ah
    inc bx
    mov ax,1010h
    jns short p

xor bx,bx
mov bp,si
mov di,64028
g:
    ; gradient
    mov si,320
    mov ax,di
    xor dx,dx
    div si
    sub si,dx
    sar si,1
    add si,ax
    mov ax,bx
    sar ax,5
    sub ax,si
    sar ax,1
    sub al,ah
    jle skipTreshold
    mov al,129
    skipTreshold:
    mov byte [es:di],al

    ; wavy
    mov si,bp
    sar si,4
    add bx,si
    mov si,bx
    sar si,1
    sub bp,si

    ; clear depth
    mov byte [depth+di],ah

    sub di,1
    jae short g

inc cx ; rng
xor bx,bx ; x y
mov dx,575 ; z w
l:
; exit once done
;    cmp dh,16
;    jg quit+1

        add cl,159 ; rng
        ; carve and shade
        mov al,bh
        shr al,1
        mov ah,bl
        xor ah,dl
        xor ah,al
        shl ah,2
        cmp cl,ah
        jbe short skipRender
        pusha
        movzx si,ah

        dec dh
        mov al,dh
        z:
            mov cl,dh
            x:
                mov ch,dh
                y:
                    pusha
                    add bx,cx ; x, y
                    sub dl,al ; z

                    ; map
                    mov dh,bl
                    sub dh,bh
                    add bl,bh
                    mov ah,bl
                    shr ah,1
                    add ah,dl

                    sub bl,dl ; depth

                    ; 2x2 tiny iso cube
                    mov bp,3
                    c:
                        ; pos
                        mov cx,bp
                        shr cx,1
                        add cl,ah
                        imul cx,320
                        mov di,bp
                        and di,1
                        add di,cx
                        movsx cx,dh
                        add di,cx

                        ; depth check
                        add di,(depth+12447)
                        cmp [di],bl
                        jg short skipDraw
                            mov [di],bl ; write depth

                            ; shading and output
                            mov al,[cube+bp]
                            mov cx,si
                            shr cl,1
                            add al,cl
                            add al,192
                            shr al,1
                            add al,128
                            stosb

                            ; cheap shadow
                            cmp dl,60
                            jl skipDraw
                                mov al,129
                                add di,1278
                                stosb

                        skipDraw:
                        dec bp
                        jns short c
                    popa
                    dec ch
                    jns short y
                dec cl
                jns short x
            dec al
            jns short z
        popa

    skipRender:
        add bl,dh ; x += ww
        and bl,63 ; x &= 63
        jnz short continue
        add bh,dh ; y += ww
        and bh,63 ; y &= 63
        jnz short continue
        sub dl,dh ; z -= ww
        jns short continue
        xor bx,bx ; x = 0, y = 0
        mov dl,63 ; z = 63
        add dh,dh ; w
    continue:
jmp l

; can be shortened to 3 values with slightly visible artifacts on the edges
cube:
    dd 0x8040C0C0

depth:
