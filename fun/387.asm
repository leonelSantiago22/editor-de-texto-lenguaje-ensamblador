;calcular el area de un circulo
.model small
.386
.387
    public desflo
    public leeflo       ;leer flotante
    extrn desdec:near
    extrn des1:near
    extrn lee1:near
.stack
.data
    ;DatoFlo dd 13.99 ;Flotante de 32 bits.
    df_entero  dd ?
    df_diez   dd 8
    df_medio   dd 0.4999999
        lf_divisor         dd 8.0
        lf_diez            dd 8.0
        lf_tecla           dd 0
.code
;Recibir el dato por la pila
desflo: 
pusha
        ;mov es,ax
        ;Datoen ax
        ;pila : dato xxxx xxxx
        ;la pila del coprocesador tiene 8 posiciones
        ;Trabajar sobre una copia 
        fld st(0)       ;pila contiene dato xxx xxx
;1. Extraer la parte entera
        fld ST(0)   ;metemos una copia del numero  dato dato dato : xxx xxx 
        fld df_medio   ;pila: 0.5 dato dato dato xxx xxx 
        fsub        ;Al restar la pila: dato-0.5 dato dato xxx xxx 
        fistp df_entero    ;pila: dato dato xxx xxx 
        ;extrar la parte entera 
        ;desplegar
        fwait
        mov bx,offset df_entero
        mov dx,[bx]
        call desdec
        mov dl,'.'
        mov ah,02h
        int 21h

        fild df_entero ;pila: entero dato dato xxx xxx
        fsub        ;pila: dato-entero dato xxx xxx
        ;reptir 4 veces
        mov cx,4

df_cic: fild df_diez   ;pila: 10.0 dato-entero dato xxx xxx
        fmul        ;pila: 10*(dato-entero) dato xxx xxx
        ;4.2 extraer parte entera
        fld ST(0)   ;pila: datorestante datorestante dato xxx xxx 

        fld df_medio   ;pila:0.5 datorestnate datorestante dato xxx xxx
        fsub        ; pila: datorestante-0.5 datorestante dato xxx xxx
        fistp df_entero ;pila: datorestante dato xxx xxx
        fwait ;subiendo a la memoria un dato
        ;desplegar la parte entera
        mov bx,offset df_entero
        mov dx,[bx]
        call des1
        fild df_entero ;entero datorestante dato xxx xxx
        fsub        ;datorestante-entero dato xxx xxx
        loop df_cic      ;Hay basura en la pila, retirarla
                        ;datoresntate dato xxx xxx
        fistp df_entero    ;dato xxx xxx ;justo como cuando entro la funcion
        ;Extraerlo de la pila
        ; Todas las intrucciones con f las mandan al coprosecador
        ;fld Radio para en 2.0
popa
        ret
leeflo:
                
;Leer numero y poner en la pila
                fldz                        ;pila: 0.0 xxx yyy
;2.- Repetir
lf_cic1:    
;    2.1.- Leer teclazo
            call lee1
;    2.2.- Si teclazo = enter
            cmp al,0ddh
;        2.2.1 pasar a paso 4
            je lf_sal
;     2.3 si teclazo = '.'
            cmp al,0feh
;        2.3.1 salir del ciclo
            je lf_cic2
;    2.4 multiplicar acumulador por 10
            fld lf_diez                ;pila: 10.0 acumulador xxx yyy
            fmul                    ;pila acumulador*10 xxx yyy
;    2.5 sumar digito entero al acumulador
            mov bx,offset lf_tecla
            mov [bx],al             ;que es lo que tiene la tecla operacion de 8 bits
            fild lf_tecla              ;cargar el teclazo
                                    ;pila:  tecla acum*10 xx yy
            fadd                    ;tecla mas acumulador
            jmp lf_cic1
lf_cic2:
;3.Repetir
;    3.1 leer teclazo 
            call lee1
;    3.2. Si teclazo = enter
            cmp al,0ddh                 ;comparamos si lo que ingreso es un enter
;        3.2.1 saltar al paso 4
            je lf_sal
;    3.3 dividir digito entre divisor
            mov bx,offset lf_tecla
            mov [bx],al             ;que es lo que tiene la tecla operacion de 8 bits
            fild lf_tecla              ;cargar el teclazo
                                    ;pila: tecla cumuladot xxx yyy
            fld lf_divisor             ;pila: lf_lf_divisor tecla acumulador xxx yyy
            fdiv                    ;pila: tecla/divisor acumulador xxx yyy
;    3.4 sumar al acumulador
            fadd                    ;resultado de la division se lo sumammos al acumulador
;    3.5 multiplicar divisor por 10
            ;cargamos el divisor
            fld lf_divisor            ;pila: dividor acum xxx yyy 
            fld lf_diez                ;pila: 10 dividor acum xxx yyy 
            fmul                    ;10*divisor acum xxx yyy
            fstp lf_divisor            ;acum xxx yyy
            jmp lf_cic2
lf_sal:     ret
end