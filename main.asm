;-------------------------------------------------------------------------------
;  Simple Calculator - creates a simple calculator that adds, subtracts, divides,
;                      multiplies, clears, and has bounds at 0 and 255
;  Author - C2C Erik Thompson
;  Date - 15 September 2014
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------

            .text                           ; Assemble into program memory
funct: 		.byte 	0x22, 0x11, 0x22, 0x22, 0x33, 0x33, 0x08, 0x44, 0x08, 0x22, 0x09, 0x44, 0xff, 0x11, 0xff, 0x44, 0xcc, 0x33, 0x02, 0x33, 0x00, 0x44, 0x33, 0x33, 0x08, 0x55		; "A" Mathematical function to be performed
;funct: 		.byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0xDD, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x22, 0xFD, 0x55													; "B" Mathematical function to be performed
;funct: 		.byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x44, 0x22, 0x22, 0x22, 0x11, 0xCC, 0x55																						; "C" Mathematical function to be performed
add: 		.byte 	0x11					;Variables for performing of the
sub: 		.byte 	0x22					;specified function
multi: 		.byte 	0x33
clr: 		.byte 	0x44
end: 		.byte	0x55
bound:		.byte	0xFF
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
.space                          ; that have references to current

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------


			mov.w	#funct, 	r4			;Preps the program by moving he functino into a register,
			mov.b	#0xFF,		r9			;setting the upper bound for the numbers
			mov.w	#0x0200,	r8			;setting the address location for the answers
			mov.b	@r4+,		r5			;moving the first number into a register
			mov.b	@r4+,		r7			;moving the first operand into a register
top:										;loops back here after performing each operation
			mov.b	#0x01,		r10			;register used for checking multiplication
			cmp.b	add,		r7			;compares r7 to different variables to determine what operation to perform
			jz		adder
			cmp.b	sub,		r7
			jz		subtractor
			cmp.b	multi,		r7
			jz		multiplier
			cmp.b	clr,		r7
			jz		clearer
adder:										;performs addition
			mov.b	@r4+,		r6
			add		r6,			r5
			jmp		linker

subtractor:									;performs subtraction
			mov.b	@r4+,		r6
			sub		r6,			r5
			jn		negative
			jmp		linker

multiplier:									;performs multiplication
			mov.b	@r4+,		r6
			cmp		#0x01,		r6			;checks if multiplying by 1
			jz		linker
			cmp		#0x00,		r6			;checks if multiplying by zero
			jz		ifZero
			cmp		#0x00,		r5			;checks if multiplying by zero (other number)
			jz		ifZero
			mov.b	r5,			r11


contMultiplier:
			rla	r5							;rotates number in r5 to the left, multiplying by two each time
			rla	r10							;rotates r10 "checker number" to the left, multiplying by two
			cmp		r6,			r10			;compares the value of r10 to r6
			jz		linker					;if equal, done with multiplication
			jge		finishMultiply			;if greater, moves to subtraction stage
			jmp		contMultiplier			;if less, does multiplication again

finishMultiply:

			sub		r6,			r10			;determines number of subtractions necessary

contFinishMultiply:
			sub		r11,			r5		;subtracts the original number from the multiplied result the
			dec		r10						;number of times specified in the previous step
			cmp		#0x00,		r10
			jz		linker
			jmp		contFinishMultiply

ifZero:
			mov.b	#0x00,		r5			;makes answer zero if multiplied by zero
			jmp		linker
clearer:									;clears number in register and moves to next spot in memory
			mov.b	#0x00,		r5
			mov.b	r5,			0(r8)
			mov.b	@r4+,		r5
			jmp		ifClear
negative:									;lower bound at zero for answers

			mov.b	#0x00,		r5
			jmp		linkerCont
			clrn
tooHigh:									;upper bound at 0x55 (255) for answers
			mov.b	#0xFF,		r5
			jmp	linkerCont
			clrn
linker:										;moves the program to the next operand
			cmp		r5,		r9
			jn		tooHigh
linkerCont:
			mov.b	r5,			0(r8)
ifClear:
			inc		r8
			mov.b	@r4+,		r7
			cmp.b	end,		r7
			jz		finish
			jmp		top
finish:										;infintie loop
			jmp		finish



;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
