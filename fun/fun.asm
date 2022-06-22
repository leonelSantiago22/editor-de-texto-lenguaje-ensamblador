.MODEL SMALL 
public spc 
public desdec
public reto 
public lee1
public lee2
public lee4
public des4
public des2
public des1
public leedec
public leecad
.STACK
.DATA
pre_cad db 2 dup(?)
cadena db 40
bcdata db 6 dup(?)		;Reservar 6 espacios no inicializados 
.CODE
main:	mov ax,@data
		mov ds,ax
		

reto:	push bx 
		push cx
		push ax
		push dx			;Retorno
		mov ah,02h
		mov dl,0Dh 		;codigo para el salto de linea
		int 21h
		mov dl,0Ah
		int 21h
		pop dx
		pop ax
		pop cx
		pop bx
		ret
spc:	push ax 
		push dx 
		mov ah,02h
		mov dl, 20h ;Hexadecimal del espacio 
		int 21h
		pop dx
		pop ax 
		ret
lee1:	mov ah,01h ;Leemos lo que tenemos en el teclaso
		int 21h		
		sub al,30h	;Restamos lo que tenemos en al 30
		cmp al,09h	;Comparamos que sea mayor que 9
		jle l1s	;Si no ee mayor que 09 h saltamos a la salida
		sub al,07h	;Si no cumplen las condiciones le restamos otros 07
		cmp al,0Fh	;comparamos si es mayor que 0fh
		jle l1s 	;Si no saltamos a la saldia
		sub al,20h	;Si no se cumplen las condiciones anteriores le restamos 20
l1s:	ret

;Despliegue de un diguito, dato en dl

des1:	add dl,30h
		cmp dl,39h
		jle salida
		add dl,07h

salida:	mov ah,02h 
		int 21h
		ret
lee2:	push bx			;blidamos la funcion para que no sea un problema utilizar Bl 
		call lee1		;dato en al
		shl al,04		;Desplazar isquierda
		mov bl,al 		;poner en el Bl
		call lee1
		add al,bl		;acomodar y juntarlos lo de Al y Bl 		;devolver en al
		pop bx
		ret
des2:	push dx				;dato en dl, pe: 3B
		shr dl,4h			;Recuperar de Bl
		call des1
		pop dx
		and dl,0fh					;Filtar la parte derecha; pe: 0B
		call des1
		ret
lee4:	push bx
		call lee2			;12h
		mov bl,al			;resplandamos lo que tenermos en al en el registro bl
		call lee2			;Mandar a llamar para leer 2 numeros 
		mov ah,bl			;completamos el registro ax moviendo a su parte alta lo que tenemos en bl
		pop bx
		ret
des4:	push bx
		mov bl,dl		;Remplazamos lo que tenemos en dl a bl
		mov dl,dh 	;el dato esta en dl 
		call des2   ;desplegamos pa primera parte que tenemos en la parte alta de dx
		mov dl,bl		;Desplegamos la siguiente parte que es la parte baja de dx
		call des2		;Desplegamos 
		pop bx			;Regresamos el valor de bx a su original
		ret

leedec:		push cx
			push bx
			push dx 
			mov bx,0						;acumulador
			mov ch,0

	ld_c:	call lee1						;Leemos un digito
			cmp al,0DDh	
			je ld_s
			mov cl,al
			mov ax,0Ah
			mul	bx							;AX x BX, resultado en ax
			add ax,cx						;multiplicar acumulador por A y sumar al dato nuevo
			mov bx,ax
			jmp ld_c
	ld_s:	mov ax,bx
			pop dx
			pop bx
			pop cx
			ret
			
desdec:		push ax
			push bx
			push cx
			mov ax,dx 								;numero a cociete
			mov bx,0Ah
			mov cx,0								;Contador en CX
	ciclo3:	cmp ax,0
			je dd_s1
			inc cx								;Incrementamos el contador
			mov dx,0							;Dato en DX-AX
			div bx								;Dato en AX Residuo en d
			push dx 							;Respaldamos el residuo en la pila X
			jmp ciclo3
	dd_s1:	cmp cx,0 
			jg dd_sal4
			mov dl,0
			call des1
			jmp dd_sal
	dd_sal4:							;Mientras contador >0
			pop dx 
			call des1
			loop dd_sal4

	dd_sal:	pop cx
			pop bx
			pop ax
			ret
;modificacion para poder identificar el 0 eh imprimirlo 
condec:		push ax
			push bx
			push cx
			mov ax,dx 								;numero a cociete
			mov bx,0Ah
			mov cx,0								;Contador en CX
	ciclo:	cmp ax,0
			je salida1
			mov dx,0							;Dato en DX-AX
			div bx								;Dato en AX Residuo en dX
			inc cx								;Incrementamos el contador
			push dx 							;Respaldamos el residuo en la pila 
			jmp ciclo
	salida1:							;Mientras contador >0
			pop dx 
			call des1
			loop salida1
			pop cx
			pop bx
			pop ax
			ret	
;para leer cadena
leecad: mov bx,dx ;vamos a usar bx como apuntador
        sub dx,2
        mov [bx-2],cl       ;ponemos donde apunta dx el tamano de la cadena
        mov ah,0Ah                  ;ya esta en dx el offset del arreglo 
        int 21h 
        call reto
        mov al, [bx-1]          ;aqui pone realemente el tamano que leyo
        ret
;Despliega cadena
despc:  push bp
        mov bp,sp
        mov ah,02h
        cld
        mov si,[bp+4]
dcl:    lodsb           ;Carga en AL, incrementa SI
        cmp al,0        ;Si ya llegó al 0, salir.
        je dcs
        mov dl,al
        int 21h
        jmp dcl
dcs:    mov sp,bp
        pop bp
        ret
end
