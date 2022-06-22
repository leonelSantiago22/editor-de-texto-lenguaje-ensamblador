.MODEL SMALL
public reto 
.STACK
.DATA
.CODE
main:
reto:	push ax
		push dx			;Retorno
		mov ah,02h
		mov dl,0Dh 		;codigo para el salto de linea
		int 21h
		mov dl,0Ah
		int 21h
		pop dx
		pop ax
		ret
end 