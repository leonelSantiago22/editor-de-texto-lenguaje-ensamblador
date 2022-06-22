.MODEL SMALL
extrn des1:near
.STACK
.DATA
bcddata db 6 dup(?)		;Reservar 6 espacios no inicializados 
.CODE
main:	mov ax,@data
		mov ds,ax
		mov es,ax 						;Movemos el extra segment 
		mov dx,0001h
		mov bx,offset bcddata
		call condec 					;Escribe en arreglo
		mov cl,bcddata
		mov ch,0
		mov bx,offset bcddata

	cic:	mov dl,[bx]
			call des1
			inc bx
			loop ciclo
	condec:	push ax
			mov di,bx						;Direccion del arreglo destination index
			push cx
			mov ax,dx 								;numero a cociete
			mov bx,0Ah
			mov cx,0								;Contador en CX
	ciclo:	cmp ax,0
			je dd_p2
			mov dx,0							;Dato en DX-AX
			div bx								;Dato en AX Residuo en dX
			inc cx								;Incrementamos el contador
			push dx 							;Respaldamos el residuo en la pila 
			jmp ciclo
	dd_p2:	;Guardamos tamano de numero
			mov [di],cl 						;Movemos donde los que tenemos di
			inc di
	salida1:							;Mientras contador >0
			pop dx 
			mov [di],dl		;Guardar el digito en el arreglo
			inc di
			loop salida1
			pop cx
			pop ax
			ret
	.exit 0
end