;pequena introduccion
;es un editor de texto en el lenguaje ensamblador su ejecucion es em corrida dosbox,
;programado en AL aseembly lenguaje 8086 por Leonel Santiago Rosas y Daniel Gaytan Hernandez
;proyecto para la materia de Lenguaje ensamblador por el Mtro. Luiz Anselmo Zarza Lopez 
;agradecimiento a mi co-autor Angel Daniel Gaytan
.model small
.486
include ..\fun\macros.asm
extrn des4:near
extrn reto:near
extrn des2:near
extrn spc:near
.stack 256
.data
;El código siguiente recorre toda la pantalla una línea y establece un atributo de color:
;MOV AX,0601H
;MOV BH,30H
;MOV CX,0000
;MOV dx,184FH br INT 10H
.DATA
;db reserva memimoria para datos de tipo byte
        posx        DB     00               ;posicion en la que nos encontramos
        posy        DB     00               ;posicion en la que nos medimos
        Ltop        DB     00               ;medida en la que estamos
        InKey       DB     00               ;estado de la tecla de insercion para conocer si esta activa
        locacion    DW     0                ;saber en que columa estamos
        cant_enter  DB     00
;directiva EQU lo que hace es que asigna al valor simbolico de una expresion. 
;Cuando encuentre el codigo dicho nombre simbolico. lo sustituira por el valor de la expresion
;en este caso una contante numerica que nos indica el valor de los limites de la pantalla 
;informacion obtenida de la poderosa utm: del profesor juan juarez fuentes 
;https://www.utm.mx/~jjf/le/LE_APENDICE_D.pdf
    limite_derecho    EQU    79
    limite_izquierdo    EQU    00
    limite_inferior    EQU    21
    limite_superior    EQU    00
    limite_pantalla   EQU    79

    buffer    DB  8000 DUP(20h),20h ; Buffer para contenido maximo de 8000 caracteres
    LIST      LABEL  BYTE                       ;
    MAX_L     DB     21
    LEN       DB     ?
    nombre_archivo   DB     23 DUP(' ')  ; Buffer for crear_archivo2 name
    fid              DW     ?
    archivo_temo     DB     'temp.txt',0 ;el archivo temporal nos ayuda mientras le pone un nombre al archivo
    ;color db 71H    ;color del fondo
    numero_archivos db 0


.CODE
main:
        mov    ax, @DATA           
        mov    ds, ax              
        mov    es, ax              

        ;limpiar pantalla
        mov    ax, 0600H           ; movemos hasta arriba la pantalla
        call   limpiar_pantalla    ;funcion que limpia la pantatta

        call   Menu                 ;menu
        call   crear_archivo        ;creamos un nuevo archivo

        mov    posy, 0		      ; posicionamos el cursos para que pueda empezar a escribir
        mov    posx, 0		      

cic_main:
        call   tipo_captura                ;comprobamos si esta activo el bloq mayus 
        call   cursor_posicion          ;esta funcion nos permite mandas la posicion en la que se encuentra el cursor 
        call   entrada_del_usuarios     ;Entrada del usuario
        jmp    cic_main 
        ;salida del programa
        .exit 0
.386
;la funcion nos permite estar constantemente revisando el tipo de captura de datos activos
tipo_captura:
        push   cx
        push   ax
        mov    dh, posy
        mov    dl, posx
        push   dx	              ;respaldamos las pos x y y 
        mov    posx, 24            ;posicion x del cursor 
        mov    posy, 65            ; posy locacion del cursor para escribir 
        call   cursor_posicion     ; movemos el cursor para saber si estamos en como captura
        mov    ah, 02H
        int    16H                ; int 16H,02H - ck
        mov    ah, 02H            ; int 21H,02H - escribe el caracter de salida
        jnz    cap_encendidas             ; salta si no es cero o error a mostrar que las capturas estan habilitadas
        mov    cx, 04
        mov    dl, 20H            ; Set the character writen to STDOUT to spcae 
cic1_tipo_captura:
        int    21H
        loop   cic1_tipo_captura            ; loop to clean Caps Lock information
        jmp    num
cap_encendidas: print"Caps"


num:    mov    posy, 70            ; posyumn locacion del cursor
        call   cursor_posicion     ;mover el cursor para mostrar la información de Bloq Num 
;ah para interrupcion 16h para el scan-code de las teclas
;ah=12h teclado expandido, obtener el teclado expandido
;inf: https://es-academic.com/dic.nsf/eswiki/591430
	mov    ah, 12H
        int    16H                ; int 16H,12H - consultar el estado de cambio de teclado extendido
        and    al, 00100000B      ; Comprobar bloqueo numérico)
        mov    ah, 02H
        jnz    num_encendido              ; salta si no es igual a zero donde badera z=0
        mov    cx, 03
        mov    dl, 20H            ; Establezca el carácter escrito en STDOUT en espacio
num_apagado:int    21H
        loop   num_apagado             ; loop to clean Num Lock information
        jmp    sal_tipo_captura
num_encendido:  print "Num"

sal_tipo_captura:
        pop    dx                 ; restauramos la posicion x y y
        mov    posy, dh
        mov    posx, dl
        pop    ax
        pop    cx
        ret
;conocer el tipo de error al manipular 
error_manejo:   call reto
                mov dx,ax
                call des4
                ret
;creamos el archivo temporal
crear_archivo:
        mov    ah, 3CH
        mov    cx, 00             ; Normal 
        lea    dx, archivo_temo            ; archivo_temporal
        int    21H                
        jc     error_manejo       ; revisamos si no hay ningun error
        mov    fid, ax        ; fid es el identificador del archivo
        ret

crear_archivo3:   
        push   cx
        push   ax
        clc                                     ;bandera de acarreo limpiar
        pop    ax
        ;mov    al, 02
        mov    cx, 00                           ; abrimos el arhivo en normal
        lea    dx, nombre_archivo            ; nombre del archivo 
        int    21H
        jc     error_archivo
        mov    fid, ax                      ; mandamos el nombre del archivo al identificador
        jmp    sal_archivo
error_archivo:        
        mov    posx, 24
        mov    posy, 9
        call   cursor_posicion                  ;locacion del sursor para imprimir el mismo eh imprimir el mensaje de error
        mov    dx,ax                        ; 
        call des4                            ;desplegamos el mendaje de error
sal_archivo:
        ;restablecemos el cursor
        mov    posx, 00
        mov    posy, 00
        call   cursor_posicion              ; move cursor location
        pop    cx
        ;pop    ax       ;restauramos la pila
        ret

;nos permite crear un archivo nuevo
;revisado

crear_archivo2:   
        push   cx
        push   ax
        clc                                     ;bandera de acarreo limpiar
        mov    posx, 24
        mov    posy, 9
        call   cursor_posicion                  ; move cursor location for input crear_archivo2 name
        call   extraer_nombre_archivo           ; llamamos a llamar el nombre
        pop    ax
        ;mov    al, 02
        mov    cx, 00                           ; abrimos el arhivo en normal
        lea    dx, nombre_archivo            ; nombre del archivo 
        int    21H
        jc     error_archivo3
        mov    fid, ax                      ; mandamos el nombre del archivo al identificador
        jmp    sal_archivo3
error_archivo3:        
        mov    posx, 24
        mov    posy, 9
        call   cursor_posicion                  ;locacion del sursor para imprimir el mismo eh imprimir el mensaje de error
        mov    dx,ax                        ; 
        call des4                            ;desplegamos el mendaje de error
sal_archivo3:
        ;restablecemos el cursor
        mov    posx, 00
        mov    posy, 00
        call   cursor_posicion              ; move cursor location
        pop    cx
        ;pop    ax       ;restauramos la pila
        ret
;salvamos la escritura del archivo
escribir_archivo:
        CLC                             ;limpiar bandera de acarreo
        mov    ah,40H              ;Escritura en dispositivo/Archivo
        mov    BX,fid              ;extraemo el  handle del archivo (identificador)
        mov    cx,8000             ;numero de datos a escribir
        lea    dx,buffer
        int    21H               
        JNC    sal_escribirarchivo
        jmp error_manejo                ;para saver si hay algun tipo de error al momento de guardar el archivo
sal_escribirarchivo: ret

;lectura de los archivos
leer: 
        mov    ah, 3FH
        mov    BX, fid              ; handle del archivo
        mov    cx, 8000             ;numero de datos a leer
        lea    dx, buffer           ;espacio de guarda
        int    21H                  ; int 21,3FH - leer a crear_archivo2
        jc     leer_error              ; sabeer si hay un error
        jmp    sal_leer
leer_error:jmp error_manejo        
sal_leer:  ret


;cerrar archivo
cerrar_archivo: 
        mov   BX, fid         ; crear_archivo2 handle
        mov   ah, 3EH
        int   21H                 ;funcion oara cerrar el archivo
        ret


;extraemos el nombre del archivo
extraer_nombre_archivo:
        push   ax
        push   cx
        ;en esta posicion mandamos a pedir el nombre del archivo
        mov    posx, 24
        mov    posy, 9
        call   cursor_posicion 
        ;limpiamos el espacio de entrada
        mov    cx,25
        mov    al,20H
nombre_lleno:  call   escribir_caracter
        loop   nombre_lleno
        mov    posx,24
        mov    posy,9
        call   cursor_posicion
        mov    cx, 23
        mov    si, 0000
limpiar_nombre:  mov    nombre_archivo[si], 20H
        inc    si
        loop   limpiar_nombre
        ;entrada de los datos
        mov    ah, 0ah
        lea    dx, LIST
        int    21H
        movZX  BX, LEN                   ;movzx es para tranferir un dato agregando ceros
        mov    nombre_archivo[BX], 00H
        pop    cx
        pop    ax
        ret

;menu del programa
Menu:
;a) codigo para limpiar pantalla
;obtencion del codigo: http://pepperslina.over-blog.net/article-30488298.html
        mov    ax, 0600H        ;ah 06 es un recorrido y 00 es la pantalla completa
        mov    BH, 07H          ;colores en este caso fondo negro letras blancas
        mov    cx, 0000H        ;es l esquena superioor izquierda renglos:columna
        mov    dx, 184FH        ;es la esquina inferior derecha renglon: columna
        int    10H
;
        call   cursor_posicion
        mov    ah, 02H
        mov    posx, 22
        call   cursor_posicion
        print "F1=Crear "
        print "F2=Mostrar "
        print "F3=Guardar "
        ;print "F4=Modificar"
	print "F4=Borrar"
        print "ESC=Salir"
        ;nos movemos al final para poder escribir
        mov    posx, 24
        mov    posy, 0
        call   cursor_posicion
        mov    ah, 02H
        print "nombre:"         ;conocer el nombre del archivo en el que estamos
        mov    posx, 2          ;regresamos a la posicion donde podemos insertar
        ret

entrada_del_usuarios:
;para el uso de int 16h usamos 10h que siginifa leer caracter del teclado expandido
;donde ah=00 para leer la pulsacion del teclado y retorna los valores es 
;ah= scan-code de la tecla pulsada 
;al = caracter ascii de la tecla pulsada
        mov    ah, 10H                  ;esperamos los datos de entrada
        int    16H                      ;Obtener el estado del buffer del teclado
        cmp    ah, 01H              ;y saber si es un esc scan_code de la tecla pulsada
        je     sal_en               ;si es esc salimos de la lectura de datos den entrada
        cmp    al, 00H              ;Leer pulsacion de la tecla
        je     teclaso            
        cmp    al, 0E0H             ;es una tecla de funcion extendida como las flecas
        je     teclaso
        call   comprobar_caracter   ;comprobamos que los datos de entrada sean un caracter
        jmp    salida_entrada_usuarios             ; leave
teclaso:
        cmp    ah, 47H            ; tecla de home
        jne    salto1               ;si no es la tecla de terminar
        call   restablecer_posicion_inicial ; restablecer_posicion_inicial
        jmp    salida_entrada_usuarios
salto1: cmp    ah, 4FH            ;tecla end del teclado 
        jne    salto2
        call   limite_y              ; si si para llamar a brincar al final
        jmp    salida_entrada_usuarios             ; salir
salto2:
        cmp    ah, 50H            ; abajo de la posicon de X 
        jne    salto3
        call   para_abajo             ; para_abajo
        jmp    salida_entrada_usuarios             ; salir

salto3:  cmp    ah, 48H            ; arriba
        jne    ArrR
        call   pa_arriba               ; pa_arriba
        jmp    salida_entrada_usuarios             ; leave

ArrR:   cmp    ah, 4dh            ; flcha derecha
        jne    ArrL
        call   mover_derecha                ; mover_derecha
        jmp    salida_entrada_usuarios             ; leave

ArrL:   cmp    ah, 4BH            ;flecha izquierda
        jne    tecla_ins
        call   limite_izquierdo_tecla                ; limite_izquierdo
        jmp    salida_entrada_usuarios             ; salir

tecla_ins: cmp    ah, 52H            ;teclas insertar o ins del teclado
        jne    tecla_arriba
        call   tecla_insertar              ; tecla_insertar
        jmp    salida_entrada_usuarios             ; leave

tecla_arriba:  cmp    ah, 49H            ;tecla page up
        jne    tecla_abajo
        call   subir_pagina              ; subir_pagina
        jmp    salida_entrada_usuarios             ; leave

tecla_abajo:  cmp    ah, 51H        ; tecla page down
        jne    tecla_borrar
        call   bajar_pagina              ; bajar_pagina
        jmp    salida_entrada_usuarios             ; leave

tecla_borrar: cmp    ah, 53H            ; con 'del' del teclado 
        jne    tecla_f1             ; tecla f1
        call   borrar_caracter             ; call borrar_caracter
        jmp salida_entrada_usuarios
tecla_f1:        cmp ah,3bh              ;conocer si es f1
                jne tecla_f2
                call pulso_f1
                jmp salida_entrada_usuarios
tecla_f2:        cmp ah,3Ch              ;conocer si es la tecla f2
                jne tecla_f3
                call pulso_f2
                jmp salida_entrada_usuarios
tecla_f3:       cmp ah,3dh
                jne salida_entrada_usuarios
                call pulso_f3
                jmp salida_entrada_usuarios
sal_en: .exit 0               ;cuando presiona esc salimos    
salida_entrada_usuarios:       ret              ;cuando no ah apretado esc


;restablecemos la posicion inicial
restablecer_posicion_inicial:
        mov    posy, 00            ; pos 00
        ret

	; funcion de tecla hacia arriba
subir_pagina:
        mov    cx, 19             ; move up 19 times
cic_subir:   call   pa_arriba               ; Up
        call   cursor_posicion              ; move cursor location
        loop   cic_subir
        ret

;funcion que nos permitte bajar la pagina
bajar_pagina:
                mov cx, 19                   ;mover  19 veces hacia abajo
cic_bajar: call   para_abajo               ;bajar
        call   cursor_posicion          ; move cursor location
        loop   cic_bajar
        ret


;nos permite cambiar entre la pantalla de menu y la pantalla de editar
esc_escribir:
        mov    posy, 00
        cmp    posx, 00                 ;si las posiciones son esas salimos del modo menu
        jne    reestablecer_esc         ;restablecemos cuando sea la segunda entrada
        mov    posx, 00            ;Espacio del editor
        jmp sal_esc
reestablecer_esc:   
        mov    posx, 00            ;posicion para el menu
        mov    posy, 00
sal_esc: ret


limite_y:
        mov    posy, limite_derecho        ; move cursor location to last
        ret

;para abajo es una funcion que nos permite detectar
;segun dependiendo de que accion estemos realizando
;ponernos en la direccion adecuada del mismo
para_abajo:
        cmp    posx, limite_inferior        ; limite de x 
        JAE    scroll_arriba
        inc    posx                ; siguiente posicion de x

	    ; Desplácese hacia arriba si está en la parte inferior del espacio del editor
scroll_arriba:   cmp    Ltop, limite_pantalla
        JAE    sal_abajo
        mov    ax, 0601H                   ; El código siguiente recorre toda la pantalla una línea y establece un atributo de color:
        call   limpiar_pantalla             ; hacia arriba
        inc    Ltop
        call   linea_desplazamiento
sal_abajo: ret 


;Tratar con los contenidos cuando se desplaza una línea
linea_desplazamiento:
        push   cx
        mov    dh, posx            ;salvamos las posiciones del curo
        mov    dl, posy
        push   dx
        mov    posy,00
        call   cursor                ; juzgar la ubicación del cursor
        call   cursor_posicion        ;movemos en donde se encuentra el cursor
        mov    BX, locacion         ;locacion del cursor la movemos a bx
        lea    si, [buffer+BX]      ;nos movemos en el bufer dependiendo del contenido
de:     mov    al, [si]           ; movemos o desplazamos el caracter para imprimir
        inc    si
        call   escribir_caracter    ;imprimirmos el caracter
        cmp    posy, limite_derecho         ;revisamos si estamos en el limite derecho
        jb     de                       ;JB Si está por debajo CF=1
	;ultimo caracter
        call   cursor
        mov    BX, locacion         ;nuevamente volvemos a obtener la locacion
        mov    al, [buffer+BX]
        ;donde al= caracter, bh, numero de pagina, bl=color, cx,numero de veces para escribir en el caracter
        ;dudas informacion: https://es-academic.com/dic.nsf/eswiki/591427
        mov    ah, 09H              
        mov    BH, 0
        mov    BL, 07H             
        mov    cx, 01
        int    10H
        pop    dx                 ; restauramos las posiciones anteriormente guardadas
        mov    posx, dh             ;cambiamos por las nuevas posiciones
        mov    posy, dl
        pop    cx
        jmp salida_tra
pa_arriba:
        cmp    posx, limite_superior        ;estamos en el limitesuperior?
        jbe    scroll_bajo
        dec    posx                ; decrementamos la posicion de lo contrario
;Desplácese hacia abajo una posx cuando alcance el límite superior
scroll_bajo:   cmp    Ltop, 00
        JB     salida_tra
        mov    ax, 0701H        
        call   limpiar_pantalla             ; int 10H,07H - scroll down
        dec    Ltop
        call   linea_desplazamiento
salida_tra:
        ret


mover_derecha:
        cmp    posy, limite_derecho        ; Right limit?
        JAE    linea_siguiente
        inc    posy                ; increase posyumn
        ret
linea_siguiente:
		; pasar a la siguiente posx cuando alcance el límite derecho
        cmp    Ltop, limite_pantalla
        JB     mas_derecha
        jmp sal_derecha
mas_derecha:    ;nos movemos a la posicion inicial de la derecha
        call   restablecer_posicion_inicial
        call   para_abajo
sal_derecha:ret



limite_izquierdo_tecla:
        cmp    posy, limite_izquierdo;comprobamos si llegamos al limire
        JBE    arriba
        dec    posy                     ;si no decrementamos la posciocion y para llegar a ese limite
        ret
arriba:

	; muver hacia arriba posx cuando llegue al límite izquierdo
        call   limite_y
        call   pa_arriba
        ret
;tecla borrar
;revisado
borrar_caracter:
        mov    BH, posy             ;obtenmos las posiciones 
        mov    BL, posx
        push   BX                 ;salvamos las posisciones
        call   cursor               ;imprimirmos lo que tenemis
        mov    BX, locacion         ;ahora referemos en que posicion estamos
        lea    DI, [buffer+BX]      ;guardamos la posicion del arrelo
        lea    si, [buffer+BX+1]    ;cuando escriba de nuevo ponerlo adelante del caracter borrado
borrar_c: mov    al, [si]
        mov    [DI], al
        inc    si                   ;cada que escriba nos movemos a la siguiente posicion
        inc    DI
        call   escribir_caracter        ;escribimos el caracter leido
        cmp    posy, limite_derecho        ;si ya estamos en el limite de la pantalla
        JB     borrar_c

        call   cursor                       ;mandamos a taer el cursor
        mov    BX,locacion                  ;referimos la locacion del mismo
        mov    [buffer+BX], 20H         ;final de los caracteres de modo grafico
        mov    al, 20H                  ;movemos el final de cadena en al que es el caracer
        mov    ah, 09H                  ;funcion perteneciente a int 10h
        mov    BH, 0                    ;bloque a leer y numero de pagina
        mov    BL, 07H                  ;color
        mov    cx, 01                   ;numero de caracteres a cambiar para escribir el nuevo caracter
        int    10H

        pop    BX                 ;regresamos los datos originales 
        mov    posy, BH
        mov    posx, BL
        ret

;presion
;revisado
tecla_insertar:
        mov    dh, posy
        mov    dl, posx
        push   dx
        push   cx
        push   ax
        xor    InKey, 1111B       ;con ayuda de compuertas logicas Convertir el estado de la clave de inserción
        mov    posx, 24
        mov    posy, 75
        call   cursor_posicion
        mov    ah, 02H
        cmp    InKey, 0000B
        jne    colocamos_el_insertar
        mov    cx, 03
;si no salir 
ins_salt_apa:
        mov    dl, 20H
        int    21H
        loop   ins_salt_apa
        jmp    ins_fin
;colocamos en la esquina inferior derecha que estamos en modo de insercion
colocamos_el_insertar:
        print "ins"
ins_fin:
        pop    ax
        pop    cx
        pop    dx
        mov    posy, dh
        mov    posx, dl
        ret

;comprobar que los datos de entrada son un caracter
;
comprobar_caracter:
        cmp    al,0dh            ;si es entero  ;codigo exadecimal para enter
        je     Ent
        cmp    al,08H            ;hacia atras
        je     retroceso
        cmp    al,09H            ;tecla tabulador
        je     Tab
        cmp    al,20H            ;fuera de rango 20 h lo que nos permite conocer si hay 'espacio'
        JB     no_es_caracter
        cmp    al,7EH            ;fuera del rango
        JA     no_es_caracter            
        cmp    InKey,00                 ;Tecla de insertar cuando esta en 0 para conocer si estamos escribiendo sobre un archivo
        jne    insertar_activo
        call   salvar             ;salvamos el buffer
        call   escribir_caracter  ;escribimos el caracter
no_es_caracter:        ret

retroceso:
        cmp    posy, 00            ;comprobamos si ya no podemos retroceder mas
        JBE    no_es_caracter
        dec    posy                ; decrease one posyumn
        call   cursor_posicion              ; move cursor location
        call   borrar_caracter             ; borrar_caracter
        ret
Tab:
        mov    al, 20H            ;espcio
        mov    cx, 06             ;colocar 6 espacios para el tabulador
repeatSpace:
        call   salvar             ;salvamos lo que escribimos en el buffer  en este caso guardamos el tabulador
        call   escribir_caracter  ;escribimos el caracter o el espacio en este caso
        loop   repeatSpace
        ret

insertar_activo:  
        call    insertar_archivo            ;Insert
        ret

Ent:    ;call    insertar_archivo
        call    toENTER
        ret
toENTER:
        call restablecer_posicion_inicial
        call para_abajo
        ret

;lo que ocurre cuando presionamor eter
pulso_f1:
        mov    ax, 0600H          ;posicionar scroll y limpiar
        call   limpiar_pantalla   
        mov    ah, 3CH            ;funcion para crear el arhivo
        mov al,00
        call   crear_archivo2               ; crear nuevo archivo
        call    restablecer_posicion_inicial
        call    para_abajo
        ret
;abrir archivo
pulso_f2:
        mov    ax, 0600H          ;posicionamos el scroll y lo limiamos
        call   limpiar_pantalla   ; Scroll
        mov    ah,3dh            ;abrimos el archivo solo en modo apartura
        mov     al,02
        call   crear_archivo2     ;abrimos o creamos un archivo
        call   leer               ;leemos el contenido de este
        call   restablecer_posicion_inicial
        call    para_abajo
        ret
;Guuardar el contenido
pulso_f3:
        mov    ah,3ch            ;abrimos el archivo solo en modo apartura
        mov     al,02
        call   crear_archivo3     ;abrimos o creamos un archivo
        call escribir_archivo   ;salvamos el contenido
        call restablecer_posicion_inicial
        call para_abajo
        ret


pulso_esc:   
        call   cerrar_archivo              ;cerramos el archivo
        .exit 0                            ;
        ret


;datos en modo insercion del archivo 
insertar_archivo:
        call   cursor
        mov    cx, 8000
        lea    si, buffer+7998  ;seteamos los contadores en las ultimas posiciones del bufer
        lea    DI, buffer+7999
insertar_car:mov    dh, [si]
        mov    [di], dh
        dec    si
        dec    DI
        dec    cx
        cmp    cx, locacion             ; completamos el movimiento
        ja     insertar_car                       ;Salta si está arriba o si es igual o salta si no está abajo.
        call   escribir_caracter        ; Wescribirmos el caracter
        call   salvar                   ;salvamos lo que tiene escrito en el buffer
        mov    BH, posy
        mov    BL, posx
        push   BX                       ;respladamos en pila las posiciones
        call   cursor                   ;llamamos el cursor
        mov    BX, locacion             ;llamamos la locacion del cursor
        mov    dh, Ltop                 ;mocemos lo que tenemos en dh que en este caso es el lo que tiene el buffer en si que es el contador
        push   dx
        mov    Ltop, 00                 ;seteamos el tope izquiero como 00 para volver iniciar en la siguiente linea
        call   cursor
        mov    cx, locacion             ;obtenemos la locacion
        lea    DI, buffer               ;movemos lo que tiene el bufer a di 
	;mostrar y mover el caracter
insertar_mos:     mov    al, [DI+BX]    
        inc    BX                       ;incrementamos bx ambas posiciones tanto x como y
        inc    cx                       ;incrementamos cx la locacion
        call   escribir_caracter        
        cmp    cx, 1598        
        jbe    insertar_mos             ;JBE Si está por debajo o igual CF=1 ó ZF=1
        ;el caracter esta en la ultima posicion de x
        ;todo esto es para escribir caracter y atributo en la posicoin del cursor
        ;donde al, caracter, bh, numero de pagina, bl=color, cx,numero de veces para escribir en el caracter
        ;dudas informacion: https://es-academic.com/dic.nsf/eswiki/591427
        mov    al, buffer+1599  ;pongo el 1599       
        mov    ah, 09H                  ;
        mov    BH, 0             ;bloque del mapa a leer en este caso no hay
        mov    BL, 07H           
        mov    cx, 01           
        int    10H
        pop    dx
        mov    Ltop, dh        
        pop    BX                 ; recobramos la posiocion x
        mov    posy, BH
        mov    posx, BL
        ret

;salvar los datos bufer bufer
salvar:
        push   ax
        call   cursor             ;calculamos los datos de entrada 
        mov    BX, locacion      ; movemos el index a bx
        lea    DI, buffer
        mov    [DI+BX], al        ; movemos los datos de ntrada al bufer
        pop    ax
        ret

;ubicacion actual del cursor
;revisado
cursor:
        push   cx                       ;respaldamos ambos registros
        push   dx
        mov    locacion, 00             ; Reset locacion
        movZX  cx, posx                  ;movzx es para tranferir un dato agregando ceros
        dec    cx
        dec    cx
        movZX  dx, Ltop           ;movzx es para tranferir un dato agregando ceros
        ADD    cx, dx             ;agregamos lo que tenemos en Ltop ah cx 
        cmp    cx, 00             ;estamos en la posicion 1
        jb     agregar_posy
      
;agrgamos posiciones en las x para asi poder la manipulasion
agregar_posx: add   locacion, 80             ;agregamos 80 posiciones adicionales a X 
        loop   agregar_posx
        
agregar_posy: movZX  dx, posy           ;tranferimos un dato agregando ceros
        add    locacion, dx

        pop    dx
        pop    cx
        ret
        
;escribimos el caracter
escribir_caracter:
        push   ax
        push   cx
        ;todo esto es para escribir caracter y atributo en la posicoin del cursor
        ;donde al, caracter, bh, numero de pagina, bl=color, cx,numero de veces para escribir en el caracter
        ;dudas informacion: https://es-academic.com/dic.nsf/eswiki/591427 
        mov    ah, 09H
        mov    bh, 0              ; numero de caracter
        mov    bl, 07H            ; atributo de fondo blanco sobre azul
        mov    cx, 1
        int    10H                ; int 10H,09H - escribir el caracter en la locacion designada usando la interrupcion 10h
ok:     call   mover_derecha                ; mover a la derecha para ir a la siguiente posicion
        call   cursor_posicion              ; move cursor a la posicion
        pop    cx
        pop    ax
        ret

;mever el cursor a la locacion
;revisado
cursor_posicion:
        ;asigna la posicion del cursor 
        ;donde: ah,02h modo, bh es la pagina, dh= fila, dl=columna
        mov    ah, 02H
        mov    bh, 00
        mov    dh, posx
        mov    dl, posy
        int    10H                ; int 10H,02H - setear el cursor en la locacion
        ret

borrar_archivo:
        mov ah,41h
        mov dx, offset nombre_archivo
        int 21h
        jc error_manejo
ret
limpiar_pantalla:   
        push   cx       
        mov    BH, 07H            ; posyor
        mov    cx, 0200H          ; desde arriba a la izquierca
        mov    dx, 164FH          ; hasta abajo a la derecha
        int    10H
        pop    cx
        ret                

END ;fin del programa