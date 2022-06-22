.MODEL SMALL
extrn lee4:near
extrn des4:near
extrn des2:near
extrn lee2:near
extrn spc:near
extrn reto:near
.STACK
.DATA
arreglo db 01h,02h,03h,04h
.CODE
main: 	mov ax,@data
		mov ds,ax

		mov cx,04h
		lea bx,arreglo		;ya tenemos una direccion
		mov ah,02h
ciclo:	mov dl,[bx]			;Cargamos la direcion de donde empieza el arreglo 
		int 21h
		call spc
		loop ciclo 			;Segun nos va a desplegar lo que tenemos en el arreglo		
		.exit 0
end