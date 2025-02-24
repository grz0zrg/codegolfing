bits 16

org 100h

mov al,13h
l:
  mov bp,dx
  sar bp,1
  adc cx,bp
  sub dx,cx
  sbb cx,ax

  pusha
  shr cx,8
  shr dx,9
  xor dh,al

  int 10h
  popa
  mov ah,0x0c
  aas
  loop l
inc ax
jmp short l
