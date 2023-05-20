; Universidad del Valle de Guatemala
; Josue Say, 22801 - Gustavo Cruz, 22779
; Descripcion; Programa de Cálculo de ISR y Análisis de Régimen Fiscal para Empresa Pequeño Contribuyente
; 15/05/2023

;============
;|| HEADER ||
;============
.386
	includelib libcmt.lib
	includelib libvcruntime.lib
	includelib libucrt.lib
	includelib legacy_stdio_definitions.lib

.model flat, stdcall, C
	printf proto c : vararg
	scanf  proto c : vararg

.stack 4096


;==========
;|| DATA ||
;==========
.data
	
	;===============================================
	;|| Variables de representación de la empresa ||
	;===============================================
	cliente BYTE 'EMPRESA INC.', 0																	; Nombre de la empresa
	nit BYTE '123456789',0																			; NIT de la empresa
	monto_facturado DWORD 1000, 2000, 1500, 3000, 2500, 1800, 1200, 2800, 3500, 4000, 2200, 1800	; Monto de cada factura (12 facturas)
	; Lista con los meses de las 12 facturas
	mes1 BYTE "JUNIO2022", 0
    mes2 BYTE "JULIO2022", 0
    mes3 BYTE "AGOSTO2022", 0
    mes4 BYTE "SEPTIEMBRE2022", 0
    mes5 BYTE "OCTUBRE2022", 0
    mes6 BYTE "NOVIEMBRE2022", 0
    mes7 BYTE "DICIEMBRE2022", 0
    mes8 BYTE "ENERO2023", 0
    mes9 BYTE "FEBRERO2023", 0
    mes10 BYTE "MARZO2023", 0
    mes11 BYTE "ABRIL2023", 0
    mes12 BYTE "MAYO2023", 0
    meses DWORD mes1, mes2, mes3, mes4, mes5, mes6, mes7, mes8, mes9, mes10, mes11, mes12
	
	;===================================
	;|| Variables para hacer cálculos ||
	;===================================
	val_comparacion DWORD 150000				; Valor de comparación (Q150,000.00)
	porcentaje_isr DWORD 5						; Porcentaje de isr
	divisor_isr DWORD 100						; Divisor de isr
	n_facturas DWORD 12							;Cantidad de facturas

	;==========================
	;|| Variables resultados ||
	;==========================
	isr_calculado DWORD 12 DUP(?)				; ISR calculado de cada factura (12 facturas)
	monto_anual DWORD 0							; Monto anual

	;=====================================
	;|| Variables formato para imprimir ||
	;=====================================
	formato_encabezado BYTE "El Cliente: '%s' con NIT '%s'.",0Ah, 0																	; Formato para imprimir el nombre del cliente
	formato_monto BYTE "El monto anual es '%d'.",0Ah, 0																				; Formato para imprimir el monto anual
	aviso1 BYTE "AVISO: Actualizar su régimen tributario a 'Mediano Contribuyente'.",0Ah, 0											; Aviso 1 para el monto anual
	aviso2 BYTE "AVISO: Para el siguiente periodo fiscal, la empresa puede continuar como 'pequenio contribuyente'.",0Ah, 0			; Aviso 2 para el monto anual
	formato_datos_empresa BYTE "||%-15s||%-10d||%-10d||", 0Ah, 0     																; Formato para imprimir los meses montos e isr
	mencion BYTE "LOS DATOS GENERALES SON:",0Ah,0																					; Cadena para mostrar datos generales
	identificacion_datos BYTE "||      MES      ||MONTOS    ||ISR       ||", 0Ah, 0									; Cadena a mostrar para identificar los datos mes, montos e isr
;==========
;|| CODE ||
;==========
.code
main    proc
    ; =========================================
	; ||CODIGO PARA CALCULAR EL MONTO POR ISR|| 
	; =========================================
	; Moviendo las direcciones de las listas
	mov esi, OFFSET monto_facturado 		
	mov edi, OFFSET isr_calculado 			 			
	mov ecx, n_facturas							; Numero de elementos en la lista
	
	; Bucle para realizar el calculo
	bucle_isr:
		mov eax, [esi]							; Se obtiene el valor de monto_factura
		imul eax, porcentaje_isr				; Multiplica el valor de la lista por 5
		xor edx, edx							; Se limpia edx
		mov ebx, divisor_isr					; Valor para dividir eax
		idiv ebx								; Se divide el resultado anterior de ebx entre eax
		mov [edi], eax							; Guarda el resultado en isr_calculado
		add esi, 4								; Se avanza a la siguiente posición de monto_facturado
		add edi, 4								; Se avanza a la siguiente posición de isr_calculado
		dec ecx									; Reducir el valor del registro ecx hasta cero
		jnz bucle_isr							; Si ecx es cero seguir con el codigo

	; =======================================
	; ||CODIGO PARA CALCULAR EL MONTO ANUAL|| 
	; =======================================
	mov esi, OFFSET monto_facturado				; Monto facturado
	mov ecx, n_facturas							; Numero de elementos en la lista
		
	; Bucle para realizar el calculo		
	bucle_monto_anual:		
		mov eax, [esi]							; Se obtiene el valor de monto_factura				
		add monto_anual, eax					; Se suma el valor del monto anual con los valores de monto_factura
		add esi, 4								; Se avanza a la siguiente posición de monto_facturado
		dec ecx									; Reducir el valor del registro ecx hasta cero
		jnz bucle_monto_anual					; Si ecx es cero seguir con el codigo
	
	; =============================
	; ||CODIGO IMPRIMIR LOS DATOS|| 
	; =============================
	;|| ENCABEZADO ||
	encabezado:
		INVOKE printf, addr formato_encabezado, addr cliente, addr nit		; se invoca printf y se imprime el cliente y nit
	
	;|| DATOS MES,MONTO,ISR ||
    INVOKE printf, ADDR mencion
    INVOKE printf, ADDR identificacion_datos
	mov esi, 0  															; Inicializar índice de factura en 0

    imprimir_montos_meses:
		mov eax, [meses + esi*4]                                          ; Cargar la dirección del mes actual en eax
		mov ebx, [monto_facturado + esi*4]                                ; Cargar el valor de la factura actual en ebx
		mov ecx, [isr_calculado + esi*4]                                  ; Cargar el valor del ISR calculado actual en ecx
		INVOKE printf, ADDR formato_datos_empresa, eax, ebx, ecx          ; Imprimir el mes, el monto y el ISR calculado
		add esi, 1                                                        ; Incrementar el índice de factura y de mes
		cmp esi, n_facturas                                               ; Comparar el índice con la cantidad de facturas y de meses
		jl imprimir_montos_meses                                          ; Saltar a imprimir_montos_meses si el índice es menor que la cantidad de facturas y de meses

	;|| MONTO ||
	mostrar_monto:
		mov eax, monto_anual												; Carga el valor de monto_anual en eax
		mov ebx, val_comparacion											; Cargar el valor de val_comparacion a ebx
		INVOKE printf, addr formato_monto, monto_anual						; Imprimir el monto anual								
		cmp eax, ebx														; Compara el valor en eax (monto_anual) con 150000
		jg mensaje1															; Si monto_anual > 150000, salta a la etiqueta mensaje1
		jl mensaje2															; Si monto_anual < 150000, salta a la etiqueta mensaje2
	
	;|| AVISO 1 ||
	mensaje1:
		INVOKE printf, addr aviso1

	;|| AVISO 2 ||
	mensaje2:
		INVOKE printf, addr aviso2
	ret
main    endp
        end