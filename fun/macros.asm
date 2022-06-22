.MODEL SMALL 
.386
org 100h
.STACK 
.DATA 
.CODE 
print2 macro x, y, attrib, sdat
LOCAL   s_dcl, skip_dcl, s_dcl_end
    pusha
    mov dx, cs
    mov es, dx                              ;utiliza el extra segment
    mov ah, 13h
    mov al, 1
    mov bh, 0
    mov bl, attrib
    mov cx, offset s_dcl_end - offset s_dcl
    mov dl, x
    mov dh, y
    mov bp, offset s_dcl
    int 10h
    
    mov dx,ds
    mov es,dx
    popa
    jmp skip_dcl
    s_dcl DB sdat
    s_dcl_end DB 0
    skip_dcl:
endm
print	macro cadena
local dbcad,dbfin,salta
	pusha			;respalda todo
	push ds			;respalda DS, porque vamos a usar segmento de c�digo
	mov dx,cs		;segmento de codigo ser� tambi�n de datos
	mov ds,dx
	
	mov dx,offset dbcad	;direccion de cadena (en segmento de c�digo)
	mov ah,09h
	int 21h			;desplegar
	jmp salta		;saltar datos para que no sean ejecutados
	dbcad db cadena		;aqui estara la cadena pasada en la sustitucion
	dbfin db 24h		;fin de cadena	con su signo de pesos
salta:	pop ds			;etiqueta local de salto, recuperar segmento de datos
	popa			;recuperar registros
endm
