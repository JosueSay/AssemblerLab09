; Universidad del Valle de Guatemala
; Josue Say, 22801 - Gustavo Cruz, 22779
; Descripcion; Programa de Cálculo de ISR y Análisis de Régimen Fiscal para Empresa Pequeño Contribuyente
; 15/05/2023

;============
;|| HEADER ||
;============
.386
.model flat, stdcall, C
.stack 4096

;==========
;|| DATA ||
;==========
.data

	;=================================
	;|| Variables de representación ||
	;=================================

	; Nit's de clientes
	nit1 BYTE "123456789",0
	nit2 BYTE "234567891",0
	nit3 BYTE "345678912",0
	nit4 BYTE "456789123",0
	nit5 BYTE "567891234",0
	nit6 BYTE "678912345",0
	nit7 BYTE "789123456",0
	nit8 BYTE "891234567",0
	nit9 BYTE "912345678",0
	nit10 BYTE "012345679",0
	nit11 BYTE "102345678",0
	nit12 BYTE "210345678",0

	; Nombres de clientes
	cliente1 BYTE "Josue",0
	cliente2 BYTE "Maria",0
	cliente3 BYTE "Carlos",0
	cliente4 BYTE "Ana",0
	cliente5 BYTE "Jorge",0
	cliente6 BYTE "Laura",0
	cliente7 BYTE "Juan",0
	cliente8 BYTE "Isabel",0
	cliente9 BYTE "Pedro",0
	cliente10 BYTE "Sofia",0
	cliente11 BYTE "David",0
	cliente12 BYTE "Marta",0

	; 12 meses de facturación
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

	; Clientes, Nits y Meses
	clientes DWORD cliente1, cliente2, cliente3, cliente4, cliente5, cliente6, cliente7, cliente8, cliente9, cliente10, cliente11, cliente12
	nits DWORD nit1, nit2, nit3, nit4, nit5, nit6, nit7, nit8, nit9, nit10, nit11, nit12
	meses DWORD mes1, mes2, mes3, mes4, mes5, mes6, mes7, mes8, mes9, mes10, mes11, mes12

	;===================================
	;|| Variables para hacer cálculos ||
	;===================================
	val_comparacion DWORD 150000			; Valor de comparación (Q150,000.00)
	porcentaje_iva DWORD 5					; Porcentaje de iva
	divisor_iva DWORD 100					; Divisor de iva
	n_facturas DWORD 12						; Cantidad de facturas

	;==========================
	;|| Variables resultados ||
	;==========================
	monto_facturado DWORD 12 DUP (0)		; Monto de cada factura a ingresar (12 facturas)
	iva_calculado DWORD 12 DUP (0)			; IVA calculado de cada factura (12 facturas)
	monto_anual DWORD 0						; Monto anual

	;=====================================
	;|| Variables formato para imprimir ||
	;=====================================
	espacio BYTE " ",0Ah,0
	encabezado BYTE "LOS DATOS GENERALES SON:",0Ah,0																					
	mencion1 BYTE "Ingresa el monto para el mes '%s': ",0
	contMonto BYTE "%d", 0
	identificacion_datos BYTE "||      MES      ||Cliente        ||NIT       ||MONTO     ||IVA       ||", 0Ah, 0
	formato_datos_empresa BYTE "||%-15s||%-15s||%-10s||%-10d||%-10d||", 0Ah, 0
	formato_monto BYTE "El monto anual es '%d'.",0Ah, 0
	aviso1 BYTE "AVISO: Actualizar su regimen tributario a 'IVA General'.",0Ah, 0
	aviso2 BYTE "AVISO: Para el siguiente periodo fiscal, la empresa puede continuar como 'pequenio contribuyente'.",0Ah, 0

;==========
;|| CODE ||
;==========
.code
main proc
	; Librerias
	includelib libucrt.lib
	includelib legacy_stdio_definitions.lib
	includelib libcmt.lib
	includelib libvcruntime.lib

	extrn printf:near
	extrn scanf:near
	extrn exit:near

	; ========================================
	; ||CODIGO PARA PEDIR LOS MONTOS POR MES||
	; ========================================
	; Apuntador
	mov esi, 0
	; Bucle para pedir datos
	lectura_datos:
		mov ebx, meses[esi*4]          				; Obtener el mes
		push ebx			
		push offset mencion1			
		call printf                    				; Imprimir el mes
		add esp, 8                      			; Limpiar el stack
			
		lea eax, monto_facturado[esi*4] 			; Lugar donde se guarda monto_facturado
		push eax			
		push offset contMonto           			; Ingreso de monto
		call scanf			
		add esp, 8                      			; Limpiar el stack
			
		inc esi                         			; Incrementar contador de mes
		cmp esi, n_facturas             			; Comparar con la cantidad de facturas
		jl lectura_datos                			; Si es menor, volver a pedir datos

	; =======================================
	; ||CODIGO PARA CALCULAR EL MONTO ANUAL||
	; =======================================
	mov esi, OFFSET monto_facturado     			; Monto facturado
	mov ecx, n_facturas                 			; Numero de elementos en la lista
	; Bucle para obtener el monto anual			
	bucle_monto_anual:			
		mov eax, [esi]                  			; Se obtiene el valor de monto_factura
		add monto_anual, eax            			; Se suma el valor del monto anual con los valores de monto_factura
		add esi, 4                      			
		dec ecx                         			
		jnz bucle_monto_anual           			; Si ecx no es cero, continuar con el bucle

	; ========================================
	; ||CODIGO PARA CALCULAR EL IVA POR MES||
	; ========================================
	mov esi, 0                          			; Inicializar contador de meses
	mov ecx, n_facturas                 			; Numero de elementos en la lista
	; Bucle para realizar el calculo
	bucle_iva:
		mov eax, [monto_facturado + esi*4]          ; Obtener el valor de monto_facturado
		imul eax, porcentaje_iva                    
		cdq                                         ; Limpiar edx
		idiv divisor_iva                            
		mov [iva_calculado + esi*4], eax           	
		inc esi                                     ; Incrementar el contador de meses
		loop bucle_iva                              ; Continuar el bucle hasta que ecx llegue a cero

	; =============================
	; ||CODIGO IMPRIMIR LOS DATOS||
	; =============================
	;|| ENCABEZADO ||
	push OFFSET espacio
	call printf
	add esp, 4
	push OFFSET encabezado
	call printf
	add esp, 4
	push OFFSET identificacion_datos
	call printf
	add esp, 4

	;|| DATOS GENERALES ||
	mov esi, 0
	imprimir_datos:
		mov eax, [meses + esi*4]              		; Cargar mes
		mov ebx, [clientes + esi*4]           		; Cargar cliente
		mov ecx, [nits + esi*4]               		; Cargar nit
		mov edx, [monto_facturado + esi*4]    		; Cargar monto
		mov edi, [iva_calculado + esi*4]      		; Cargar iva
		push edi
		push edx
		push ecx
		push ebx
		push eax
		push OFFSET formato_datos_empresa
		call printf
		add esp, 24                          		; Limpiar stack
		inc esi                               		; Incrementar el índice de factura y de mes
		cmp esi, n_facturas                   		; Comparar el índice con la cantidad de facturas
		jl imprimir_datos                     		; Saltar a imprimir_datos si el índice es menor que la cantidad de facturas


		;|| MONTO ||
	mostrar_monto:
        mov eax, monto_anual               		; Cargar el valor de monto_anual en eax
        push eax			
		push OFFSET formato_monto          			; Imprimir el monto anual
		call printf			
		add esp, 8                         			; Limpiar stack
	
	;|| MONTO ||
    mostrar_aviso:
        mov eax, monto_anual               		; Cargar el valor de monto_anual en eax
        mov ebx, val_comparacion           		; Cargar el valor de val_comparacion en ebx
        cmp eax, ebx                       		; Comparar el valor en eax (monto_anual) con 150000
        jg mensaje1                        		; Si monto_anual > 150000, saltar a la etiqueta mensaje1
        jmp mensaje2                        		; Si monto_anual <= 150000, saltar a la etiqueta mensaje2

    ;|| AVISO 1 ||
    mensaje1:
        push OFFSET aviso1
        call printf
        add esp, 4
        jmp finalizar

    ;|| AVISO 2 ||
    mensaje2:
        push OFFSET aviso2
        call printf
        add esp, 4

	finalizar:
	call exit

ret
main endp
end
